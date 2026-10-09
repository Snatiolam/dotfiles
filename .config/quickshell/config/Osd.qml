pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// OSD state. Listens to real volume (Pipewire) and brightness (backlight
// sysfs) changes and exposes functions to trigger it via `qs ipc call osd`.
Singleton {
    id: osd

    // Displayed state
    property bool visible: false
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1
    property bool muted: false

    // Current backlight fraction (0..1), updated by the watcher.
    property real brightness: 0

    // Avoids showing the OSD during startup.
    property bool armed: false
    Timer {
        interval: 1200
        running: true
        onTriggered: osd.armed = true
    }

    // ── Default sink listener (volume) ────────────────────────────
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    PwObjectTracker {
        objects: osd.sink ? [osd.sink] : []
    }

    Connections {
        target: osd.audio
        function onVolumesChanged(): void { osd.onAudioChange(); }
        function onMutedChanged(): void { osd.onAudioChange(); }
    }

    function onAudioChange(): void {
        if (!osd.armed || !osd.audio) return;
        osd.showVolume(osd.audio.volume, osd.audio.muted);
    }

    // ── Backlight listener (brightness) ───────────────────────────
    readonly property string backlight: "intel_backlight"
    property int maxBrightness: 0
    property real lastBrightness: -1

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + osd.backlight + "/max_brightness"
        blockLoading: true
        onLoaded: {
            const n = parseInt(maxFile.text());
            if (!isNaN(n) && n > 0) osd.maxBrightness = n;
        }
    }

    FileView {
        id: brightnessFile
        path: "/sys/class/backlight/" + osd.backlight + "/brightness"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: osd.onBrightnessChange()
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: brightnessFile.reload()
    }

    function onBrightnessChange(): void {
        if (osd.maxBrightness <= 0) return;
        const raw = parseInt(brightnessFile.text());
        if (isNaN(raw)) return;
        const v = Math.max(0, Math.min(1, raw / osd.maxBrightness));
        osd.brightness = v;
        if (Math.abs(v - osd.lastBrightness) < 0.004) return;
        osd.lastBrightness = v;
        if (!osd.armed) return;
        osd.showBrightness(v);
    }

    // Applies a new brightness (0..1) and shows the OSD.
    function setBrightness(v: real): void {
        setBrightProc.command = ["brightnessctl", "set",
            Math.round(Math.max(0, Math.min(1, v)) * 100) + "%"];
        setBrightProc.running = true;
        osd.showBrightness(v);
    }

    Process {
        id: setBrightProc
        running: false
    }

    // ── API ───────────────────────────────────────────────────────
    function showVolume(v: real, m: bool): void {
        osd.kind = "volume";
        osd.value = Math.max(0, Math.min(1, v));
        osd.muted = m;
        osd.visible = true;
        hideTimer.restart();
    }

    function showBrightness(v: real): void {
        osd.kind = "brightness";
        osd.value = Math.max(0, Math.min(1, v));
        osd.muted = false;
        osd.visible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osd.visible = false
    }

    // External control: `qs ipc call osd brightness 70` / `... volume 40`
    IpcHandler {
        target: "osd"

        function brightness(value: string): void {
            osd.showBrightness(parseFloat(value) / 100);
        }

        function volume(value: string): void {
            osd.showVolume(parseFloat(value) / 100, false);
        }
    }
}
