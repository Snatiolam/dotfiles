pragma Singleton

import QtQuick
import Quickshell

// Nerd Font glyphs (Font Awesome), verified against the installed fonts.
Singleton {
    // Audio
    readonly property string volumeHigh:   "\uDB81\uDD7E"
    readonly property string volumeMedium: "\uDB81\uDD80"
    readonly property string volumeLow:    "\uDB81\uDD7F"
    readonly property string volumeMute:   "\uDB81\uDF5F"
    readonly property string headphones:   "\uDB80\uDECB"

    // Brightness
    readonly property string brightness: "\uF185"

    // Battery
    readonly property string batteryFull:    "\uF240"
    readonly property string batteryThree:   "\uF241"
    readonly property string batteryHalf:    "\uF242"
    readonly property string batteryQuarter: "\uF243"
    readonly property string batteryEmpty:   "\uF244"
    readonly property string charging:       "\uF0E7"

    // Power profiles
    readonly property string leaf:       "\uF06C"
    readonly property string balanced:   "\uF24E"
    readonly property string performance: "\uF0E7"

    // Network
    readonly property string wifi:   "\uF1EB"
    readonly property string wired:  "\uF1E6"
    readonly property string globe:  "\uF0AC"

    // Bluetooth
    readonly property string bluetooth: "\uF294"

    // Notifications
    readonly property string bell:      "\uF0F3"
    readonly property string bellSlash: "\uF1F6"

    // Power menu
    readonly property string power:  "\uF011"
    readonly property string lock:   "\uF023"
    readonly property string logout: "\uF08B"
    readonly property string moon:   "\uF186"
    readonly property string reboot: "\uF021"

    // Misc
    readonly property string close: "\uF00D"
    readonly property string check: "\uF00C"

    // Calendar / navigation
    readonly property string calendar:     "\uF133"
    readonly property string chevronLeft:  "\uF053"
    readonly property string chevronRight: "\uF054"
    readonly property string chevronUp:    "\uF077"
    readonly property string chevronDown:  "\uF078"
    readonly property string refresh:      "\uF021"

    // Audio input
    readonly property string microphone: "\uF130"

    // Media
    readonly property string play:      "\uF04B"
    readonly property string pause:     "\uF04C"
    readonly property string backward:  "\uF04A"
    readonly property string forward:   "\uF04E"
    readonly property string music:     "\uF001"

    // Control center / misc
    readonly property string sliders:   "\uF1DE"

    // Lists / actions
    readonly property string eye:      "\uF06E"
    readonly property string eyeSlash: "\uF070"
    readonly property string trash:    "\uF1F8"
    readonly property string search:   "\uF002"
    readonly property string link:     "\uF0C1"
}
