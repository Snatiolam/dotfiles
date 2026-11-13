import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config

// macOS-style app launcher. Search is done with fzf over a TSV built by
// list_apps.py. Controlled with `qs ipc call launcher toggle`.
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
    visible: Ui.launcher

    // ── State ────────────────────────────────────────────────────
    property var results: []
    property string query: ""
    property int sel: -1
    property bool pendingFilter: false

    readonly property string launcherScript: Quickshell.shellDir + "/modules/list_apps.py"

    // ── Startup: build the app list for fzf ──────────────────────
    // Rebuilt every time the launcher opens so newly installed apps
    // (e.g. flatpaks) show up without restarting the shell.
    Process {
        id: appScan
        running: false
        command: ["python3", win.launcherScript]
        stdout: StdioCollector {
            onStreamFinished: if (win.visible) win.requestFilter()
        }
    }

    // ── Filter through fzf ───────────────────────────────────────
    Process {
        id: filterProc
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                win.applyResults(this.text || "");
                if (win.pendingFilter) Qt.callLater(() => win.requestFilter());
            }
        }
    }

    Timer {
        id: debounce
        interval: 60
        onTriggered: win.requestFilter()
    }

    function sanitize(q: string): string {
        return q.replace(/[^a-zA-Z0-9\u00C0-\u00FF _.-]/g, "");
    }

    // Always applies the *latest* query: if a filter is in flight, remember
    // that another pass is needed once it finishes instead of dropping it.
    function requestFilter(): void {
        if (filterProc.running) {
            win.pendingFilter = true;
            return;
        }
        win.pendingFilter = false;
        const safe = win.sanitize(win.query);
        filterProc.command = ["sh", "-c",
            "fzf --exact --delimiter='\\t' --nth=1 --tiebreak=begin,index --filter='" + safe + "' < /tmp/qs_apps.tsv | head -n 8"];
        filterProc.running = true;
    }

    function applyResults(text: string): void {
        const arr = [];
        for (const line of (text || "").split("\n")) {
            if (line.trim() === "") continue;
            const f = line.split("\t");
            arr.push({
                name: f[0] || "",
                exec: f[1] || "",
                icon: f[2] || "",
                comment: f[3] || "",
            });
        }
        win.results = arr;
        win.sel = arr.length > 0 ? 0 : -1;
    }

    function launch(i: int): void {
        const r = win.results[i];
        if (r && r.exec) Quickshell.execDetached(["sh", "-c", r.exec]);
        Ui.closeLauncher();
    }

    function onOpened(): void {
        field.text = "";
        win.query = "";
        win.results = [];
        win.sel = -1;
        win.pendingFilter = false;
        appScan.running = true;
        debounce.start();
        Qt.callLater(() => field.forceActiveFocus());
    }

    onVisibleChanged: if (win.visible) win.onOpened()

    // Click outside the card to close.
    MouseArea {
        anchors.fill: parent
        onClicked: Ui.closeLauncher()
    }

    // ── Card ─────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.14
        width: 520
        implicitHeight: cardCol.implicitHeight + 24
        radius: 24
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        // Absorbs clicks inside the card.
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Search box
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 54
                radius: 16
                color: Theme.surface0
                border.width: 1
                border.color: field.activeFocus ? Theme.tint(Theme.mauve, 0.6) : "transparent"
                Behavior on border.color { ColorAnimation { duration: 120 } }

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
                            text: "Search apps…"
                            color: Theme.overlay0
                            font: field.font
                        }

                        onTextChanged: {
                            win.query = field.text;
                            debounce.restart();
                        }

                        Keys.onUpPressed: function(event) {
                            if (win.results.length > 0) {
                                win.sel = (win.sel - 1 + win.results.length) % win.results.length;
                            }
                            event.accepted = true;
                        }
                        Keys.onDownPressed: function(event) {
                            if (win.results.length > 0) {
                                win.sel = (win.sel + 1) % win.results.length;
                            }
                            event.accepted = true;
                        }
                        Keys.onReturnPressed: function(event) {
                            if (win.results.length > 0) win.launch(win.sel);
                            event.accepted = true;
                        }
                        Keys.onEscapePressed: function(event) {
                            Ui.closeLauncher();
                            event.accepted = true;
                        }
                        Keys.onTabPressed: function(event) { event.accepted = true }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: win.query !== "" && win.results.length === 0
                text: "No results"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 13
            }

            // Results
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: win.results.slice(0, 8)
                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        implicitHeight: 64
                        radius: 14
                        color: index === win.sel ? Theme.tint(Theme.mauve, 0.16) : "transparent"
                        Behavior on color { ColorAnimation { duration: 90 } }

                        HoverHandler { id: hover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onEntered: win.sel = index
                            onClicked: win.launch(index)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 14

                            // Icon (or first-letter tile)
                            Rectangle {
                                width: 44
                                height: 44
                                radius: 12
                                color: Theme.tint(Theme.mauve, 0.16)
                                clip: true
                                visible: modelData.icon === ""

                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.name && modelData.name.charAt(0)) || "?"
                                    color: Theme.mauve
                                    font.family: Theme.font
                                    font.pixelSize: 19
                                    font.bold: true
                                }
                            }

                            Image {
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44
                                Layout.alignment: Qt.AlignVCenter
                                visible: modelData.icon !== ""
                                source: modelData.icon
                                sourceSize: Qt.size(96, 96)
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: index === win.sel ? Theme.mauve : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: modelData.comment
                                    color: Theme.subtext0
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── IPC: `qs ipc call launcher toggle/open/close` ────────────
    IpcHandler {
        target: "launcher"

        function toggle(): void { Ui.toggleLauncher(); }
        function open(): void { Ui.openLauncher(); }
        function close(): void { Ui.closeLauncher(); }
    }
}