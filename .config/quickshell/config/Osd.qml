pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// OSD state. Listens to real volume (Pipewire) and brightness changes,
// applies the multimedia-key steps itself (one IPC call per keypress, no
// external processes), and exposes extra control through `qs ipc call osd`.
Singleton {
    id: osd

    // Displayed state
    property bool visible: false
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1
    property bool muted: false

    // ── Startup suppression (event-driven, no timers) ────────────
    // PipeWire/WirePlumber are (socket-)activated by quickshell itself, so they
    // come up AFTER it (this session: qs 09:57:02, wireplumber 09:57:04,
    // pipewire 09:57:05) and then deliver the first sink plus its restored
    // volume. Any time-based grace would have to guess how long that takes, and
    // the old 1.2s one expired first — which is why every login popped the OSD.
    // Instead the OSD stays disarmed until the user actually acts: media keys
    // go through `qs ipc call osd volup/voldown/mute/...`, which applies the
    // change and arms the OSD in the same call. Startup can then be as slow
    // as it wants without ever leaking an OSD, and no timer is involved.
    property bool armed: false

    // ── Default sink listener (volume) ────────────────────────────
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    PwObjectTracker {
        objects: osd.sink ? [osd.sink] : []
    }

    Connections {
        target: osd.audio
        // Normal changes are shown immediately so holding the volume key keeps
        // the OSD live. A volume of exactly 0 is the ambiguous case: unplugging
        // USB headphones makes the outgoing node emit a final 0 while it is
        // still `osd.audio`, and the switch to the next sink emits no change of
        // its own. Deferring only the 0 means it is re-read once things settle,
        // from whichever sink is default by then — no flash, no stuck 0%.
        function onVolumesChanged(): void {
            if (osd.audio && osd.audio.volume <= 0.001) osd.deferAudio();
            else osd.onAudioChange();
        }
        function onMutedChanged(): void { osd.onAudioChange(); }
    }

    // A default-sink switch (jack unplug, device selection) re-shows the new
    // sink's volume, after letting it settle/bind. Startup sink events happen
    // while disarmed, so they are ignored without any special casing.
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
        // The new sink may still be binding; retry briefly so we never latch
        // onto its not-yet-populated (0) volume.
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

    // ── Media keys ───────────────────────────────────────────────
    // Hyprland binds every multimedia key to a single `qs ipc call osd <cmd>`
    // and quickshell applies the change itself: volume goes over the already
    // open PipeWire connection (same path as the bar wheel and the
    // control-center slider) and brightness through the coalesced writer above.
    // That is one process spawn per keypress instead of one sh + wpctl +
    // brightnessctl + qs burst per keypress (a held key repeats ~30/s), the
    // OSD shows the target value without waiting for the event roundtrip, and
    // brightness writes still collapse into one brightnessctl while held.
    readonly property real volumeStep: 0.05

    function applyVolume(delta: real): void {
        const a = osd.audio;
        if (!a) return;
        osd.armed = true;
        const next = Math.max(0, Math.min(1, a.volume + delta));
        // Raising above zero unmutes, mirroring the bar wheel and slider.
        const unmute = next > 0 && a.muted;
        const muted = unmute ? false : a.muted;
        a.volume = next;
        if (unmute) a.muted = false;
        // Show the target now; the PipeWire event re-confirms it right after.
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
