import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.config

// Default sink volume control.
// Left click = audio panel · wheel = ±5% · OSD appears automatically.
Item {
    id: root

    implicitWidth: row.implicitWidth + 14
    implicitHeight: 26

    readonly property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property real volume: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false

    function volumeIcon(): string {
        if (root.muted || root.volume <= 0.001) return Icons.volumeMute;
        if (root.volume < 0.34) return Icons.volumeLow;
        if (root.volume < 0.67) return Icons.volumeMedium;
        return Icons.volumeHigh;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "audio") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.volumeIcon()
            color: root.muted ? Theme.overlay0 : Theme.flamingo
            font.family: Theme.font
            font.pixelSize: Theme.iconSize
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            } else {
                Ui.togglePopout("audio");
            }
        }

        onWheel: (wheel) => {
            if (!root.audio) return;
            const step = 0.05;
            const next = root.audio.volume + (wheel.angleDelta.y > 0 ? step : -step);
            root.audio.volume = Math.max(0, Math.min(1, next));
            if (root.audio.volume > 0 && root.audio.muted)
                root.audio.muted = false;
        }
    }
}