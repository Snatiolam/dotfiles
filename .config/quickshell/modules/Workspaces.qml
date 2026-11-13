import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Dynamic workspaces: only occupied/active ones are shown, sorted by id.
Row {
    id: root

    spacing: 5

    function focusWorkspace(target): void {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ workspace = "${target}" })`]);
    }

    readonly property var list: {
        const out = [];
        const values = Hyprland.workspaces.values;
        for (let i = 0; i < values.length; i++) {
            const ws = values[i];
            if (ws.id > 0)
                out.push(ws);
        }
        out.sort((a, b) => a.id - b.id);
        return out;
    }

    Repeater {
        model: root.list

        delegate: Rectangle {
            id: chip

            required property var modelData

            readonly property bool isFocused: modelData.focused
            readonly property bool isActive: modelData.active

            width: isFocused ? 26 : 22
            height: 22
            radius: 7
            color: isFocused ? Theme.mauve
                 : isActive ? Theme.surface2
                 : hover.hovered ? Theme.hover
                 : Theme.surface0

            Behavior on color { ColorAnimation { duration: 160 } }
            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            Text {
                anchors.centerIn: parent
                text: chip.modelData.id
                color: chip.isFocused ? Theme.base : Theme.text
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: chip.isFocused
            }

            HoverHandler { id: hover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusWorkspace(chip.modelData.id)
                onWheel: (wheel) => root.focusWorkspace(wheel.angleDelta.y > 0 ? "e+1" : "e-1")
            }
        }
    }
}
