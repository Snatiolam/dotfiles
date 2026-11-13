import QtQuick
import qs.config

// Circular power-menu action with an accent glow and scale lift on hover.
Item {
    id: item

    required property string glyph
    required property string label
    required property color accent
    required property var action

    implicitHeight: 104

    Rectangle {
        id: disc
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 64
        height: 64
        radius: 32
        color: area.containsMouse
            ? Theme.tint(item.accent, 0.26)
            : Qt.rgba(1, 1, 1, 0.055)
        border.width: 1
        border.color: area.containsMouse
            ? Theme.tint(item.accent, 0.58)
            : Qt.rgba(1, 1, 1, 0.09)
        scale: area.containsMouse ? 1.07 : 1.0
        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Text {
            anchors.centerIn: parent
            text: item.glyph
            color: area.containsMouse ? item.accent : Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 25
            Behavior on color { ColorAnimation { duration: 140 } }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: disc.bottom
        anchors.topMargin: 12
        text: item.label
        color: area.containsMouse ? Theme.text : Theme.subtext0
        font.family: Theme.font
        font.pixelSize: 12
        font.weight: Font.Medium
        Behavior on color { ColorAnimation { duration: 140 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            item.action();
            Ui.closePopout();
        }
    }
}
