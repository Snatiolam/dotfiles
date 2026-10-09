pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Shared state for overlays and popups.
// Only one popup open at a time: opening one automatically closes the rest.
Singleton {
    // "" | "calendar" | "network" | "bluetooth" | "audio" | "power" | "notifications"
    property string popout: ""

    // Derived: keeps compatibility with existing overlays.
    readonly property bool powerMenu: popout === "power"
    readonly property bool notifCenter: popout === "notifications"

    function togglePopout(name): void {
        popout = (popout === name) ? "" : name;
    }

    function openPopout(name): void {
        popout = name;
    }

    function closePopout(): void {
        popout = "";
    }

    function togglePowerMenu(): void {
        togglePopout("power");
    }

    function toggleNotifCenter(): void {
        togglePopout("notifications");
    }

    function closeAll(): void {
        popout = "";
    }

    // External control: `qs ipc call popup open network` / `... close`
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
