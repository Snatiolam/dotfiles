import QtQuick
import Quickshell
import qs.config
import qs.components

// Center clock: bold time + subtle date. Click opens the calendar.
BarButton {
    id: root

    popoutId: "calendar"
    implicitWidth: row.implicitWidth + 16
    implicitHeight: Theme.barHeight

    onClicked: Ui.togglePopout("calendar")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.sky
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
            text: {
                const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                return days[clock.date.getDay()] + " " + clock.date.getDate()
                       + " " + months[clock.date.getMonth()];
            }
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 12
        }
    }
}
