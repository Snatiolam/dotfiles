import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// One audio direction (output or input): volume + mute row and a device picker.
// Reused by AudioPopup for both sinks and sources.
ColumnLayout {
    id: root

    required property string title
    required property string titleIcon
    required property color accent
    required property var nodes
    required property var currentNode

    property int glyphSize: 15
    property bool expanded: false

    signal selected(var node)

    readonly property var currentAudio: currentNode ? currentNode.audio : null

    function label(node): string {
        if (!node) return "No device";
        return node.description || node.nickname || node.name || "Device";
    }

    spacing: 10

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 7

        Text {
            text: root.titleIcon
            color: root.accent
            font.family: Theme.font
            font.pixelSize: 14
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            color: Theme.subtext1
            font.family: Theme.font
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            visible: root.currentNode !== null
            text: root.label(root.currentNode)
            color: Theme.overlay0
            font.family: Theme.font
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.maximumWidth: 150
        }
    }

    // Volume + mute
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: (root.currentAudio && root.currentAudio.muted) ? Icons.volumeMute : root.titleIcon
            color: (root.currentAudio && root.currentAudio.muted) ? Theme.overlay0 : Theme.text
            font.family: Theme.font
            font.pixelSize: root.glyphSize
            HoverHandler { cursorShape: Qt.PointingHandCursor }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.currentAudio) root.currentAudio.muted = !root.currentAudio.muted
            }
        }

        Slider {
            Layout.fillWidth: true
            value: root.currentAudio ? root.currentAudio.volume : 0
            accent: root.accent
            onMoved: (v) => {
                if (!root.currentAudio) return;
                root.currentAudio.volume = v;
                if (v > 0 && root.currentAudio.muted)
                    root.currentAudio.muted = false;
            }
        }

        Text {
            text: Math.round((root.currentAudio ? root.currentAudio.volume : 0) * 100) + "%"
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 11
            Layout.preferredWidth: 36
            horizontalAlignment: Text.AlignRight
        }
    }

    // Device selector
    Rectangle {
        Layout.fillWidth: true
        height: 28
        radius: Theme.controlRadius
        color: selHover.hovered ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: root.label(root.currentNode)
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            Text {
                text: root.expanded ? Icons.chevronUp : Icons.chevronDown
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 11
            }
        }

        HoverHandler { id: selHover }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // Device list
    ColumnLayout {
        Layout.fillWidth: true
        visible: root.expanded
        spacing: 3

        Repeater {
            model: root.nodes

            delegate: Rectangle {
                required property var modelData

                Layout.fillWidth: true
                height: 28
                radius: Theme.controlRadius
                color: devHover.hovered ? Theme.hover : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    Text {
                        width: 14
                        text: modelData === root.currentNode ? Icons.check : ""
                        color: Theme.green
                        font.family: Theme.font
                        font.pixelSize: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.label(modelData)
                        color: modelData === root.currentNode ? Theme.text : Theme.subtext0
                        font.family: Theme.font
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                HoverHandler { id: devHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selected(modelData);
                        root.expanded = false;
                    }
                }
            }
        }
    }
}
