import QtQuick
import Quickshell
import qs.config

// Control Center button (grid). Click opens the macOS-style panel.
Item {
    id: root

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "controlcenter") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: Icons.grid
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("controlcenter")
    }
}