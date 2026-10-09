import QtQuick
import Quickshell
import Quickshell.Networking
import qs.config
import qs.components

// Network status (WiFi). Click opens the networks panel.
BarButton {
    id: root

    popoutId: "network"

    readonly property var wifi: {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi)
                return devs[i];
        }
        return null;
    }

    readonly property bool enabled: Networking.wifiEnabled

    onClicked: Ui.togglePopout("network")

    function netIcon(): string {
        return root.wifi ? Icons.wifi : Icons.wired;
    }

    function netColor(): color {
        return root.enabled ? Theme.text : Theme.overlay0;
    }

    Text {
        anchors.centerIn: parent
        text: root.netIcon()
        color: root.netColor()
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }
}
