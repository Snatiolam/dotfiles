import QtQuick
import qs.config

// Minimal switch. Does not mutate its own state: reflects `checked`
// and notifies with `toggled()` so the parent updates the real state.
Item {
    id: root

    property bool checked: false
    property color accent: Theme.accent

    signal toggled()

    implicitWidth: 38
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.9)
            : Theme.surface1
        Behavior on color { ColorAnimation { duration: 140 } }
    }

    Rectangle {
        width: parent.height - 6
        height: parent.height - 6
        radius: height / 2
        color: root.checked ? Theme.base : Theme.overlay0
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
