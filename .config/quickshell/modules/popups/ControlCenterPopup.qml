import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.config
import qs.components

// macOS-style control center: quick toggles, playback and sliders.
AnchoredPopup {
    id: cc

    popoutId: "controlcenter"

    implicitWidth: 360
    implicitHeight: col.implicitHeight + Theme.popupPadding * 2

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    // ── Night light state ────────────────────────────────────────
    property bool nightOn: false

    Timer {
        interval: 3000
        running: true
        triggeredOnStart: true
        onTriggered: nightCheck.running = true
    }

    Process {
        id: nightCheck
        command: ["pgrep", "-x", "wlsunset"]
        stdout: StdioCollector {
            onStreamFinished: cc.nightOn = (this.text || "").trim() !== ""
        }
    }

    function toggleNight(): void {
        if (cc.nightOn) nightStop.running = true;
        else nightStart.running = true;
        cc.nightOn = !cc.nightOn;
    }

    Process {
        id: nightStart
        running: false
        command: ["sh", "-c", "setsid wlsunset -t 3000 -T 3100 >/dev/null 2>&1 &"]
    }

    Process {
        id: nightStop
        running: false
        command: ["sh", "-c", "pkill -x wlsunset"]
    }

    // ── Wi-Fi helpers ────────────────────────────────────────────
    readonly property var ccWifi: {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    readonly property string wifiSublabel: {
        if (!Networking.wifiEnabled) return "Off";
        if (cc.ccWifi && cc.ccWifi.connected) {
            const nets = cc.ccWifi.networks.values;
            for (let i = 0; i < nets.length; i++) {
                if (nets[i].connected && nets[i].name) return nets[i].name;
            }
        }
        return "No connection";
    }

    readonly property var btAdapter: Bluetooth.defaultAdapter

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 12

        // ══ Quick toggles ════════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 104
            Layout.fillHeight: false

            Column {
                id: togglesCol
                anchors.left: parent.left
                anchors.top: parent.top
                width: 132
                spacing: 8

                CcTile {
                    width: parent.width
                    height: 48
                    pill: true
                    tileIcon: Icons.wifi
                    label: "Wi-Fi"
                    sublabel: cc.wifiSublabel
                    on: Networking.wifiEnabled
                    accent: Theme.blue
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }

                CcTile {
                    width: parent.width
                    height: 48
                    pill: true
                    tileIcon: Icons.bluetooth
                    label: "Bluetooth"
                    sublabel: (cc.btAdapter && cc.btAdapter.enabled) ? "On" : "Off"
                    on: cc.btAdapter ? cc.btAdapter.enabled : false
                    accent: Theme.sapphire
                    onClicked: {
                        if (cc.btAdapter) cc.btAdapter.enabled = !cc.btAdapter.enabled;
                    }
                }
            }

            PlaybackTile {
                anchors.left: togglesCol.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }

        // ══ Toggle row ═══════════════════════════════════════════
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 8
            rowSpacing: 8

            CcTile {
                Layout.fillWidth: true
                tileIcon: Icons.bellSlash
                label: "Focus"
                on: Notifs.dnd
                accent: Theme.mauve
                onClicked: Notifs.dnd = !Notifs.dnd
            }

            CcTile {
                Layout.fillWidth: true
                tileIcon: Icons.performance
                label: "Turbo"
                on: PowerProfiles.hasPerformanceProfile
                     && PowerProfiles.profile === PowerProfile.Performance
                disabled: !PowerProfiles.hasPerformanceProfile
                accent: Theme.peach
                onClicked: {
                    const next = (PowerProfiles.profile === PowerProfile.Performance)
                                 ? PowerProfile.Balanced : PowerProfile.Performance;
                    PowerProfiles.profile = next;
                }
            }

            CcTile {
                Layout.fillWidth: true
                tileIcon: Icons.moon
                label: "Night"
                on: cc.nightOn
                accent: Theme.yellow
                onClicked: cc.toggleNight()
            }
        }

        // ══ Sliders ══════════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: Icons.brightness
                color: Theme.yellow
                font.family: Theme.font
                font.pixelSize: 15
            }

            Slider {
                Layout.fillWidth: true
                value: Osd.brightness
                accent: Theme.yellow
                onMoved: (v) => Osd.setBrightness(v)
            }

            Text {
                text: Math.round(Osd.brightness * 100) + "%"
                color: Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 11
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: Icons.volumeHigh
                color: Theme.mauve
                font.family: Theme.font
                font.pixelSize: 15
            }

            Slider {
                Layout.fillWidth: true
                value: (cc.audio && cc.audio.volume) ? cc.audio.volume : 0
                accent: Theme.mauve
                onMoved: (v) => {
                    if (cc.audio) {
                        cc.audio.volume = v;
                        if (v > 0 && cc.audio.muted) cc.audio.muted = false;
                    }
                }
            }

            Text {
                text: Math.round((cc.audio ? cc.audio.volume : 0) * 100) + "%"
                color: Theme.subtext0
                font.family: Theme.font
                font.pixelSize: 11
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}