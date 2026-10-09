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

    readonly property var networks: {
        if (!popup.wifi || !popup.wifi.networks) return [];
        const arr = popup.wifi.networks.values.slice();
        arr.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            return popup.normSignal(b) - popup.normSignal(a);
        });
        return arr;
    }

    property var pendingNetwork: null
    property string psk: ""
    property bool showPsk: false

    // Scan only while the panel is open.
    onVisibleChanged: {
        if (popup.wifi)
            popup.wifi.scannerEnabled = popup.visible;
    }

    function onNetworkClicked(n): void {
        if (n.connected) {
            n.disconnect();
            return;
        }
        if (popup.isOpen(n) || n.known) {
            n.connect();
            return;
        }
        popup.pendingNetwork = (popup.pendingNetwork === n) ? null : n;
        popup.psk = "";
        popup.showPsk = false;
    }

    function submitPsk(): void {
        const n = popup.pendingNetwork;
        if (n && popup.psk.length > 0)
            n.connectWithPsk(popup.psk);
        popup.pendingNetwork = null;
        popup.psk = "";
        popup.showPsk = false;
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

            Text {
                text: Icons.refresh
                color: scanHover.hovered ? Theme.text : Theme.overlay0
                font.family: Theme.font
                font.pixelSize: 13
                HoverHandler { id: scanHover }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.wifi) {
                            popup.wifi.scannerEnabled = false;
                            popup.wifi.scannerEnabled = true;
                        }
                    }
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
                                accent: modelData.connected ? Theme.green : Theme.text
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: modelData.connected ? Theme.text : Theme.subtext1
                                font.family: Theme.font
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: !popup.isOpen(modelData)
                                text: Icons.lock
                                color: Theme.overlay0
                                font.family: Theme.font
                                font.pixelSize: 10
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
                text: popup.wifi && popup.wifi.scannerEnabled
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
            Layout.fillWidth: true
            visible: popup.pendingNetwork !== null
            spacing: 6

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
                    onAccepted: popup.submitPsk()
                    onVisibleChanged: if (visible) forceActiveFocus()
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
                        onClicked: popup.pendingNetwork = null
                    }
                }
            }
        }
    }
}