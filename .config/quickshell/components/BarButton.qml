import QtQuick
import Quickshell
import qs.config

// Bar button with a hover/open background; emits clicked(mouse) and wheeled(wheel).
Item {
    id: root

    property string popoutId: ""
    property color activeColor: Theme.hover
    property int acceptedButtons: Qt.LeftButton

    readonly property alias hovered: hover.hovered
    readonly property string screenName: QsWindow.window ? QsWindow.window.screen.name : ""
    readonly property bool open: popoutId !== "" && Ui.isPopoutOpenOn(popoutId, screenName)

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
