import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.popups

// Full-width top bar. Left: workspaces · Center: clock · Right: system.
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    BackgroundEffect.blurRegion: Region {
        item: panelBg
    }

    Rectangle {
        id: panelBg
        anchors.fill: parent
        color: Theme.barBg

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.55) }
                GradientStop { position: 0.5; color: Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.55) }
                GradientStop { position: 1.0; color: Qt.rgba(Theme.teal.r, Theme.teal.g, Theme.teal.b, 0.55) }
            }
        }
    }

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.gap

        Workspaces {}
    }

    Clock {
        id: clockWidget
        anchors.centerIn: parent
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.gap

        Tray {}
        Bluetooth { id: bluetoothWidget }
        Network { id: networkWidget }
        Volume { id: volumeWidget }
        Battery { id: batteryWidget }
        Notifications {}
        ControlCenterButton { id: controlCenterWidget }
        PowerButton {}
    }

    CalendarPopup { anchorItem: clockWidget }
    BluetoothPopup { anchorItem: bluetoothWidget }
    NetworkPopup { anchorItem: networkWidget }
    AudioPopup { anchorItem: volumeWidget }
    BatteryPopup { anchorItem: batteryWidget }
    ControlCenterPopup { anchorItem: controlCenterWidget }
}
