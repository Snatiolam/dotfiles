import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.config
import qs.components

// Audio panel: device selection (output/input) + volume + mute.
AnchoredPopup {
    id: popup

    popoutId: "audio"

    implicitWidth: 350
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property bool outputOpen: false
    property bool inputOpen: false

    function collectNodes(isSink): var {
        const out = [];
        const arr = Pipewire.nodes.values;
        for (let i = 0; i < arr.length; i++) {
            const n = arr[i];
            if (n.isStream || !n.audio) continue;
            if (isSink ? n.isSink : !n.isSink) out.push(n);
        }
        out.sort((a, b) => popup._label(a).localeCompare(popup._label(b)));
        return out;
    }

    function _label(node): string {
        if (!node) return "Device";
        return node.description || node.nickname || node.name || "Device";
    }

    readonly property var outputs: collectNodes(true)
    readonly property var inputs: collectNodes(false)

    PwObjectTracker { objects: popup.outputs.concat(popup.inputs) }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        // ══ Output ══════════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                text: Icons.volumeHigh
                color: Theme.mauve
                font.family: Theme.font
                font.pixelSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: "Output"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                visible: popup.sink !== null
                text: popup.sink ? popup._label(popup.sink) : ""
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: (popup.sink && popup.sink.audio && popup.sink.audio.muted)
                      ? Icons.volumeMute : Icons.volumeHigh
                color: (popup.sink && popup.sink.audio && popup.sink.audio.muted)
                       ? Theme.overlay0 : Theme.text
                font.family: Theme.font
                font.pixelSize: 16
                HoverHandler { cursorShape: Qt.PointingHandCursor }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.sink && popup.sink.audio)
                            popup.sink.audio.muted = !popup.sink.audio.muted;
                    }
                }
            }

            Slider {
                Layout.fillWidth: true
                value: (popup.sink && popup.sink.audio) ? popup.sink.audio.volume : 0
                accent: Theme.mauve
                onMoved: (v) => {
                    if (popup.sink && popup.sink.audio) {
                        popup.sink.audio.volume = v;
                        if (v > 0 && popup.sink.audio.muted)
                            popup.sink.audio.muted = false;
                    }
                }
            }

            Text {
                text: Math.round((popup.sink && popup.sink.audio ? popup.sink.audio.volume : 0) * 100) + "%"
                color: Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 11
                Layout.preferredWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }

        // Output device selector
        Rectangle {
            Layout.fillWidth: true
            height: 28
            radius: Theme.controlRadius
            color: outSelectHover.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: popup.sink ? popup._label(popup.sink) : "No device"
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    text: popup.outputOpen ? Icons.chevronUp : Icons.chevronDown
                    color: Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 11
                }
            }

            HoverHandler { id: outSelectHover }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.outputOpen = !popup.outputOpen
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: popup.outputOpen
            spacing: 3

            Repeater {
                model: popup.outputs
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
                            text: modelData === Pipewire.defaultAudioSink ? Icons.check : ""
                            color: Theme.green
                            font.family: Theme.font
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: popup._label(modelData)
                            color: modelData === Pipewire.defaultAudioSink ? Theme.text : Theme.subtext0
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
                            Pipewire.preferredDefaultAudioSink = modelData;
                            popup.outputOpen = false;
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.cardBorder
        }

        // ══ Input ═══════════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                text: Icons.microphone
                color: Theme.teal
                font.family: Theme.font
                font.pixelSize: 13
            }

            Text {
                Layout.fillWidth: true
                text: "Input"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                visible: popup.source !== null
                text: popup.source ? popup._label(popup.source) : ""
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: (popup.source && popup.source.audio && popup.source.audio.muted)
                      ? Icons.volumeMute : Icons.microphone
                color: (popup.source && popup.source.audio && popup.source.audio.muted)
                       ? Theme.overlay0 : Theme.text
                font.family: Theme.font
                font.pixelSize: 14
                HoverHandler { cursorShape: Qt.PointingHandCursor }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.source && popup.source.audio)
                            popup.source.audio.muted = !popup.source.audio.muted;
                    }
                }
            }

            Slider {
                Layout.fillWidth: true
                value: (popup.source && popup.source.audio) ? popup.source.audio.volume : 0
                accent: Theme.teal
                onMoved: (v) => {
                    if (popup.source && popup.source.audio) {
                        popup.source.audio.volume = v;
                        if (v > 0 && popup.source.audio.muted)
                            popup.source.audio.muted = false;
                    }
                }
            }

            Text {
                text: Math.round((popup.source && popup.source.audio ? popup.source.audio.volume : 0) * 100) + "%"
                color: Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 11
                Layout.preferredWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 28
            radius: Theme.controlRadius
            color: inSelectHover.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: popup.source ? popup._label(popup.source) : "No device"
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    text: popup.inputOpen ? Icons.chevronUp : Icons.chevronDown
                    color: Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 11
                }
            }

            HoverHandler { id: inSelectHover }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.inputOpen = !popup.inputOpen
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: popup.inputOpen
            spacing: 3

            Repeater {
                model: popup.inputs
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.controlRadius
                    color: inDevHover.hovered ? Theme.hover : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            width: 14
                            text: modelData === Pipewire.defaultAudioSource ? Icons.check : ""
                            color: Theme.green
                            font.family: Theme.font
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: popup._label(modelData)
                            color: modelData === Pipewire.defaultAudioSource ? Theme.text : Theme.subtext0
                            font.family: Theme.font
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    HoverHandler { id: inDevHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Pipewire.preferredDefaultAudioSource = modelData;
                            popup.inputOpen = false;
                        }
                    }
                }
            }
        }
    }
}