import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.config
import qs.components

// Default sink volume control.
// Left click = audio panel · middle click = mute · wheel = ±5%.
BarButton {
    id: root

    popoutId: "audio"
    implicitWidth: row.implicitWidth + 14
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real volume: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false

    property string activePort: ""

    // The active port comes from pactl because Pipewire exposes no direct
    // "headphones plugged" property.
    readonly property bool headphones: {
        function has(s) { return s.indexOf("headphone") !== -1 || s.indexOf("headset") !== -1; }
        if (!sink) return false;
        const props = sink.properties || {};
        if (has(String(props["device.icon-name"] || "").toLowerCase())) return true;
        if (has(String(sink.name || "").toLowerCase())) return true;
        if (has((String(sink.description || "") + " " + String(sink.nickname || "")).toLowerCase())) return true;
        return has(activePort.toLowerCase());
    }

    function volumeIcon(): string {
        if (root.muted || root.volume <= 0.001) return Icons.volumeMute;
        if (root.headphones) return Icons.headphones;
        if (root.volume < 0.34) return Icons.volumeLow;
        if (root.volume < 0.67) return Icons.volumeMedium;
        return Icons.volumeHigh;
    }

    function parseActivePort(text): void {
        const target = sink ? sink.name : "";
        if (!target) return;
        const lines = text.split("\n");
        let current = false;
        for (let i = 0; i < lines.length; i++) {
            const name = lines[i].match(/^\s*Name:\s*(\S+)/);
            if (name) {
                current = (name[1] === target);
                continue;
            }
            if (!current) continue;
            const port = lines[i].match(/^\s*Active Port:\s*(\S+)/);
            if (port) {
                root.activePort = port[1];
                return;
            }
        }
        root.activePort = "";
    }

    onClicked: (mouse) => {
        if (mouse.button === Qt.MiddleButton) {
            if (root.audio) root.audio.muted = !root.audio.muted;
        } else {
            Ui.togglePopout("audio");
        }
    }

    onWheeled: (wheel) => {
        if (!root.audio) return;
        const step = 0.05;
        const next = root.audio.volume + (wheel.angleDelta.y > 0 ? step : -step);
        root.audio.volume = Math.max(0, Math.min(1, next));
        if (root.audio.volume > 0 && root.audio.muted)
            root.audio.muted = false;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: portQuery.running = true
    }

    Process {
        id: portQuery
        command: ["pactl", "list", "sinks"]
        stdout: StdioCollector {
            onStreamFinished: root.parseActivePort(this.text)
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.volumeIcon()
            color: root.muted ? Theme.overlay0 : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.iconSize + 2
        }
    }
}
