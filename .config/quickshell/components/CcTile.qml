import QtQuick
import QtQuick.Layouts
import qs.config

// macOS-style quick-toggle tile. `pill: true` renders a full-width
// rounded pill (optionally showing a network/app name in `sublabel`).
Rectangle {
    id: t

    property string tileIcon: ""
    property string label: ""
    property string sublabel: ""
    property bool on: false
    property color accent: Theme.accent
    property bool disabled: false
    property bool pill: false

    signal clicked()

    implicitHeight: t.pill ? 44 : 68
    radius: t.pill ? 22 : 14
    color: t.on ? Theme.tint(t.accent, 0.26) : Theme.surface0
    border.width: t.on ? 1 : 0
    border.color: Qt.rgba(t.accent.r, t.accent.g, t.accent.b, 0.6)
    opacity: t.disabled ? 0.45 : 1
    Behavior on color { ColorAnimation { duration: 120 } }

    // Pill layout (full-width, horizontal).
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10
        visible: t.pill

        Text {
            text: t.tileIcon
            color: t.on ? t.accent : Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 15
        }

        Text {
            Layout.fillWidth: true
            text: t.label
            color: t.on ? Theme.text : Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            visible: t.sublabel !== ""
            text: t.sublabel
            color: t.on ? Theme.subtext0 : Theme.overlay0
            font.family: Theme.font
            font.pixelSize: 10
        }
    }

    // Square layout (icon + label stacked).
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5
        visible: !t.pill

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: t.tileIcon
            color: t.on ? t.accent : Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 17
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: t.label
            color: t.on ? Theme.text : Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 10
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: t.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !t.disabled
        onClicked: t.clicked()
    }
}