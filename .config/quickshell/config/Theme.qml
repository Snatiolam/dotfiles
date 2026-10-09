pragma Singleton

import QtQuick
import Quickshell

// Central theme: Catppuccin Macchiato pastel palette + bar metrics.
Singleton {
    id: theme

    // ── Catppuccin Macchiato palette ──────────────────────────────
    readonly property color rosewater: "#f4dbd6"
    readonly property color flamingo:  "#f0c6c6"
    readonly property color pink:      "#f5bde6"
    readonly property color mauve:     "#c6a0f6"
    readonly property color red:       "#ed8796"
    readonly property color maroon:    "#ee99a0"
    readonly property color peach:     "#f5a97f"
    readonly property color yellow:    "#eed49f"
    readonly property color green:     "#a6da95"
    readonly property color teal:      "#8bd5ca"
    readonly property color sky:       "#91d7e3"
    readonly property color sapphire:  "#7dc4e4"
    readonly property color blue:      "#8aadf4"
    readonly property color lavender:  "#b7bdf8"

    readonly property color text:      "#cad3f5"
    readonly property color subtext1:  "#b8c0e0"
    readonly property color subtext0:  "#a5adcb"
    readonly property color overlay2:  "#939ab7"
    readonly property color overlay1:  "#8087a2"
    readonly property color overlay0:  "#6e738d"
    readonly property color surface2:  "#5b6078"
    readonly property color surface1:  "#494d64"
    readonly property color surface0:  "#363a4f"
    readonly property color base:      "#24273a"
    readonly property color mantle:    "#1e2030"
    readonly property color crust:     "#181926"

    // ── Metrics ───────────────────────────────────────────────────
    readonly property int barHeight: 36
    readonly property int radius: 12
    readonly property int smallRadius: 8
    readonly property int gap: 4
    readonly property int padding: 10
    readonly property int fontSize: 13
    readonly property int iconSize: 15
    readonly property string font: "MonaspiceNe Nerd Font"

    // ── Derived pastel tones ──────────────────────────────────────
    // Translucent enough for the compositor blur (macOS-style) to show through.
    readonly property color barBg: Qt.rgba(base.r, base.g, base.b, 0.55)
    readonly property color cardBg: Qt.rgba(crust.r, crust.g, crust.b, 0.96)
    readonly property color cardBorder: Qt.rgba(surface2.r, surface2.g, surface2.b, 0.5)
    readonly property color hover: Qt.rgba(surface1.r, surface1.g, surface1.b, 0.55)
    readonly property color accent: mauve
    readonly property color track: surface0

    // Notification bell: same whitish as the rest of the widgets when idle,
    // warm pastel when there are pending notifications.
    readonly property color bellIdle: text
    readonly property color bellActive: yellow

    // Tinted translucent fill, useful for glows/backgrounds.
    function tint(c: color, alpha): color {
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    // ── Popups ────────────────────────────────────────────────────
    readonly property int popupRadius: 16
    readonly property int popupPadding: 14
    // Gap between the bar and any popup, in pixels.
    readonly property int popupGap: 4
    readonly property int controlRadius: 8
}
