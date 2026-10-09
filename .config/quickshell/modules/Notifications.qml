import QtQuick
import Quickshell
import qs.config

// Bell with counter. Click = toggle the notification center.
Item {
    id: root

    implicitWidth: 26
    implicitHeight: 26

    readonly property bool hasNotifs: Notifs.count > 0
    readonly property color bellColor: hasNotifs ? Theme.bellActive : Theme.bellIdle

    // Soft pastel halo behind the bell while there are pending notifications.
    Rectangle {
        anchors.centerIn: parent
        width: 22
        height: 22
        radius: 11
        color: Theme.tint(Theme.bellActive, 0.22)
        visible: root.hasNotifs
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.notifCenter)
            ? Theme.tint(root.bellColor, 0.18)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: Icons.bell
        color: root.bellColor
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        Behavior on color { ColorAnimation { duration: 160 } }
    }

    // Counter badge
    Rectangle {
        visible: root.hasNotifs
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 1
        anchors.topMargin: 1
        width: Math.max(14, badgeText.implicitWidth + 6)
        height: 14
        radius: 7
        color: Theme.red

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: Notifs.count
            color: Theme.crust
            font.family: Theme.font
            font.pixelSize: 9
            font.bold: true
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.toggleNotifCenter()
    }
}
