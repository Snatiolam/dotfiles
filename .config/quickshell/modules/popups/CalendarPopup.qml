import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// Month calendar, anchored to the clock.
AnchoredPopup {
    id: popup

    popoutId: "calendar"

    implicitWidth: 300
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    property int monthOffset: 0

    readonly property date today: new Date()
    readonly property date shownMonth: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
    readonly property int daysInMonth: new Date(shownMonth.getFullYear(), shownMonth.getMonth() + 1, 0).getDate()
    // Week starting on Monday (0 = Monday).
    readonly property int firstWeekday: (new Date(shownMonth.getFullYear(), shownMonth.getMonth(), 1).getDay() + 6) % 7

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var weekdayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    readonly property var weekdayFull: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    function isToday(day): bool {
        return day >= 1 && day <= daysInMonth
            && day === today.getDate()
            && shownMonth.getMonth() === today.getMonth()
            && shownMonth.getFullYear() === today.getFullYear();
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        // ── Header: month/year + navigation ───────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: popup.monthNames[popup.shownMonth.getMonth()] + " " + popup.shownMonth.getFullYear()
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
                font.bold: true
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }

            Text {
                text: "Today"
                color: hoyHover.hovered ? Theme.mauve : Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 11
                HoverHandler { id: hoyHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.monthOffset = 0
                }
            }

            Rectangle {
                width: 26
                height: 26
                radius: Theme.controlRadius
                color: prevHover.hovered ? Theme.hover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: Icons.chevronLeft
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 12
                }
                HoverHandler { id: prevHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.monthOffset--
                }
            }

            Rectangle {
                width: 26
                height: 26
                radius: Theme.controlRadius
                color: nextHover.hovered ? Theme.hover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: Icons.chevronRight
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 12
                }
                HoverHandler { id: nextHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.monthOffset++
                }
            }
        }

        // ── Weekday row ───────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: popup.weekdayNames
                delegate: Text {
                    required property string modelData
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        // ── Month grid ────────────────────────────────────────────
        Grid {
            id: grid
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 0

            readonly property real cellW: width / 7

            Repeater {
                model: 42

                delegate: Item {
                    // index goes from 0 to 41.
                    readonly property int day: index - popup.firstWeekday + 1
                    readonly property bool inMonth: day >= 1 && day <= popup.daysInMonth
                    readonly property bool today: popup.isToday(day)

                    width: grid.cellW
                    height: 34
                    implicitWidth: grid.cellW
                    implicitHeight: 34

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        visible: today
                        color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.20)
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        visible: dayHover.hovered && inMonth && !today
                        color: Theme.hover
                    }

                    Text {
                        anchors.centerIn: parent
                        text: inMonth ? day : ""
                        color: today ? Theme.mauve
                             : inMonth ? Theme.text
                             : "transparent"
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.bold: today
                    }

                    HoverHandler { id: dayHover }
                }
            }
        }

        // ── Footer: full date ─────────────────────────────────────
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: popup.weekdayFull[popup.today.getDay()]
                  + ", " + popup.today.getDate() + " "
                  + popup.monthNames[popup.today.getMonth()] + " "
                  + popup.today.getFullYear()
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 11
        }
    }
}
