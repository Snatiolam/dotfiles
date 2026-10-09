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

        AudioDeviceSection {
            Layout.fillWidth: true
            title: "Output"
            titleIcon: Icons.volumeHigh
            glyphSize: 16
            accent: Theme.mauve
            nodes: popup.outputs
            currentNode: popup.sink
            onSelected: (node) => Pipewire.preferredDefaultAudioSink = node
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.cardBorder
        }

        AudioDeviceSection {
            Layout.fillWidth: true
            title: "Input"
            titleIcon: Icons.microphone
            glyphSize: 14
            accent: Theme.teal
            nodes: popup.inputs
            currentNode: popup.source
            onSelected: (node) => Pipewire.preferredDefaultAudioSource = node
        }
    }
}
