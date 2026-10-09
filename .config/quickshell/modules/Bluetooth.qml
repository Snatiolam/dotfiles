import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.config

// Bluetooth. Click opens the devices panel.
Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property int connectedCount: {
        let n = 0;
        const devs = Bluetooth.devices.values;
        for (let i = 0; i < devs.length; i++)
            if (devs[i].connected) n++;
        return n;
    }

    implicitWidth: row.implicitWidth + 14
    implicitHeight: 26

    function btColor(): color {
        if (!root.adapter || !root.enabled) return Theme.overlay0;
        if (root.connectedCount > 0) return Theme.blue;
        return Theme.text;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "bluetooth") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
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

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("bluetooth")
    }
}