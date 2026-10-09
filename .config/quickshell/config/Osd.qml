pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// OSD state: listens to real audio changes (Pipewire) and exposes
// functions to trigger it from the bar or via `qs ipc call osd ...`.
Singleton {
    id: osd

    // Displayed state
    property bool visible: false
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1
    property bool muted: false

    // Avoids showing the OSD during startup.
    property bool armed: false
    Timer {
        interval: 1200
        running: true
        onTriggered: osd.armed = true
    }

    // ── Default sink listener ─────────────────────────────────────
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
