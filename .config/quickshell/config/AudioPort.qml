pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Whether the default sink is headphones. PipeWire has no such property, so the port comes from pactl.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    property string activePort: ""

    readonly property bool headphones: {
        function mentionsHeadphones(text) {
            const lower = String(text || "").toLowerCase();
            return lower.indexOf("headphone") !== -1 || lower.indexOf("headset") !== -1;
        }
        if (!sink) return false;
        const props = sink.properties || {};
        return mentionsHeadphones(props["device.icon-name"])
            || mentionsHeadphones(sink.name)
            || mentionsHeadphones(sink.description + " " + sink.nickname)
            || mentionsHeadphones(activePort);
    }

    function parseActivePort(text: string): void {
        const target = sink ? sink.name : "";
        let inTargetSink = false;
        root.activePort = "";
        for (const line of text.split("\n")) {
            const name = line.match(/^\s*Name:\s*(\S+)/);
            if (name) inTargetSink = target !== "" && name[1] === target;
            const port = inTargetSink && line.match(/^\s*Active Port:\s*(\S+)/);
            if (port) {
                root.activePort = port[1];
                return;
            }
        }
    }

    // Port changes always emit a pulse event, so no polling is needed.
    Process {
        id: portEvents
        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: (line) => {
                if (/ on (sink #|card #|server)/.test(line)) portDebounce.restart();
            }
        }
        onExited: restartTimer.restart()
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: portEvents.running = true
    }

    // A held volume key emits a burst of sink events; collapse them into one read.
    Timer {
        id: portDebounce
        interval: 300
        onTriggered: portQuery.running = true
    }

    Process {
        id: portQuery
        command: ["pactl", "list", "sinks"]
        stdout: StdioCollector {
            onStreamFinished: root.parseActivePort(this.text)
        }
    }

    Component.onCompleted: portQuery.running = true
}
