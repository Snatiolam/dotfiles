pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Volume and brightness OSD. Media keys reach it through `qs ipc call osd <cmd>`.
Singleton {
    id: osd

    property bool visible: false
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1
    property bool muted: false

    // Stays disarmed until the user acts, so slow PipeWire startup (it comes up after
    // Quickshell and delivers the restored volume) never pops the OSD at login.
    property bool armed: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    PwObjectTracker {
        objects: osd.sink ? [osd.sink] : []
    }

    Connections {
        target: osd.audio
        // A volume of exactly 0 is ambiguous (unplugging headphones emits a final 0 from
        // the outgoing node), so it is deferred and re-read once the new sink settles.
        function onVolumesChanged(): void {
            if (osd.audio && osd.audio.volume <= 0.001) osd.deferAudio();
            else osd.onAudioChange();
        }
        function onMutedChanged(): void { osd.onAudioChange(); }
    }

    // Re-shows the new sink's volume once it settles; startup events are ignored while disarmed.
    onSinkChanged: if (osd.armed) osd.deferAudio()

    property int audioRetries: 0

    function deferAudio(): void {
        osd.audioRetries = 0;
        audioDebounce.restart();
    }

    Timer {
        id: audioDebounce
        interval: 100
        onTriggered: osd.onAudioChange();
    }

    function onAudioChange(): void {
        if (!osd.armed || !osd.audio) return;
        // The new sink may still be binding; retry so its unpopulated 0 is never shown.
        if (osd.sink && !osd.sink.ready && osd.audioRetries < 5) {
            osd.audioRetries++;
            audioDebounce.restart();
            return;
        }
        osd.showVolume(osd.audio.volume, osd.audio.muted);
    }

    Connections {
        target: Brightness
        function onAdjusted(v: real): void { osd.showBrightness(v); }
        function onChangedExternally(v: real): void { if (osd.armed) osd.showBrightness(v); }
    }

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

    // One IPC call per key press (held keys repeat ~30/s): volume goes over the open
    // PipeWire connection and brightness through Brightness's coalesced writer.
    readonly property real volumeStep: 0.05

    function applyVolume(delta: real): void {
        const a = osd.audio;
        if (!a) return;
        osd.armed = true;
        const next = Math.max(0, Math.min(1, a.volume + delta));
        // Raising above zero unmutes.
        const unmute = next > 0 && a.muted;
        const muted = unmute ? false : a.muted;
        a.volume = next;
        if (unmute) a.muted = false;
        // Show the target now; the PipeWire event confirms it.
        osd.showVolume(next, muted);
    }

    function toggleMute(): void {
        const a = osd.audio;
        if (!a) return;
        osd.armed = true;
        const muted = !a.muted;
        a.muted = muted;
        osd.showVolume(a.volume, muted);
    }

    IpcHandler {
        target: "osd"

        function volup(): void { osd.applyVolume(osd.volumeStep) }
        function voldown(): void { osd.applyVolume(-osd.volumeStep) }
        function mute(): void { osd.toggleMute() }

        function brightup(): void { Brightness.step(true) }
        function brightdown(): void { Brightness.step(false) }
        function brightness(value: string): void { Brightness.set(parseFloat(value) / 100) }
        function refresh(): void { Brightness.refresh() }
    }
}
