#!/usr/bin/env python3
"""Supervise Quickshell in a Hyprland session.

Quickshell 0.3.2 does not recreate its PanelWindows when every output is
removed and re-added (e.g. unplugging/replugging the only HDMI monitor).
Qt falls back to "There are no outputs - creating placeholder screen" and the
bar never comes back even though the compositor sees the monitor again. The
process stays alive, so a plain crash watchdog would not catch it.

This supervisor:
  * restarts Quickshell if it exits unexpectedly, and
  * restarts it after a debounced monitor add/remove burst, which rebuilds
    the layer surfaces on the new output list.

A restart is postponed while the compositor has no real output (only its
"FALLBACK" placeholder), otherwise Quickshell would come back in the very
state that breaks it: no outputs, no bar to map.

Only one instance runs per session (flock); it owns the quickshell child and
forwards SIGTERM/SIGINT so the bar goes away cleanly when the session ends.
"""

import fcntl
import glob
import json
import os
import select
import shutil
import signal
import socket
import subprocess
import sys
import time

RESTART_DELAY = 1.5      # seconds between a crash and the next launch
MAX_RESTART_DELAY = 30.0  # cap for the crash backoff
HOTPLUG_DEBOUNCE = 3.0   # wait for a hotplug burst to settle before restarting
NO_OUTPUT_RETRY = 1.0    # re-check interval while only the fallback screen exists
SOCKET_RETRY = 2.0       # Hyprland not ready / restarted
EVENTS = {"monitoradded", "monitorremoved",
          "monitoraddedv2", "monitorremovedv2"}

RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
STATE_DIR = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "quickshell-watchdog",
)
LOCK_PATH = os.path.join(RUNTIME, "quickshell-watchdog.lock")
LOG_PATH = os.path.join(STATE_DIR, "log")

stopping = False
child = None
child_started_at = 0.0


def log(message):
    try:
        os.makedirs(STATE_DIR, exist_ok=True)
        stamp = time.strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_PATH, "a", encoding="utf-8") as fh:
            fh.write(f"{stamp} {message}\n")
    except OSError:
        pass


def event_socket_path():
    candidates = []
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if signature:
        candidates.append(os.path.join(RUNTIME, "hypr", signature,
                                       ".socket2.sock"))
    # Hyprland may have restarted since the session started, so fall back to
    # whatever socket directory currently exists.
    candidates.extend(glob.glob(os.path.join(RUNTIME, "hypr", "*",
                                             ".socket2.sock")))
    for path in candidates:
        if os.path.exists(path):
            return path
    return None


def start_child():
    global child, child_started_at
    child = subprocess.Popen(["quickshell"])
    child_started_at = time.monotonic()
    log(f"started quickshell (pid {child.pid})")


def stop_child(sig=signal.SIGTERM, timeout=5.0):
    global child
    if child is None:
        return
    if child.poll() is None:
        try:
            child.send_signal(sig)
        except ProcessLookupError:
            pass
        try:
            child.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            child.kill()
            try:
                child.wait(timeout=2.0)
            except subprocess.TimeoutExpired:
                pass
    log(f"stopped quickshell (pid {child.pid})")
    child = None


def restart_child(reason):
    log(f"restarting quickshell: {reason}")
    stop_child()
    start_child()


def on_signal(signum, _frame):
    global stopping
    stopping = True
    log(f"received signal {signum}")


def connect_events():
    path = event_socket_path()
    if path is None:
        return None
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.setblocking(False)
    try:
        sock.connect(path)
    except OSError:
        sock.close()
        return None
    return sock


def real_outputs():
    """Return the list of active, non-placeholder monitors.

    `None` means "unknown" (hyprctl missing or failed); callers should then
    fail open and restart anyway.
    """
    exe = shutil.which("hyprctl")
    if exe is None:
        return None
    try:
        result = subprocess.run([exe, "-j", "monitors"], capture_output=True,
                                text=True, timeout=3.0)
        monitors = json.loads(result.stdout)
    except (OSError, subprocess.SubprocessError, ValueError):
        return None
    return [m for m in monitors
            if m.get("name") != "FALLBACK" and not m.get("disabled")]


def main():
    global stopping, child, child_started_at

    os.makedirs(STATE_DIR, exist_ok=True)
    lock = open(LOCK_PATH, "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print("quickshell-watchdog: already running", file=sys.stderr)
        return 0

    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)

    # Take ownership of an instance started by the old autostart line, if any.
    subprocess.run(["pkill", "-x", "quickshell"],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    start_child()

    events = None
    next_connect = 0.0
    buffer = ""
    pending = None          # (deadline, reason)
    fast_failures = 0
    postponed = False

    while not stopping:
        now = time.monotonic()

        # Child died on its own (crash, quit or lost wayland connection).
        if child is not None and child.poll() is not None:
            uptime = now - child_started_at
            code = child.returncode
            child = None
            if uptime < 5.0:
                fast_failures += 1
            else:
                fast_failures = 0
            delay = min(RESTART_DELAY * (2 ** max(0, fast_failures - 1)),
                        MAX_RESTART_DELAY)
            log(f"quickshell exited with code {code} after {uptime:.1f}s")
            pending = (now + delay, f"process exited (code {code})")

        # Reconnect the Hyprland event socket if needed.
        if events is None and now >= next_connect:
            events = connect_events()
            next_connect = now + SOCKET_RETRY
            if events is not None:
                log("connected to Hyprland event socket")

        # Drain pending events; a monitor burst pushes the restart deadline.
        if events is not None:
            try:
                readable, _, _ = select.select([events], [], [], 0.25)
            except OSError:
                readable = []
            if readable:
                try:
                    chunk = events.recv(65536)
                except OSError:
                    chunk = b""
                if not chunk:
                    events.close()
                    events = None
                    log("Hyprland event socket closed")
                else:
                    buffer += chunk.decode("utf-8", "replace")
                    *lines, buffer = buffer.split("\n")
                    for line in lines:
                        event = line.split(">>", 1)[0]
                        if event in EVENTS:
                            log(f"hotplug event: {line}")
                            pending = (time.monotonic() + HOTPLUG_DEBOUNCE,
                                       "monitor configuration changed")
        else:
            time.sleep(0.25)

        if pending is not None and time.monotonic() >= pending[0]:
            reason = pending[1]
            outputs = real_outputs()
            if outputs is not None and not outputs:
                # Only Hyprland's placeholder screen is left: starting
                # Quickshell now would give us the no-outputs state that never
                # maps the bar. Wait for a real output to show up.
                if not postponed:
                    log("no real output connected yet; postponing restart")
                    postponed = True
                pending = (time.monotonic() + NO_OUTPUT_RETRY, reason)
            else:
                postponed = False
                pending = None
                if child is None:
                    log(f"starting quickshell: {reason}")
                    start_child()
                else:
                    restart_child(reason)

    if events is not None:
        events.close()
    stop_child()
    log("supervisor exiting")
    return 0


if __name__ == "__main__":
    sys.exit(main())
