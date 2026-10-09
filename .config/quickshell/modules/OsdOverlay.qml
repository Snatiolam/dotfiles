import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// Floating OSD centered at the bottom. Shown on volume/brightness changes.
PanelWindow {
    id: win

    anchors.bottom: true
    margins.bottom: 56
    exclusiveZone: 0
    aboveWindows: true
    focusable: false
    color: "transparent"
    visible: Osd.visible

    implicitWidth: 280
    implicitHeight: 66

    readonly property string osdIcon: {
        if (Osd.kind === "brightness") return Icons.brightness;
        if (Osd.muted || Osd.value <= 0.001) return Icons.volumeMute;
        if (Osd.value < 0.34) return Icons.volumeLow;
        if (Osd.value < 0.67) return Icons.volumeMedium;
        return Icons.volumeHigh;
    }

    readonly property string osdLabel: {
        if (Osd.kind === "brightness") return "Brightness";
        return Osd.muted ? "Muted" : "Volume";
    }

    // Pastel accent: warm yellow for brightness, mauve for volume.
    readonly property color osdAccent: (Osd.kind === "brightness")
        ? Theme.yellow : Theme.mauve

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 18
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        NumberAnimation on opacity {
            running: win.visible
            from: 0
            to: 1
            duration: 140
            easing.type: Easing.OutCubic
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Text {
                text: win.osdIcon
                color: Osd.muted ? Theme.overlay0 : win.osdAccent
                font.family: Theme.font
                font.pixelSize: 24
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: win.osdLabel
                        color: Theme.subtext1
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round(Osd.value * 100) + "%"
                        color: Theme.subtext0
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 7
                    radius: 4
                    color: Theme.surface0

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * (Osd.muted ? 0 : Osd.value)
                        radius: 4
                        color: Osd.muted ? Theme.overlay0 : win.osdAccent
                        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
            }
        }
    }
}
