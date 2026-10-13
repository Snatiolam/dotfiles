import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.config
import qs.components

// Network panel: WiFi switch, network list, connection and password.
AnchoredPopup {
    id: popup

    popoutId: "network"

    implicitWidth: 340
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var wifi: {
        const arr = Networking.devices.values;
        for (let i = 0; i < arr.length; i++)
            if (arr[i].type === DeviceType.Wifi) return arr[i];
        return null;
    }

    readonly property var wired: {
        const arr = Networking.devices.values;
        for (let i = 0; i < arr.length; i++)
            if (arr[i].type === DeviceType.Wired) return arr[i];
        return null;
    }

    function normSignal(n): real {
        const s = n ? n.signalStrength : 0;
        if (s === undefined || s === null) return 0;
        return s > 1 ? s / 100 : s;
    }

    function isOpen(n): bool {
        return n.security === WifiSecurityType.Open;
    }

    // A connection attempt in flight.
    function isConnecting(n): bool {
        return !!n && n.state === ConnectionState.Connecting;
    }

    // Sort priority: the network being connected first, then the connected one,
    // then everything else by signal strength.
    function netRank(n): int {
        if (popup.isConnecting(n)) return 0;
        if (n.connected) return 1;
        return 2;
    }

    // Human-readable failure reason for the password prompt.
    function failText(reason): string {
        switch (reason) {
        case ConnectionFailReason.NoSecrets: return "Wrong password";
        case ConnectionFailReason.WifiAuthTimeout: return "Authentication timed out";
        case ConnectionFailReason.WifiClientFailed: return "Authentication failed";
        case ConnectionFailReason.WifiNetworkLost: return "Network lost";
        case ConnectionFailReason.WifiClientDisconnected: return "Disconnected";
        default: return "Connection failed";
        }
    }

    // A wrong password can surface as different reasons depending on the
    // driver/NetworkManager version, so treat everything as retryable except a
    // network that simply vanished.
    function isAuthFail(reason): bool {
        return reason !== ConnectionFailReason.WifiNetworkLost;
    }

    // NetworkManager saves the profile on the failed attempt, so without
    // forgetting it every later click would reconnect with the bad secret and
    // fail instantly. Drop it and reopen the prompt so the user can retry.
    function onConnectionFailed(n, reason): void {
        popup.pskError = popup.failText(reason);
        if (popup.isAuthFail(reason) && !popup.isOpen(n)) {
            n.forget();
            popup.pendingNetwork = n;
            popup.psk = "";
            popup.showPsk = false;
        }
    }

    readonly property var networks: {
        if (!popup.wifi || !popup.wifi.networks) return [];
        const arr = popup.wifi.networks.values.slice();
        arr.sort((a, b) => {
            const ra = popup.netRank(a);
            const rb = popup.netRank(b);
            if (ra !== rb) return ra - rb;
            return popup.normSignal(b) - popup.normSignal(a);
        });
        return arr;
    }

    property var pendingNetwork: null
    property string psk: ""
    property bool showPsk: false
    // Message shown in the password prompt after a failed attempt.
    property string pskError: ""

    // True while a WiFi scan is (probably) in flight. The backend exposes no
    // "scanning" signal, so this is driven by a timeout purely for feedback.
    property bool scanning: false

    // Scan only while the panel is open.
    onVisibleChanged: {
        if (!popup.wifi)
            return;
        popup.wifi.scannerEnabled = popup.visible;
        popup.scanning = popup.visible;
        if (popup.visible) {
            popup.pskError = "";
            popup.pendingNetwork = null;
            scanTimeout.restart();
        } else {
            scanTimeout.stop();
        }
    }

    // Kick off a fresh scan and show the spinner for a moment.
    function rescan(): void {
        if (popup.wifi) {
            popup.wifi.scannerEnabled = false;
            popup.wifi.scannerEnabled = true;
        }
        popup.scanning = true;
        scanTimeout.restart();
    }

    function onNetworkClicked(n): void {
        popup.pskError = "";
        if (n.connected) {
            n.disconnect();
            return;
        }
        // Clicking the pending network again closes its prompt.
        if (popup.pendingNetwork === n) {
            popup.pendingNetwork = null;
            return;
        }
        if (popup.isOpen(n) || n.known) {
            n.connect();
            return;
        }
        popup.pendingNetwork = n;
        popup.psk = "";
        popup.showPsk = false;
    }

    function submitPsk(): void {
        const n = popup.pendingNetwork;
        // Ignore empty submits so Enter does not dismiss the prompt.
        if (!n || popup.psk.length === 0)
            return;
        popup.pskError = "";
        n.connectWithPsk(popup.psk);
        popup.pendingNetwork = null;
        popup.psk = "";
        popup.showPsk = false;
    }

    // A WiFi scan reports no completion, so keep the spinner up briefly.
    Timer {
        id: scanTimeout
        interval: 3000
        repeat: false
        onTriggered: popup.scanning = false
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
                text: "Network"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
            }

            Item {
                implicitWidth: scanIcon.implicitWidth
                implicitHeight: scanIcon.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: Icons.refresh
                    color: popup.scanning
                           ? Theme.blue
                           : (scanHover.hovered ? Theme.text : Theme.overlay0)
                    font.family: Theme.font
                    font.pixelSize: 13

                    // Spin while a scan is in flight.
                    RotationAnimator on rotation {
                        running: popup.scanning
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }
                }

                HoverHandler { id: scanHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.rescan()
                }
            }

            Switch {
                checked: Networking.wifiEnabled
                onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        // ── Wired status ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            visible: popup.wired !== null
            height: 30
            radius: Theme.controlRadius
            color: Theme.surface0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: Icons.wired
                    color: popup.wired && popup.wired.connected ? Theme.green : Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 13
                }

                Text {
                    Layout.fillWidth: true
                    text: "Ethernet"
                    color: Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 12
                }

                Text {
                    text: popup.wired && popup.wired.connected ? Icons.check : ""
                    color: Theme.green
                    font.family: Theme.font
                    font.pixelSize: 12
                }
            }
        }

        // ── Network list ──────────────────────────────────────────
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(232, listCol.implicitHeight)
            contentHeight: listCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: Networking.wifiEnabled && popup.networks.length > 0

            Column {
                id: listCol
                width: parent.width
                spacing: 3

                Repeater {
                    model: popup.networks

                    delegate: Rectangle {
                        required property var modelData

                        width: listCol.width
                        height: 30
                        radius: Theme.controlRadius
                        color: netHover.hovered ? Theme.hover : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            SignalBars {
                                value: popup.normSignal(modelData)
                                accent: modelData.connected ? Theme.green
                                        : popup.isConnecting(modelData) ? Theme.blue
                                        : Theme.text
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: modelData.connected ? Theme.text
                                       : popup.isConnecting(modelData) ? Theme.blue
                                       : Theme.subtext1
                                font.family: Theme.font
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: !popup.isOpen(modelData) && !popup.isConnecting(modelData)
                                text: Icons.lock
                                color: Theme.overlay0
                                font.family: Theme.font
                                font.pixelSize: 10
                            }

                            // Connection attempt in progress.
                            RowLayout {
                                visible: popup.isConnecting(modelData)
                                spacing: 4

                                Text {
                                    text: Icons.refresh
                                    color: Theme.blue
                                    font.family: Theme.font
                                    font.pixelSize: 10

                                    RotationAnimator on rotation {
                                        running: popup.isConnecting(modelData)
                                        from: 0
                                        to: 360
                                        duration: 900
                                        loops: Animation.Infinite
                                    }
                                }

                                Text {
                                    text: "connecting…"
                                    color: Theme.blue
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                text: modelData.connected ? Icons.check : ""
                                color: Theme.green
                                font.family: Theme.font
                                font.pixelSize: 12
                            }
                        }

                        HoverHandler { id: netHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.onNetworkClicked(modelData)
                        }

                        // Surface connect failures (e.g. wrong password).
                        Connections {
                            target: modelData
                            function onConnectionFailed(reason) {
                                popup.onConnectionFailed(modelData, reason);
                            }
                        }
                    }
                }
            }
        }

        // ── Empty states ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: Networking.wifiEnabled && popup.networks.length === 0
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: popup.scanning
                      ? "Scanning for networks…"
                      : "No networks found"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            visible: !Networking.wifiEnabled
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "WiFi off"
                color: Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ── Password ──────────────────────────────────────────────
        ColumnLayout {
            id: pskSection
            Layout.fillWidth: true
            visible: popup.pendingNetwork !== null
            spacing: 6

            // Focus the field as soon as the prompt appears. Doing this on the
            // section (not the TextInput) is what actually fires: a child item's
            // own `visible` never changes when the parent is toggled.
            onVisibleChanged: if (visible) Qt.callLater(pskInput.forceActiveFocus)

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: "Secure network: "
                          + (popup.pendingNetwork ? popup.pendingNetwork.name : "")
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    text: popup.showPsk ? Icons.eyeSlash : Icons.eye
                    color: Theme.overlay0
                    font.family: Theme.font
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.showPsk = !popup.showPsk
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: popup.pskError !== ""
                text: popup.pskError
                color: Theme.red
                font.family: Theme.font
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: Theme.controlRadius
                color: Theme.surface0
                border.width: 1
                border.color: pskInput.activeFocus ? Theme.mauve : Theme.cardBorder

                TextInput {
                    id: pskInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    selectionColor: Theme.mauve
                    selectedTextColor: Theme.base
                    font.family: Theme.font
                    font.pixelSize: 12
                    echoMode: popup.showPsk ? TextInput.Normal : TextInput.Password
                    selectByMouse: true
                    // Keep the field and the model in sync. textEdited fires only
                    // on user input, so this one-way binding never loops.
                    text: popup.psk
                    onTextEdited: popup.psk = text
                    onAccepted: popup.submitPsk()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.controlRadius
                    color: connHover.hovered ? Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.25) : Theme.surface0
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: Theme.mauve
                        font.family: Theme.font
                        font.pixelSize: 11
                        font.bold: true
                    }

                    HoverHandler { id: connHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.submitPsk()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.controlRadius
                    color: cancelHover.hovered ? Theme.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Theme.subtext1
                        font.family: Theme.font
                        font.pixelSize: 11
                    }

                    HoverHandler { id: cancelHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.pendingNetwork = null;
                            popup.pskError = "";
                        }
                    }
                }
            }
        }
    }
}