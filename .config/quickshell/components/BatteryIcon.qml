import QtQuick
import qs.config

// macOS-style battery glyph: rounded body + terminal cap + fill level.
Item {
    id: root

    property real level: 1
    property bool charging: false
    property color fillColor: Theme.text
    property real bodyWidth: 22
    property real bodyHeight: 12
    property real borderWidth: 1.5
    property bool showPercent: false
    property real percentSize: 8

    readonly property real capWidth: 2
    readonly property real inset: borderWidth + 1
    readonly property color percentColor: (root.level >= 0.45) ? Theme.base : Theme.text

    implicitWidth: bodyWidth + capWidth
    implicitHeight: bodyHeight

    Rectangle {
        id: body
        width: root.bodyWidth
        height: root.bodyHeight
        radius: Math.min(4, root.bodyHeight / 3)
        color: "transparent"
        border.width: root.borderWidth
        border.color: root.fillColor
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: body.right
        width: root.capWidth
        height: Math.round(root.bodyHeight * 0.42)
        radius: root.capWidth / 2
        color: root.fillColor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.verticalCenter: body.verticalCenter
        anchors.left: body.left
        anchors.leftMargin: root.inset
        height: body.height - root.inset * 2
        radius: 2
        color: root.fillColor
        width: Math.max(0, Math.min(1, root.level)) * (body.width - root.inset * 2)
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Text {
        anchors.centerIn: body
        visible: root.showPercent && !root.charging
        text: Math.round(root.level * 100)
        color: root.percentColor
        font.family: Theme.font
        font.pixelSize: root.percentSize
        font.bold: true
    }

    Text {
        anchors.centerIn: body
        visible: root.charging
        text: Icons.charging
        color: Theme.base
        font.family: Theme.font
        font.pixelSize: Math.min(root.bodyHeight - 2, 12)
    }
}
