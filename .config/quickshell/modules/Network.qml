import QtQuick
import Quickshell
import Quickshell.Networking
import qs.config

// Network status (WiFi). Click opens the networks panel.
Item {
    id: root

    readonly property var wifi: {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi)
                return devs[i];
        }
        return null;
    }

    readonly property bool connected: wifi ? wifi.connected : false
    readonly property bool enabled: Networking.wifiEnabled

    implicitWidth: 26
    implicitHeight: 26

    function netIcon(): string {
        if (!root.wifi) return Icons.wired;
        return Icons.wifi;
    }

    function netColor(): color {
        if (!root.enabled) return Theme.overlay0;
        if (root.connected) return Theme.text;
        return Theme.overlay1;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "network") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.netIcon()
        color: root.netColor()
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("network")
    }
}