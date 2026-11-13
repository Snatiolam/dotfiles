import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config

// Playback tile: current track with play/pause and next controls.
Rectangle {
    id: t

    // Re-evaluates when players appear or change state, so no polling is needed.
    readonly property var player: {
        const arr = Mpris.players.values;
        let best = null;
        for (let i = 0; i < arr.length; i++) {
            if (arr[i].isPlaying) { best = arr[i]; break; }
        }
        if (!best && arr.length > 0) best = arr[0];
        return best;
    }
    readonly property bool playing: !!t.player && t.player.isPlaying

    implicitHeight: 144
    radius: 14
    color: t.playing ? Theme.tint(Theme.mauve, 0.18) : Theme.surface0
    border.width: t.playing ? 1 : 0
    border.color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.5)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7

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

            Text {
                text: Icons.back
                color: (t.player && t.player.canGoPrevious)
                       ? Theme.text : Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (t.player) t.player.previous(); }
                }
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