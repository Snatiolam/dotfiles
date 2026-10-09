import QtQuick
import Quickshell
import qs.config

// Base for dropdown popups.
// They anchor under their item, close on click outside (onClosed)
// or with Escape, and only one can be visible at a time (Ui.popout).
PopupWindow {
    id: root

    // Bar item the popup appears under.
    required property var anchorItem
    // Key in Ui.popout controlling visibility.
    required property string popoutId

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: Theme.popupGap
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    color: "transparent"
    grabFocus: true
    visible: Ui.popout === popoutId

    // Click outside → Wayland closes the popup.
    onClosed: if (Ui.popout === popoutId) Ui.popout = ""

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: Ui.closePopout()
    }

    // Background card (content is drawn on top).
    Rectangle {
        id: card
        z: -1
        anchors.fill: parent
        radius: Theme.popupRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder
    }
}
