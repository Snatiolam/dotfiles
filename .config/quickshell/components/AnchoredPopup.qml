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
    // PopupAnchor *removes* margins from the anchor rect, so a positive bottom
    // margin pulls the popup up into the bar. A negative one pushes it down.
    // Bar items are vertically centered, so their bottom edge is at
    // (barHeight + itemHeight) / 2; solving for the margin makes the popup's
    // top land exactly Theme.popupGap below the bar for any item height.
    anchor.margins.bottom: (Theme.barHeight + anchorItem.height) / 2 - Theme.barHeight - Theme.popupGap
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
