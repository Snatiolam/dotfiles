import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components

// Battery panel: macOS-style overview (charge, time, health) and power mode.
AnchoredPopup {
    id: popup

    popoutId: "battery"

    implicitWidth: 320
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var device: UPower.displayDevice
    readonly property bool present: device && device.isPresent && device.isLaptopBattery
    readonly property real pct: device ? device.percentage * 100 : 0
    readonly property bool charging: device
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.FullyCharged)
    readonly property bool full: device && device.state === UPowerDeviceState.FullyCharged

    function fillColor(): color {
        if (!charging && pct <= 15) return Theme.red;
        return Theme.text;
    }

    function fmtDuration(sec): string {
        if (!sec || sec <= 0) return "";
        const h = Math.floor(sec / 3600);
        const m = Math.round((sec % 3600) / 60);
        if (h > 0) return h + " h " + m + " min";
        return m + " min";
    }

    function statusText(): string {
        if (!device) return "";
        if (full) return "Fully charged";
        if (charging) {
            const t = fmtDuration(device.timeToFull);
            return t ? t + " until full" : "Charging";
        }
        const t = fmtDuration(device.timeToEmpty);
        return t ? t + " remaining" : "On battery";
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 12

        // ── Header ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Battery"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                visible: popup.charging
                text: Icons.charging
                color: Theme.green
                font.family: Theme.font
                font.pixelSize: 13
            }
        }

        // ── Hero: battery + charge ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            BatteryIcon {
                Layout.alignment: Qt.AlignVCenter
                bodyWidth: 62
                bodyHeight: 30
                borderWidth: 2
                level: popup.pct / 100
                charging: popup.charging
                fillColor: popup.fillColor()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: Math.round(popup.pct) + "%"
                    color: popup.fillColor()
                    font.family: Theme.font
                    font.pixelSize: 26
                    font.bold: true
                }

                Text {
                    text: popup.statusText()
                    color: Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 11
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.cardBorder
        }

        // ── Power mode ────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                text: Icons.performance
                color: Theme.yellow
                font.family: Theme.font
                font.pixelSize: 12
            }

            Text {
                Layout.fillWidth: true
                text: "Power mode"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 12
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 42
            radius: Theme.controlRadius
            color: Theme.surface0

            RowLayout {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 3

                Repeater {
                    model: [
                        { "label": "Saver", "icon": Icons.leaf, "profile": PowerProfile.PowerSaver, "accent": Theme.green, "enabled": true },
                        { "label": "Balanced", "icon": Icons.balanced, "profile": PowerProfile.Balanced, "accent": Theme.blue, "enabled": true },
                        { "label": "Performance", "icon": Icons.performance, "profile": PowerProfile.Performance, "accent": Theme.peach, "enabled": PowerProfiles.hasPerformanceProfile }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.controlRadius - 2
                        color: (PowerProfiles.profile === modelData.profile)
                            ? Qt.rgba(modelData.accent.r, modelData.accent.g, modelData.accent.b, 0.22)
                            : (modeHover.hovered && modelData.enabled ? Theme.hover : "transparent")
                        opacity: modelData.enabled ? 1 : 0.4
                        Behavior on color { ColorAnimation { duration: 120 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                color: PowerProfiles.profile === modelData.profile ? modelData.accent : Theme.subtext0
                                font.family: Theme.font
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                color: PowerProfiles.profile === modelData.profile ? Theme.text : Theme.subtext0
                                font.family: Theme.font
                                font.pixelSize: 10
                            }
                        }

                        HoverHandler { id: modeHover }
                        MouseArea {
                            anchors.fill: parent
                            enabled: modelData.enabled
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: PowerProfiles.profile = modelData.profile;
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.cardBorder
        }

        // ── Details ───────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Battery health"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: 12
            }

            Text {
                visible: popup.device && popup.device.healthSupported
                text: (popup.device && popup.device.healthSupported)
                      ? Math.round(popup.device.healthPercentage * 100) + "%" : ""
                color: Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 12
            }
        }
    }
}
