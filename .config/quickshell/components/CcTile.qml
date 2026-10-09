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

    implicitHeight: t.pill ? 48 : 68
    radius: t.pill ? 22 : 14
    color: t.on ? Theme.tint(t.accent, 0.26) : Theme.surface0
    border.width: t.on ? 1 : 0
    border.color: Qt.rgba(t.accent.r, t.accent.g, t.accent.b, 0.6)
    opacity: t.disabled ? 0.45 : 1
    Behavior on color { ColorAnimation { duration: 120 } }

    // Pill layout: icon + label on top, state/sublabel underneath.
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        spacing: 1
        visible: t.pill

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: t.tileIcon
                color: t.on ? t.accent : Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: t.label
                elide: Text.ElideRight
                color: t.on ? Theme.text : Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: true
            }
        }

        Text {
            Layout.fillWidth: true
            visible: t.sublabel !== ""
            text: t.sublabel
            elide: Text.ElideRight
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