import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config

// macOS-style "Playback" tile: shows the current track (or "Not playing"),
// with play/pause + next controls.
Rectangle {
    id: t

    property var _player: null
    readonly property var player: t._player
    readonly property bool playing: !!t.player && t.player.isPlaying

    implicitHeight: 144
    radius: 14
    color: t.playing ? Theme.tint(Theme.mauve, 0.18) : Theme.surface0
    border.width: t.playing ? 1 : 0
    border.color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.5)

    function refreshPlayers(): void {
        const arr = Mpris.players.values;
        let best = null;
        for (let i = 0; i < arr.length; i++) {
            if (arr[i].isPlaying) { best = arr[i]; break; }
        }
        if (!best && arr.length > 0) best = arr[0];
        t._player = best;
    }

    Timer {
        interval: 1000
        running: true
        triggeredOnStart: true
        onTriggered: t.refreshPlayers()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7

        // Top row: status + controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 34
                height: 34
                radius: 10
                color: Theme.surface1
                clip: true
                Layout.alignment: Qt.AlignVCenter

                Image {
                    anchors.fill: parent
                    source: t.player && t.player.trackArtUrl ? t.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                }

                Text {
                    anchors.centerIn: parent
                    visible: !(t.player && t.player.trackArtUrl)
                    text: Icons.music
                    color: t.playing ? Theme.mauve : Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 15
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Rectangle {
                width: 26
                height: 26
                radius: 13
                color: t.playing ? Theme.mauve : Theme.surface1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: t.playing ? Icons.pause : Icons.play
                    color: t.playing ? Theme.base : Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (t.player && t.player.canTogglePlaying)
                            t.player.togglePlaying();
                    }
                }
            }

            Text {
                text: Icons.forward
                color: (t.player && t.player.canGoNext)
                       ? Theme.text : Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (t.player) t.player.next(); }
                }
            }
        }

        // Title
        Text {
            Layout.fillWidth: true
            text: t.playing
                  ? (t.player.trackTitle || "Unknown track")
                  : "Not playing"
            color: t.playing ? Theme.text : Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
        }

        // Artist / hint
        Text {
            Layout.fillWidth: true
            text: t.playing
                  ? (t.player.trackArtist || t.player.trackAlbum || t.player.identity || "")
                  : "No reproduction"
            visible: text !== ""
            color: t.playing ? Theme.subtext0 : Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }
}