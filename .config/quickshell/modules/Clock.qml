import QtQuick
import Quickshell
import qs.config

// Center clock: bold time + subtle date. Click opens the calendar.
Item {
    id: root

    implicitWidth: row.implicitWidth + 16
    implicitHeight: Theme.barHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "calendar") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
            font.bold: true
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 3
            radius: 2
            color: Theme.overlay0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "ddd d MMM", Qt.locale("en_US"))
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 12
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("calendar")
    }
}