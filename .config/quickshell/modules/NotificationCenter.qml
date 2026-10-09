import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// Notification center: list of active notifications.
PanelWindow {
    id: win

    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + 8
    margins.right: 10

    exclusiveZone: 0
    aboveWindows: true
    focusable: true
    color: "transparent"
    visible: Ui.notifCenter

    implicitWidth: 360
    implicitHeight: Notifs.count === 0 ? 108 : Math.min(460, 66 + Notifs.count * 96)

    Shortcut {
        sequence: "Escape"
        enabled: Ui.notifCenter
        onActivated: Ui.closeAll()
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 13
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    visible: Notifs.count > 0
                    text: "Clear"
                    color: clearHover.hovered ? Theme.red : Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 11
                    HoverHandler { id: clearHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clearAll()
                    }
                }

                Text {
                    text: Icons.close
                    color: closeHover.hovered ? Theme.text : Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 13
                    HoverHandler { id: closeHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Ui.closeAll()
                    }
                }
            }

            // Empty state
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: Notifs.count === 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "No notifications"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }

            // List
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: Notifs.count > 0
                clip: true
                spacing: 8
                model: Notifs.server.trackedNotifications
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: item

                    required property var modelData

                    width: ListView.view.width
                    height: Math.max(72, content.implicitHeight + 20)
                    radius: 12
                    color: itemHover.hovered ? Theme.surface0 : Theme.base

                    Behavior on color { ColorAnimation { duration: 120 } }

                    HoverHandler { id: itemHover }

                    ColumnLayout {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: item.modelData.appName || "Application"
                                color: Theme.mauve
                                font.family: Theme.font
                                font.pixelSize: 11
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Icons.close
                                color: itemClose.hovered ? Theme.red : Theme.overlay0
                                font.family: Theme.font
                                font.pixelSize: 11
                                HoverHandler { id: itemClose }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: item.modelData.dismiss()
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: item.modelData.summary || ""
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: item.modelData.body || ""
                            color: Theme.subtext0
                            font.family: Theme.font
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }
}
