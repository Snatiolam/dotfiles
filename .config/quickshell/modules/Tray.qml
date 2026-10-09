import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.config

// System tray (StatusNotifierItems).
Row {
    id: root

    spacing: 2

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: cell

            required property var modelData

            width: 22
            height: 22

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
                source: cell.modelData.icon
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                // Many tray apps (nm-applet, appindicators) expose a menu but do
                // not implement Activate, so prefer the menu when one exists.
                onClicked: (mouse) => {
                    if (mouse.button === Qt.MiddleButton) {
                        cell.modelData.secondaryActivate();
                    } else if (cell.modelData.hasMenu) {
                        menuAnchor.open();
                    } else if (mouse.button === Qt.LeftButton) {
                        cell.modelData.activate();
                    }
                }

                onWheel: (wheel) => cell.modelData.scroll(wheel.angleDelta.y, false)
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: cell.modelData.menu
                anchor.window: cell.QsWindow.window
                anchor.item: cell
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
                anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            }
        }
    }
}
