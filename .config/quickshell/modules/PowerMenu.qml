import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// Centered power menu. Closes on click outside or Escape.
PanelWindow {
    id: win

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusiveZone: 0
    aboveWindows: true
    focusable: true
    color: "transparent"
    visible: Ui.powerMenu

    // Closes on click outside the card
    MouseArea {
        anchors.fill: parent
        onClicked: Ui.closeAll()
    }

    Shortcut {
        sequence: "Escape"
        enabled: Ui.powerMenu
        onActivated: Ui.closeAll()
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        implicitWidth: buttons.implicitWidth + 40
        implicitHeight: 150
        radius: 20
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        // Absorbs clicks inside the card
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 14

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Power"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
            }

            Row {
                id: buttons
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                component PowerItem: Column {
                    required property string glyph
                    required property string label
                    required property color accent
                    required property var action

                    spacing: 6
                    width: 66

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 50
                        height: 50
                        radius: 14
                        color: hov.hovered
                            ? Qt.rgba(accent.r, accent.g, accent.b, 0.25)
                            : Theme.surface0
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.glyph
                            color: parent.parent.accent
                            font.family: Theme.font
                            font.pixelSize: 20
                        }

                        HoverHandler { id: hov }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                parent.parent.action();
                                Ui.closeAll();
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.label
                        color: Theme.subtext0
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }

                PowerItem {
                    glyph: Icons.lock
                    label: "Lock"
                    accent: Theme.text
                    action: () => Quickshell.execDetached(["loginctl", "lock-session"])
                }
                PowerItem {
                    glyph: Icons.logout
                    label: "Log out"
                    accent: Theme.peach
                    action: () => Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                }
                PowerItem {
                    glyph: Icons.moon
                    label: "Suspend"
                    accent: Theme.blue
                    action: () => Quickshell.execDetached(["systemctl", "suspend"])
                }
                PowerItem {
                    glyph: Icons.reboot
                    label: "Restart"
                    accent: Theme.yellow
                    action: () => Quickshell.execDetached(["systemctl", "reboot"])
                }
                PowerItem {
                    glyph: Icons.power
                    label: "Shut down"
                    accent: Theme.red
                    action: () => Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }
        }
    }
}
