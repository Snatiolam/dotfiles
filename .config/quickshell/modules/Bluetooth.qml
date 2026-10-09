import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.components

// Bluetooth status. Click opens the devices panel.
BarButton {
    id: root

    popoutId: "bluetooth"
    implicitWidth: row.implicitWidth + 14

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property int connectedCount: {
        let n = 0;
        const devs = Bluetooth.devices.values;
        for (let i = 0; i < devs.length; i++)
            if (devs[i].connected) n++;
        return n;
    }

    onClicked: Ui.togglePopout("bluetooth")

    function btColor(): color {
        if (!root.adapter || !root.enabled) return Theme.overlay0;
        return Theme.text;
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Icons.bluetooth
            color: root.btColor()
            font.family: Theme.font
            font.pixelSize: Theme.iconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.connectedCount > 0
            text: root.connectedCount
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 11
        }
    }
}
