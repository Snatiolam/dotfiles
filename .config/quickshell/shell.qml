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
    Process {
        id: btAgent
        command: ["python3", Quickshell.configDir + "/scripts/bt-agent.py"]
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
