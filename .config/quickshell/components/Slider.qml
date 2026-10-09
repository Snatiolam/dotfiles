import QtQuick
import qs.config

// Horizontal slider 0..1. Does not mutate its own `value`: emits `moved(v)`.
Item {
    id: root

    property real value: 0
    property color accent: Theme.accent

    signal moved(real v)

    implicitHeight: 20

    function _apply(px): void {
        const w = track.width;
        if (w <= 0) return;
        root.moved(Math.max(0, Math.min(1, px / w)));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.track
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: track.width * Math.max(0, Math.min(1, root.value))
        height: 6
        radius: 3
        color: root.accent
        Behavior on width {
            enabled: !mouse.pressed
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        width: 13
        height: 13
        radius: 6.5
        color: Theme.text
        border.width: 2
        border.color: Theme.base
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(track.width - width,
                                track.width * Math.max(0, Math.min(1, root.value)) - width / 2))
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: (m) => root._apply(m.x)
        onPositionChanged: (m) => { if (pressed) root._apply(m.x); }
        onWheel: (w) => root.moved(Math.max(0, Math.min(1,
                       root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
