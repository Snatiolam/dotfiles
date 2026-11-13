import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// Centered session menu, macOS-style: dimmed backdrop, frosted card and a
// row of large circular actions. Closes on click outside or Escape.
PanelWindow {
    id: win

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Cover the whole output, including the bar's reserved strip, so the
    // backdrop dims everything and the card is truly centered.
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true
    color: "transparent"
    visible: Ui.powerMenu

    // ── Backdrop ──────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#08090f"
        opacity: win.visible ? 0.52 : 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Closes on click outside the card
        MouseArea {
            anchors.fill: parent
            onClicked: Ui.closePopout()
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: Ui.powerMenu
        onActivated: Ui.closePopout()
    }

    // ── Card ──────────────────────────────────────────────────────
    Item {
        id: stack
        anchors.centerIn: parent
        width: 520
        height: 252

        scale: win.visible ? 1 : 0.96
        opacity: win.visible ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        // Soft ambient shadow: two stacked rings give a cheap blur-like falloff
        // without needing an extra effect pass on the layer surface.
        Rectangle {
            anchors.fill: card
            anchors.topMargin: -8
            anchors.leftMargin: -14
            anchors.rightMargin: -14
            anchors.bottomMargin: -22
            radius: card.radius + 14
            color: Qt.rgba(0, 0, 0, 0.28)
        }
        Rectangle {
            anchors.fill: card
            anchors.topMargin: -3
            anchors.leftMargin: -5
            anchors.rightMargin: -5
            anchors.bottomMargin: -10
            radius: card.radius + 5
            color: Qt.rgba(0, 0, 0, 0.35)
        }

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 30
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.09)

            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.tint(Theme.base, 0.97) }
                GradientStop { position: 1.0; color: Theme.tint(Theme.crust, 0.985) }
            }

            // Absorbs clicks inside the card
            MouseArea { anchors.fill: parent }

            // Glassy top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 1
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.62
                height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.16) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // ── Header ────────────────────────────────────────────
            RowLayout {
                id: header
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 26
                anchors.rightMargin: 22
                anchors.topMargin: 22
                spacing: 10

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Power"
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 21
                        font.bold: true
                    }

                    Text {
                        text: "Session options"
                        color: Theme.overlay1
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    width: 28
                    height: 28
                    radius: 14
                    color: closeArea.containsMouse
                        ? Theme.tint(Theme.surface1, 0.9)
                        : Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: closeArea.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.12)
                        : Qt.rgba(1, 1, 1, 0.06)
                    Behavior on color { ColorAnimation { duration: 130 } }
                    Behavior on border.color { ColorAnimation { duration: 130 } }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.close
                        color: closeArea.containsMouse ? Theme.text : Theme.overlay1
                        font.family: Theme.font
                        font.pixelSize: 11
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Ui.closePopout()
                    }
                }
            }

            // ── Divider ───────────────────────────────────────────
            Rectangle {
                id: divider
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.leftMargin: 26
                anchors.rightMargin: 26
                anchors.topMargin: 16
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // ── Actions ───────────────────────────────────────────
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: divider.bottom
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                anchors.topMargin: 20
                spacing: 4

                PowerAction {
                    Layout.fillWidth: true
                    glyph: Icons.lock
                    label: "Lock"
                    accent: Theme.sapphire
                    action: () => Quickshell.execDetached(["loginctl", "lock-session"])
                }
                // Hyprland 0.57 Lua config: legacy `hyprctl dispatch exit` is
                // rejected, so use the Lua dispatcher form.
                PowerAction {
                    Layout.fillWidth: true
                    glyph: Icons.logout
                    label: "Log out"
                    accent: Theme.peach
                    action: () => Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"])
                }
                PowerAction {
                    Layout.fillWidth: true
                    glyph: Icons.moon
                    label: "Suspend"
                    accent: Theme.mauve
                    action: () => Quickshell.execDetached(["systemctl", "suspend"])
                }
                PowerAction {
                    Layout.fillWidth: true
                    glyph: Icons.reboot
                    label: "Restart"
                    accent: Theme.green
                    action: () => Quickshell.execDetached(["systemctl", "reboot"])
                }
                PowerAction {
                    Layout.fillWidth: true
                    glyph: Icons.power
                    label: "Shut down"
                    accent: Theme.red
                    action: () => Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }

            // ── Footer hint ───────────────────────────────────────
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 13
                spacing: 6

                Rectangle {
                    width: 27
                    height: 18
                    radius: 5
                    color: Theme.tint(Theme.surface0, 0.7)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)

                    Text {
                        anchors.centerIn: parent
                        text: "Esc"
                        color: Theme.overlay1
                        font.family: Theme.font
                        font.pixelSize: 9
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "to close"
                    color: Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 10
                }
            }
        }
    }
}
