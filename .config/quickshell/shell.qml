//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

// Config entry point: mounts the bar + overlays.
ShellRoot {
    Bar {}
    OsdOverlay {}
    Toast {}
    NotificationCenter {}
    PowerMenu {}
    Launcher {}
    LockScreen {}

    // BlueZ pairing agent. Quickshell 0.3.2 provides no org.bluez.Agent1,
    // so without this the panel cannot pair devices that require a
    // confirmation/passkey (keyboards, earbuds, ...).
    //
    // On a config reload Quickshell orphans the previous child (QProcess does
    // not kill it) and starts a new one, so old agents pile up holding the
    // BlueZ agent registration. Kill any stale instance first, via the `[b]`
    // trick so the pattern itself is not matched. `pkill -f` reads
    // /proc/<pid>/cmdline, so the script path must NOT be part of this
    // wrapper's argv or pkill would kill it before it can exec python. It is
    // passed through the environment instead, which lives in /proc/<pid>/environ
    // and is invisible to pkill (clearEnvironment defaults to false, so PATH is
    // still inherited).
    Process {
        id: btAgent
        command: ["sh", "-c",
            "pkill -f '[b]t-agent.py' 2>/dev/null; exec python3 \"$BT_AGENT_SCRIPT\""]
        environment: ({ BT_AGENT_SCRIPT: Quickshell.shellDir + "/scripts/bt-agent.py" })
        running: true
        onExited: btAgentRestart.restart()
    }

    Timer {
        id: btAgentRestart
        interval: 3000
        repeat: false
        onTriggered: btAgent.running = true
    }
}
