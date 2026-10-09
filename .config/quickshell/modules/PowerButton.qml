import QtQuick
import Quickshell
import qs.config

// Power button: opens the centered menu.
Item {
    id: root

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.powerMenu)
            ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.22)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: Icons.power
        color: Ui.powerMenu ? Theme.red : Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePowerMenu()
    }
}
