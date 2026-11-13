import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules

// Lock screen on ext-session-lock-v1. Control it with `qs ipc call lock lock|unlock|toggle`.
Scope {
    id: root

    // Persisted so a config reload does not release the lock.
    PersistentProperties {
        id: persist
        reloadableId: "lockscreen"
        property bool locked: false
    }

    // Remember the lock across Quickshell restarts so the shell relocks when it comes back.
    FileView {
        id: lockMarker
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-locked"
        blockLoading: true
        printErrors: false
        onLoaded: if (text().trim() === "1") persist.locked = true
    }

    Connections {
        target: persist
        function onLockedChanged(): void { lockMarker.setText(persist.locked ? "1" : "0"); }
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
