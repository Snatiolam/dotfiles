import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components

// Battery (only visible when a laptop battery is present).
// The icon shows the fill level; clicking opens the battery panel.
BarButton {
    id: root

    popoutId: "battery"
    visible: present
    implicitWidth: present ? icon.implicitWidth + 14 : 0

    readonly property var device: UPower.displayDevice
    readonly property bool present: device && device.isPresent && device.isLaptopBattery

    readonly property real pct: device ? device.percentage * 100 : 0
    readonly property bool charging: device
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.FullyCharged)

    onClicked: Ui.togglePopout("battery")

    function fillColor(): color {
        return (!charging && pct <= 15) ? Theme.red : Theme.text;
    }

    BatteryIcon {
        id: icon
        anchors.centerIn: parent
        level: root.pct / 100
        charging: root.charging
        fillColor: root.fillColor()
    }
}
