//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.modules

// Config entry point: mounts the bar + overlays.
ShellRoot {
    Bar {}
    OsdOverlay {}
    Toast {}
    NotificationCenter {}
    PowerMenu {}
    Launcher {}
}
