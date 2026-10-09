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
                onClicked: cell.modelData.activate()
                onWheel: (wheel) => cell.modelData.scroll(wheel.angleDelta.y, false)
            }
        }
    }
}
