import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config

// Battery (only visible when a laptop battery is present).
Item {
    id: root

    readonly property var device: UPower.displayDevice

    visible: device && device.isPresent && device.isLaptopBattery
    implicitWidth: visible ? row.implicitWidth + 14 : 0
    implicitHeight: 26

    readonly property real pct: device ? device.percentage : 0
    readonly property bool charging: device
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.FullyCharged)

    function batteryIcon(): string {
        if (charging) return Icons.charging;
        if (pct >= 90) return Icons.batteryFull;
        if (pct >= 65) return Icons.batteryThree;
        if (pct >= 40) return Icons.batteryHalf;
        if (pct >= 15) return Icons.batteryQuarter;
        return Icons.batteryEmpty;
    }

    function batteryColor(): color {
        if (charging) return Theme.green;
        if (pct < 15) return Theme.red;
        if (pct < 30) return Theme.yellow;
        return Theme.text;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: hover.hovered ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon()
            color: root.batteryColor()
            font.family: Theme.font
            font.pixelSize: Theme.iconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.pct) + "%"
            color: Theme.subtext0
            font.family: Theme.font
            font.pixelSize: 12
        }
    }

    HoverHandler { id: hover }
}
