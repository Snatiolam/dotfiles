import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components

// Battery (only visible when a laptop battery is present).
// The icon shows the fill level; hover reveals the exact percentage and
// clicking opens the battery panel.
Item {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device && device.isPresent && device.isLaptopBattery

    visible: present
    implicitWidth: present ? icon.implicitWidth + 14 : 0
    implicitHeight: 26

    readonly property real pct: device ? device.percentage * 100 : 0
    readonly property bool charging: device
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.FullyCharged)

    function fillColor(): color {
        if (!charging && pct <= 15) return Theme.red;
        return Theme.text;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: (hover.hovered || Ui.popout === "battery") ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    BatteryIcon {
        id: icon
        anchors.centerIn: parent
        level: root.pct / 100
        charging: root.charging
        fillColor: root.fillColor()
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ui.togglePopout("battery")
    }
}
