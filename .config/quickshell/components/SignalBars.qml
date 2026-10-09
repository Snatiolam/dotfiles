import QtQuick
import qs.config

// 4-bar signal indicator. `value` ranges from 0 to 1.
Row {
    id: root

    property real value: 0
    property color accent: Theme.text

    spacing: 2
    height: 13

    Repeater {
        model: 4

        delegate: Item {
            required property int index

            width: 3
            height: 13

            Rectangle {
                anchors.bottom: parent.bottom
                width: 3
                height: 4 + index * 3
                radius: 1
                color: Math.ceil(root.value * 4) > index
                    ? root.accent
                    : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.22)
            }
        }
    }
}
