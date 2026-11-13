import QtQuick
import Quickshell
import qs.config

// Dropdown popup anchored under a bar button; only one is open at a time (Ui.popout).
PopupWindow {
    id: root

    required property var anchorItem
    required property string popoutId

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    // PopupAnchor subtracts margins; this one drops the popup exactly Theme.popupGap
    // below the bar for any item height.
    anchor.margins.bottom: (Theme.barHeight + anchorItem.height) / 2 - Theme.barHeight - Theme.popupGap
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    color: "transparent"
    grabFocus: true
    readonly property bool shown: Ui.isPopoutOpenOn(popoutId, anchorItem.screenName)
    visible: shown

    onClosed: if (shown) Ui.closePopout()

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: Ui.closePopout()
    }

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
