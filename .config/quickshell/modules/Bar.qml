import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.popups

// Full-width top bar. Left: workspaces · Center: clock · Right: system.
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    // Compositor-side blur behind the translucent bar (macOS-style).
    BackgroundEffect.blurRegion: Region {
        item: panelBg
    }

    // Background
    Rectangle {
        id: panelBg
        anchors.fill: parent
        color: Theme.barBg

        // Bottom accent line (Macchiato gradient)
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

    // ── Left ─────────────────────────────────────────────────────
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.gap

        Workspaces {}
    }

    // ── Center ───────────────────────────────────────────────────
    Clock {
        id: clockWidget
        anchors.centerIn: parent
    }

    // ── Right ────────────────────────────────────────────────────
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

    // ── Popups (dropdowns) ───────────────────────────────────────
    CalendarPopup { anchorItem: clockWidget }
    BluetoothPopup { anchorItem: bluetoothWidget }
    NetworkPopup { anchorItem: networkWidget }
    AudioPopup { anchorItem: volumeWidget }
    BatteryPopup { anchorItem: batteryWidget }
    ControlCenterPopup { anchorItem: controlCenterWidget }
}
