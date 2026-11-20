import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config

// Searchable list overlay: clipboard history and the keybinding cheat sheet.
// `qs ipc call picker toggle clipboard|keybinds`.
PanelWindow {
    id: win

    screen: Ui.overlayScreen

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusiveZone: 0
    aboveWindows: true
    focusable: true
    color: "transparent"
    visible: Ui.picker !== ""

    property var items: []
    property string query: ""
    property int sel: 0

    readonly property var modes: ({
        clipboard: {
            placeholder: "Search clipboard…  (Shift+Del removes)",
            command: [clipboardScript, "list"],
            parse: parseClipboard,
            choose: copyEntry,
            remove: deleteEntry,
        },
        keybinds: {
            placeholder: "Search keybindings…",
            command: ["hyprctl", "binds", "-j"],
            parse: parseKeybinds,
            choose: null,
        },
    })
    readonly property var mode: modes[Ui.picker] || modes.clipboard
    readonly property string clipboardScript: Quickshell.shellDir + "/scripts/clipboard.sh"

    readonly property var shown: {
        const words = query.toLowerCase().split(/\s+/).filter(w => w !== "");
        return items.filter(item => {
            const text = (item.title + " " + item.hint).toLowerCase();
            return words.every(w => text.includes(w));
        });
    }

    function parseClipboard(text: string): var {
        return text.split("\n").filter(l => l !== "").map(line => {
            const tab = line.indexOf("\t");
            return { title: line.slice(tab + 1), hint: "", id: line.slice(0, tab) };
        });
    }

    function keyName(bind: var): string {
        const mods = [[64, "SUPER"], [4, "CTRL"], [8, "ALT"], [1, "SHIFT"]]
            .filter(m => bind.modmask & m[0]).map(m => m[1]);
        return mods.concat(bind.key).join(" + ");
    }

    function parseKeybinds(text: string): var {
        return JSON.parse(text).filter(b => b.has_description)
            .map(b => ({ title: b.description, hint: keyName(b), id: "" }));
    }

    function copyEntry(item: var): void {
        Quickshell.execDetached(["sh", "-c", '"$1" decode "$2" | wl-copy', "sh", clipboardScript, item.id]);
    }

    function deleteEntry(item: var): void {
        Quickshell.execDetached(["sh", "-c", 'printf "%s\t\n" "$2" | "$1" delete', "sh", clipboardScript, item.id]);
        items = items.filter(i => i !== item);
    }

    function remove(i: int): void {
        const item = shown[i];
        if (item && mode.remove) mode.remove(item);
        sel = Math.min(sel, shown.length - 1);
    }

    function choose(i: int): void {
        const item = shown[i];
        if (item && mode.choose) mode.choose(item);
        Ui.closePicker();
    }

    function move(step: int): void {
        if (shown.length > 0) sel = (sel + step + shown.length) % shown.length;
    }

    Process {
        id: source
        command: win.mode.command
        stdout: StdioCollector {
            onStreamFinished: win.items = win.mode.parse(this.text || "")
        }
    }

    onVisibleChanged: {
        if (!visible) return;
        field.text = "";
        items = [];
        source.running = true;
        Qt.callLater(() => field.forceActiveFocus());
    }

    onQueryChanged: sel = 0
    onSelChanged: list.positionViewAtIndex(sel, ListView.Contain)

    MouseArea {
        anchors.fill: parent
        onClicked: Ui.closePicker()
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.14
        width: 560
        implicitHeight: col.implicitHeight + 24
        radius: 24
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 54
                radius: 16
                color: Theme.surface0
                border.width: 1
                border.color: field.activeFocus ? Theme.tint(Theme.mauve, 0.6) : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: Icons.search
                        color: Theme.mauve
                        font.family: Theme.font
                        font.pixelSize: 18
                    }

                    TextInput {
                        id: field
                        Layout.fillWidth: true
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 16
                        clip: true
                        selectionColor: Theme.tint(Theme.mauve, 0.5)
                        selectedTextColor: Theme.text

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: field.text === ""
                            text: win.mode.placeholder
                            color: Theme.overlay0
                            font: field.font
                        }

                        onTextChanged: win.query = text

                        Keys.onUpPressed: function(event) { win.move(-1); event.accepted = true; }
                        Keys.onDownPressed: function(event) { win.move(1); event.accepted = true; }
                        Keys.onReturnPressed: function(event) { win.choose(win.sel); event.accepted = true; }
                        Keys.onDeletePressed: function(event) {
                            if (event.modifiers & Qt.ShiftModifier) win.remove(win.sel);
                            event.accepted = (event.modifiers & Qt.ShiftModifier) !== 0;
                        }
                        Keys.onEscapePressed: function(event) { Ui.closePicker(); event.accepted = true; }
                        Keys.onTabPressed: function(event) { event.accepted = true; }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: win.shown.length === 0
                text: win.query === "" ? "Nothing here yet" : "No results"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 13
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 400)
                visible: win.shown.length > 0
                model: win.shown
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 44
                    radius: 12
                    color: index === win.sel ? Theme.tint(Theme.mauve, 0.16) : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: win.sel = index
                        onClicked: win.choose(index)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: index === win.sel ? Theme.mauve : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: modelData.hint !== ""
                            text: modelData.hint
                            color: Theme.subtext0
                            font.family: Theme.font
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "picker"

        function toggle(name: string): void { Ui.togglePicker(name); }
        function close(): void { Ui.closePicker(); }
    }
}
