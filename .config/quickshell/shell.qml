//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

// Config entry point: mounts the bar + overlays.
ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    OsdOverlay {}
    Toast {}
    NotificationCenter {}
    PowerMenu {}
    Launcher {}
    LockScreen {}

    // BlueZ pairing agent (Quickshell has no Agent1). A reload orphans the old child,
    // so kill stale agents first. The script path goes through the environment so
    // pkill's pattern cannot match the wrapper itself.

    // bt-agent.py exits with this code when BlueZ is unavailable; restarting would loop.
    readonly property int btAgentNoBluez: 2

    Process {
        id: btAgent
        command: ["sh", "-c",
            "pkill -f '[b]t-agent.py' 2>/dev/null; exec python3 \"$BT_AGENT_SCRIPT\""]
        environment: ({ BT_AGENT_SCRIPT: Quickshell.shellDir + "/scripts/bt-agent.py" })
        running: true
        onExited: (exitCode) => { if (exitCode !== btAgentNoBluez) btAgentRestart.restart(); }
    }

    Timer {
        id: btAgentRestart
        interval: 3000
        repeat: false
        onTriggered: btAgent.running = true
    }
}
