import QtQuick
import qs.config

// Shared bar button: hover/open background + a single MouseArea.
// Widgets declare their glyphs directly as children; `popoutId` links the
// highlight to the popup controlled by Ui.popout, and `clicked(mouse)` /
// `wheeled(wheel)` report interaction.
Item {
    id: root

    property string popoutId: ""
    property color activeColor: Theme.hover
    property int acceptedButtons: Qt.LeftButton

    readonly property alias hovered: hover.hovered
    readonly property bool open: popoutId !== "" && Ui.popout === popoutId

    signal clicked(var mouse)
    signal wheeled(var wheel)

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        z: -1
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (root.hovered || root.open) ? root.activeColor : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: root.acceptedButtons
        onClicked: (mouse) => root.clicked(mouse)
        onWheel: (wheel) => root.wheeled(wheel)
    }
}
