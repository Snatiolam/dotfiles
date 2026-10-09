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

    // Address of the device being paired; connected on the first list update
    // that reports it as paired/bonded.
    property string pendingAddress: ""

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
        if (d.pairing) return "pairing…";
        if (d.connected) return "connected";
        if (d.state === BluetoothDeviceState.Connecting) return "connecting…";
        if (d.paired || d.bonded) return "paired";
        return d.address || "";
    }

    // Connect a paired/bonded device.
    // - Trust it first: keyboards (e.g. Keychron) reconnect much more
    //   reliably once trusted.
    // - Stop discovery: connecting while an inquiry is running makes BlueZ
    //   fail intermittently with "br-connection-create-socket".
    // - Retry: that error also appears when the device is initiating the link
    //   at the same time, so a couple of retries are needed.
    function connectDevice(d, immediate): void {
        if (popup.adapter)
            popup.adapter.discovering = false;
        d.trusted = true;
        connectRetry.device = d;
        connectRetry.attempts = 0;
        if (immediate) {
            d.connect();
            connectRetry.restart();
        } else {
            connectRetry.start();
        }
    }

    // The device list is recomputed on every device property change, so this
    // runs as soon as the pairing finishes. Look the device up by address
    // (the object reference can change) and connect it.
    function checkPending(): void {
        if (!popup.pendingAddress)
            return;
        const d = popup.devices.find(x => x.address === popup.pendingAddress);
        if (!d || (!d.paired && !d.bonded))
            return;
        popup.pendingAddress = "";
        if (!d.connected)
            popup.connectDevice(d, false);
    }

    function onClick(d): void {
        if (d.connected) {
            d.disconnect();
            return;
        }
        if (d.pairing) {
            popup.pendingAddress = "";
            d.cancelPair();
            return;
        }
        if (d.paired || d.bonded) {
            popup.connectDevice(d, true);
            return;
        }
        // Unpaired: pair, then connect as soon as it bonds (checkPending).
        // Stop scanning so pairing is clean.
        if (popup.adapter)
            popup.adapter.discovering = false;
        popup.pendingAddress = d.address;
        d.pair();
    }

    // Scan while the panel is open, but skip it once something is connected:
    // a running inquiry can disturb an active keyboard link. The magnifier
    // button still lets the user force a scan any time.
    onVisibleChanged: {
        if (!popup.adapter)
            return;
        const hasConnected = popup.devices.some(d => d.connected);
        popup.adapter.discovering = popup.visible && !hasConnected;
    }

    onDevicesChanged: popup.checkPending()

    // Waits a moment, then connects the pending device unless it already
    // linked up; retries a few times to absorb "br-connection-create-socket".
    Timer {
        id: connectRetry
        property var device: null
        property int attempts: 0
        interval: 1800
        repeat: false
        onTriggered: {
            const d = connectRetry.device;
            if (!d || d.connected || d.state === BluetoothDeviceState.Connecting)
                return;
            if (connectRetry.attempts >= 3)
                return;
            connectRetry.attempts++;
            d.connect();
            connectRetry.restart();
        }
    }

    // Safety net while a pairing is in flight, in case the list does not
    // report the change on its own.
    Timer {
        running: popup.pendingAddress !== ""
        interval: 700
        repeat: true
        onTriggered: popup.checkPending()
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
                     && popup.devices.length === 0
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

                        // Row click sits behind the content so the trash button
                        // on top receives its own clicks.
                        HoverHandler { id: devHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.onClick(modelData)
                        }

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

                            // Forget: unpair/unbond and drop the device.
                            Text {
                                visible: modelData.paired || modelData.bonded
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
                    }
                }
            }
        }
    }
}