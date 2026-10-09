import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.components

// Bluetooth panel: adapter switch, scanning and device list.
AnchoredPopup {
    id: popup

    popoutId: "bluetooth"

    implicitWidth: 340
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property var devices: {
        const arr = Bluetooth.devices.values.slice();
        arr.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.paired !== b.paired) return a.paired ? -1 : 1;
            return popup.deviceName(a).localeCompare(popup.deviceName(b));
        });
        return arr;
    }

    function deviceName(d): string {
        return d.deviceName || d.name || "Device";
    }

    function deviceSubtitle(d): string {
        if (d.batteryAvailable)
            return Math.round(d.battery * 100) + "%";
        if (d.connected) return "connected";
        if (d.paired) return "paired";
        return d.address || "";
    }

    function onClick(d): void {
        if (d.connected) {
            d.disconnect();
            return;
        }
        if (d.paired || d.bonded) {
            d.connect();
            return;
        }
        d.pair();
        d.connect();
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 8

        // ── Header ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Bluetooth"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: Icons.search
                color: (popup.adapter && popup.adapter.discovering)
                       ? Theme.blue : (scanHover.hovered ? Theme.text : Theme.overlay0)
                font.family: Theme.font
                font.pixelSize: 13
                HoverHandler { id: scanHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.adapter)
                            popup.adapter.discovering = !popup.adapter.discovering;
                    }
                }
            }

            Switch {
                checked: popup.adapter ? popup.adapter.enabled : false
                onToggled: {
                    if (popup.adapter)
                        popup.adapter.enabled = !popup.adapter.enabled;
                }
            }
        }

        // ── No adapter ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: !popup.adapter
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "Bluetooth unavailable"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── Searching… ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: popup.adapter && popup.adapter.discovering
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "Searching for devices…"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── No devices ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: popup.adapter && !popup.adapter.discovering
                     && popup.devices.length === 0
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: popup.adapter && !popup.adapter.enabled
                      ? "Bluetooth off"
                      : "No devices"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── Device list ───────────────────────────────────────────
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(232, listCol.implicitHeight)
            contentHeight: listCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: popup.devices.length > 0

            Column {
                id: listCol
                width: parent.width
                spacing: 3

                Repeater {
                    model: popup.devices

                    delegate: Rectangle {
                        required property var modelData

                        width: listCol.width
                        height: 34
                        radius: Theme.controlRadius
                        color: devHover.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 6
                            spacing: 8

                            Text {
                                text: Icons.bluetooth
                                color: modelData.connected ? Theme.blue : Theme.overlay1
                                font.family: Theme.font
                                font.pixelSize: 13
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: popup.deviceName(modelData)
                                    color: modelData.connected ? Theme.text : Theme.subtext1
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: popup.deviceSubtitle(modelData) !== ""
                                    text: popup.deviceSubtitle(modelData)
                                    color: Theme.overlay0
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: modelData.connected ? Icons.check : ""
                                color: Theme.green
                                font.family: Theme.font
                                font.pixelSize: 12
                            }

                            // Forget (paired only)
                            Text {
                                visible: modelData.paired
                                text: Icons.trash
                                color: forgetHover.hovered ? Theme.red : Theme.overlay0
                                font.family: Theme.font
                                font.pixelSize: 12
                                HoverHandler { id: forgetHover }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.forget()
                                }
                            }
                        }

                        HoverHandler { id: devHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.onClick(modelData)
                        }
                    }
                }
            }
        }
    }
}