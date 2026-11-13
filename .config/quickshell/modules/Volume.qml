import QtQuick
import Quickshell.Services.Pipewire
import qs.config
import qs.components

// Default sink volume control.
// Left click = audio panel · middle click = mute · wheel = ±5%.
BarButton {
    id: root

    popoutId: "audio"
    implicitWidth: icon.implicitWidth + 14
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    readonly property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property real volume: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false

    function volumeIcon(): string {
        if (muted || volume <= 0.001) return Icons.volumeMute;
        if (AudioPort.headphones) return Icons.headphones;
        if (volume < 0.34) return Icons.volumeLow;
        if (volume < 0.67) return Icons.volumeMedium;
        return Icons.volumeHigh;
    }

    onClicked: (mouse) => {
        if (mouse.button === Qt.MiddleButton) Osd.toggleMute();
        else Ui.togglePopout("audio");
    }

    onWheeled: (wheel) => Osd.applyVolume(wheel.angleDelta.y > 0 ? Osd.volumeStep : -Osd.volumeStep)

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.volumeIcon()
        color: root.muted ? Theme.overlay0 : Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.iconSize + 2
    }
}
