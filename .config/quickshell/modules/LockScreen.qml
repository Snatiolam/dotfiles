import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules

// Lockscreen built on the ext-session-lock-v1 Wayland protocol. No external
// tools: works on any conformant compositor (Hyprland, sway, niri, ...).
//
// Control it with `qs ipc call lock lock|unlock|toggle`.
Scope {
    id: root

    // The lock state lives here so a config reload while locked does not
    // release the compositor lock (which would be a fail-open).
    PersistentProperties {
        id: persist
        reloadableId: "lockscreen"
        property bool locked: false
    }

    LockContext {
        id: lockContext
        onUnlocked: persist.locked = false
    }

    WlSessionLock {
        id: sessionLock
        locked: persist.locked

        surface: Component {
            WlSessionLockSurface {
                LockSurface {
                    anchors.fill: parent
                    context: lockContext
                }
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void { persist.locked = true; }
        function unlock(): void { persist.locked = false; }
        function toggle(): void { persist.locked = !persist.locked; }
    }
}
