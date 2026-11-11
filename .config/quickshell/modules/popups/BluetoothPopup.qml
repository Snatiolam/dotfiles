import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import qs.config
import qs.components

// Bluetooth panel, macOS-style: remembered devices (connected or paired)
// come first, then whatever an ongoing scan is finding, and a settings
// shortcut sits at the very bottom (opens blueman-manager).
AnchoredPopup {
    id: popup

    popoutId: "bluetooth"

    implicitWidth: 340
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool discovering: adapter ? adapter.discovering : false

    // Address of the device being paired; connected on the first list update
    // that reports it as paired/bonded.
    property string pendingAddress: ""

    // Every device the adapter knows about, sorted: connected, paired, name.
    // The section lists below are cuts of this, and checkPending() uses it
    // to look devices up by address.
    readonly property var devices: {
        const arr = Bluetooth.devices.values.slice();
        arr.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.paired !== b.paired) return a.paired ? -1 : 1;
            return popup.deviceName(a).localeCompare(popup.deviceName(b));
        });
        return arr;
    }

    // "My Devices": connected first, then remembered ones by name.
    readonly property var knownDevices:
        popup.devices.filter(d => d.connected || d.paired || d.bonded)

    // "Other Devices": scan results that are not remembered yet. Unnamed
    // ones are dropped — there is nothing to show for them.
    readonly property var discoveredDevices: popup.devices.filter(
        d => !(d.connected || d.paired || d.bonded) && (d.deviceName || d.name))

    function deviceName(d): string {
        return d.deviceName || d.name || "Device";
    }

    // BlueZ reports a device-type icon name; map it to a matching glyph.
    function deviceIcon(d): string {
        const icon = d.icon || "";
        if (icon.indexOf("keyboard") !== -1) return Icons.keyboard;
        if (icon.indexOf("mouse") !== -1) return Icons.mouse;
        if (icon.indexOf("gaming") !== -1) return Icons.gamepad;
        if (icon.indexOf("tablet") !== -1) return Icons.tablet;
        if (icon.indexOf("headset") !== -1 || icon.indexOf("headphone") !== -1
                || icon.indexOf("audio") !== -1) return Icons.headphones;
        if (icon.indexOf("microphone") !== -1) return Icons.microphone;
        if (icon.indexOf("player") !== -1) return Icons.music;
        if (icon.indexOf("watch") !== -1) return Icons.watch;
        if (icon.indexOf("phone") !== -1 || icon.indexOf("modem") !== -1)
            return Icons.phone;
        if (icon.indexOf("computer") !== -1) return Icons.laptop;
        if (icon.indexOf("printer") !== -1 || icon.indexOf("scanner") !== -1)
            return Icons.printer;
        if (icon.indexOf("camera") !== -1) return Icons.camera;
        return Icons.bluetooth;
    }

    // macOS wording: the right side of a row states the device's condition.
    function statusText(d): string {
        if (d.pairing) return "Pairing…";
        if (d.state === BluetoothDeviceState.Connecting) return "Connecting…";
        if (d.connected) {
            return d.batteryAvailable
                ? "Connected · " + Math.round(d.battery * 100) + "%"
                : "Connected";
        }
        if (d.paired || d.bonded) return "Not Connected";
        return "Not Paired";
    }

    function statusColor(d): color {
        if (d.pairing || d.state === BluetoothDeviceState.Connecting)
            return Theme.blue;
        if (d.connected) return Theme.green;
        return Theme.overlay0;
    }

    // Hovering a row swaps its status text for this action pill (macOS).
    function actionLabel(d): string {
        if (d.pairing) return "Cancel";
        if (d.connected) return "Disconnect";
        if (d.paired || d.bonded) return "Connect";
        return "Pair";
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
        if (!popup.adapter || !popup.adapter.enabled)
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

    // Opens the BlueZ device manager. Detached so it survives quickshell
    // restarts and config reloads.
    Process {
        id: settingsProc
        running: false
        command: ["sh", "-c", "setsid blueman-manager >/dev/null 2>&1 &"]
    }

    // One device row: type icon, name, and a status text that hover swaps
    // for a Connect/Disconnect pill (macOS System Settings behaviour).
    Component {
        id: deviceDelegate

        Rectangle {
            required property var modelData

            width: listCol.width
            height: 34
            radius: Theme.controlRadius
            color: rowHover.hovered ? Theme.hover : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            HoverHandler { id: rowHover }
            // Row-wide click sits behind the content, so the pill and the
            // trash button on top receive their own clicks.
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
                    text: popup.deviceIcon(modelData)
                    color: modelData.connected ? Theme.blue : Theme.overlay1
                    font.family: Theme.font
                    font.pixelSize: 13
                }

                Text {
                    Layout.fillWidth: true
                    text: popup.deviceName(modelData)
                    color: modelData.connected ? Theme.text : Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                // Fixed-width slot: swapping status ↔ pill never reflows.
                Item {
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 22

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        text: popup.statusText(modelData)
                        color: popup.statusColor(modelData)
                        font.family: Theme.font
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        opacity: rowHover.hovered ? 0 : 1
                        visible: opacity > 0.01
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: pillLabel.implicitWidth + 20
                        height: 22
                        radius: Theme.controlRadius
                        color: pillHover.hovered ? Theme.surface1 : Theme.surface0
                        Behavior on color { ColorAnimation { duration: 120 } }
                        opacity: rowHover.hovered ? 1 : 0
                        visible: opacity > 0.01
                        Behavior on opacity { NumberAnimation { duration: 100 } }

                        HoverHandler { id: pillHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.onClick(modelData)
                        }

                        Text {
                            id: pillLabel
                            anchors.centerIn: parent
                            text: popup.actionLabel(modelData)
                            color: Theme.subtext0
                            font.family: Theme.font
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                // Forget (unpair), revealed on hover for remembered devices.
                Item {
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14

                    Text {
                        anchors.centerIn: parent
                        text: Icons.trash
                        color: forgetHover.hovered ? Theme.red : Theme.overlay0
                        font.family: Theme.font
                        font.pixelSize: 12
                        opacity: (modelData.paired || modelData.bonded)
                                 && rowHover.hovered ? 1 : 0
                        visible: opacity > 0.01
                        Behavior on opacity { NumberAnimation { duration: 100 } }

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

            // Toggle a scan on demand.
            Text {
                text: Icons.search
                color: popup.discovering
                       ? Theme.blue
                       : (scanHover.hovered ? Theme.text : Theme.overlay0)
                font.family: Theme.font
                font.pixelSize: 13
                HoverHandler { id: scanHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.adapter && popup.adapter.enabled)
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

        // ── Now discoverable (macOS wording) ──────────────────────
        Text {
            Layout.fillWidth: true
            visible: popup.adapter && popup.adapter.discoverable
            text: "Now discoverable as \u201C"
                  + (popup.adapter ? popup.adapter.name : "") + "\u201D"
            color: Theme.overlay0
            font.family: Theme.font
            font.pixelSize: 11
            elide: Text.ElideMiddle
        }

        // ── No adapter / Bluetooth off ────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: !popup.adapter || !popup.adapter.enabled
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: popup.adapter ? "Bluetooth off" : "Bluetooth unavailable"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── Device list ───────────────────────────────────────────
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(300, listCol.implicitHeight)
            contentHeight: listCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: popup.knownDevices.length > 0
                     || popup.discoveredDevices.length > 0
                     || popup.discovering

            Column {
                id: listCol
                width: parent.width
                spacing: 3

                Text {
                    visible: popup.knownDevices.length > 0
                    leftPadding: 4
                    text: "My Devices"
                    color: Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 11
                    font.bold: true
                }

                Repeater {
                    model: popup.knownDevices
                    delegate: deviceDelegate
                }

                // ── Scan results ──────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 3
                    visible: popup.discovering
                             || popup.discoveredDevices.length > 0

                    Rectangle {
                        visible: popup.knownDevices.length > 0
                        width: parent.width
                        height: 1
                        color: Theme.cardBorder
                    }

                    RowLayout {
                        width: parent.width
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            leftPadding: 4
                            text: "Other Devices"
                            color: Theme.subtext0
                            font.family: Theme.font
                            font.pixelSize: 11
                            font.bold: true
                        }

                        // Spin while the inquiry runs.
                        Text {
                            visible: popup.discovering
                            text: Icons.refresh
                            color: Theme.blue
                            font.family: Theme.font
                            font.pixelSize: 10

                            RotationAnimator on rotation {
                                running: popup.discovering
                                from: 0
                                to: 360
                                duration: 900
                                loops: Animation.Infinite
                            }
                        }
                    }

                    Repeater {
                        model: popup.discoveredDevices
                        delegate: deviceDelegate
                    }

                    // Nothing found yet.
                    Text {
                        visible: popup.discovering
                                 && popup.discoveredDevices.length === 0
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "Searching for devices…"
                        color: Theme.overlay0
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }
            }
        }

        // ── Nothing at all ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: popup.adapter && popup.adapter.enabled
                     && popup.knownDevices.length === 0
                     && popup.discoveredDevices.length === 0
                     && !popup.discovering
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "No devices"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── Settings ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: Theme.controlRadius
            color: settingsHover.hovered ? Theme.hover : Theme.surface0
            Behavior on color { ColorAnimation { duration: 120 } }

            HoverHandler { id: settingsHover }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    settingsProc.running = true;
                    Ui.closePopout();
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Icons.gear
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 12
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth Settings…"
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }
}
