pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Shared popup state: one popout at a time, opened on the focused screen.
Singleton {
    readonly property string focusedScreenName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    readonly property var focusedScreen: screenNamed(focusedScreenName)

    property string overlayScreenName: ""
    readonly property var overlayScreen: screenNamed(overlayScreenName)

    // "" | "calendar" | "network" | "bluetooth" | "audio" | "power" | "notifications"
    property string popout: ""

    readonly property bool powerMenu: popout === "power"
    readonly property bool notifCenter: popout === "notifications"

    function screenNamed(name: string): var {
        return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
    }

    function isPopoutOpenOn(name: string, screenName: string): bool {
        return popout === name && overlayScreenName === screenName;
    }

    function togglePopout(name): void {
        if (isPopoutOpenOn(name, focusedScreenName)) closePopout();
        else openPopout(name);
    }

    function openPopout(name): void {
        overlayScreenName = focusedScreenName;
        popout = name;
    }

    function closePopout(): void {
        popout = "";
    }

    property bool launcher: false

    function toggleLauncher(): void {
        if (launcher) closeLauncher();
        else openLauncher();
    }

    function openLauncher(): void {
        closePopout();
        overlayScreenName = focusedScreenName;
        launcher = true;
    }

    function closeLauncher(): void {
        launcher = false;
    }

    IpcHandler {
        target: "popup"

        function open(name: string): void {
            Ui.openPopout(name);
        }

        function close(): void {
            Ui.closePopout();
        }
    }
}
