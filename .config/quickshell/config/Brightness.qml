pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Screen brightness: the laptop backlight (sysfs + brightnessctl) or, when
// there is none, an external monitor over DDC/CI (ddcutil).
Singleton {
    id: root

    readonly property real stepSize: 0.10

    // Current brightness, 0..1.
    property real value: 0

    // A change requested through this singleton (keys, slider).
    signal adjusted(real value)
    // A change made behind our back (external tool, DDC re-read).
    signal changedExternally(real value)

    // The device name differs per machine (intel_backlight, amdgpu_bl0, ...),
    // so it is detected at startup.
    property string backlight: ""
    property int maxRaw: 0

    // External monitors have no /sys/class/backlight: brightness is a DDC/CI
    // register. NVIDIA exposes one I2C adapter per output and no `ddc`
    // symlink, so the bus is probed instead.
    property bool ddc: false
    property int ddcBus: -1
    property int ddcMax: 100

    property real lastValue: -1

    // Writes are serialized: while a command runs, further requests are
    // coalesced into pendingValue and applied when it exits, which keeps
    // slider drags smooth.
    property real pendingValue: -1
    property bool writing: false

    function clamp01(v: real): real {
        return Math.max(0, Math.min(1, v));
    }

    function step(up: bool): void {
        // First key after login probes DDC; the next one applies the change.
        if (!backlight && !ddc) {
            ddcDetect.running = true;
            return;
        }
        set(value + (up ? stepSize : -stepSize));
    }

    function set(v: real): void {
        // Never write 0 to a monitor: some panels switch off their backlight
        // and only their own buttons bring it back.
        value = Math.max(ddc ? 0.01 : 0, clamp01(v));
        lastValue = value;
        pendingValue = value;
        adjusted(value);
        applyPending();
    }

    // sysfs emits no inotify events, so changes by other tools are picked up
    // on demand with `qs ipc call osd refresh` instead of polling.
    function refresh(): void {
        if (ddc) ddcRead.running = true;
        else brightnessFile.reload();
    }

    function acceptReading(fraction: real): void {
        value = clamp01(fraction);
        if (Math.abs(value - lastValue) < 0.004) return;
        lastValue = value;
        changedExternally(value);
    }

    function useBacklight(name: string): void {
        if (!name || name === backlight) return;
        backlight = name;
        maxFile.reload();
        brightnessFile.reload();
    }

    function applyPending(): void {
        if (writing || pendingValue < 0) return;
        writing = true;
        const target = pendingValue;
        pendingValue = -1;
        if (ddc) {
            setProc.command = ["ddcutil", "--bus", String(ddcBus), "--skip-ddc-checks",
                "--noverify", "setvcp", "10", String(Math.max(1, Math.round(target * ddcMax)))];
        } else {
            setProc.command = ["brightnessctl", "set", Math.round(target * 100) + "%"];
        }
        setProc.running = true;
    }

    function readBacklight(): void {
        // Ignore reads that race with our own write.
        if (writing || pendingValue >= 0) return;
        // The two files load independently, so `brightness` may finish before
        // `max_brightness`; read the maximum synchronously in that case.
        if (maxRaw <= 0) {
            const max = parseInt(maxFile.text());
            if (!isNaN(max) && max > 0) maxRaw = max;
        }
        const raw = parseInt(brightnessFile.text());
        if (maxRaw > 0 && !isNaN(raw)) acceptReading(raw / maxRaw);
    }

    Component.onCompleted: blDetect.running = true

    Process {
        id: blDetect
        command: ["sh", "-c", "ls -1 /sys/class/backlight | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim();
                if (name) root.useBacklight(name);
                else ddcDetect.running = true;
            }
        }
    }

    // `detect --brief` lists each monitor with its I2C bus and DRM connector.
    // Prefer the focused output; otherwise take the first.
    Process {
        id: ddcDetect
        command: ["sh", "-c", "ddcutil --skip-ddc-checks detect --brief 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const focused = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
                const blocks = this.text.split(/^Display \d+/m).slice(1);
                const block = blocks.find(b => focused && b.includes("-" + focused))
                              || blocks.find(b => /Monitor:|EDID synopsis:/.test(b));
                const bus = block && block.match(/i2c-(\d+)/);
                if (!bus) return;
                root.ddcBus = parseInt(bus[1]);
                root.ddc = true;
                ddcRead.running = true;
            }
        }
    }

    // VCP 10 is brightness; `--brief` answers "VCP 10 C <current> <max>".
    Process {
        id: ddcRead
        command: ["sh", "-c",
            "ddcutil --bus " + root.ddcBus + " --skip-ddc-checks getvcp 10 --brief 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const reading = this.text.match(/VCP\s+10\s+C\s+(\d+)\s+(\d+)/);
                if (!reading) {
                    // The bus stopped answering (resume, monitor off): probe
                    // again on the next brightness action.
                    root.ddc = false;
                    return;
                }
                const max = parseInt(reading[2]);
                if (!(max > 0)) return;
                root.ddcMax = max;
                root.acceptReading(parseInt(reading[1]) / max);
            }
        }
    }

    Process {
        id: setProc
        onExited: {
            root.writing = false;
            root.applyPending();
            // DDC writes are absolute; only the backlight needs a re-read.
            if (!root.ddc) brightnessFile.reload();
        }
    }

    FileView {
        id: maxFile
        path: root.backlight ? "/sys/class/backlight/" + root.backlight + "/max_brightness" : ""
        blockLoading: true
        onLoaded: {
            const max = parseInt(maxFile.text());
            if (!isNaN(max) && max > 0) root.maxRaw = max;
        }
    }

    FileView {
        id: brightnessFile
        path: root.backlight ? "/sys/class/backlight/" + root.backlight + "/brightness" : ""
        blockLoading: true
        onLoaded: root.readBacklight()
    }
}
