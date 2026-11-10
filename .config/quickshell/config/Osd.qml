pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// OSD state. Listens to real volume (Pipewire) and brightness (backlight
// sysfs) changes, applies the multimedia-key steps itself (one IPC call per
// keypress, no external processes), and exposes extra control through
// `qs ipc call osd`.
Singleton {
    id: osd

    // Displayed state
    property bool visible: false
    property string kind: "volume"   // "volume" | "brightness"
    property real value: 0           // 0..1
    property bool muted: false

    // Current backlight fraction (0..1), updated by the watcher.
    property real brightness: 0

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

    // ── Backlight listener (brightness) ───────────────────────────
    // The device name differs per machine (intel_backlight, acpi_video0,
    // amdgpu_bl0, ...), so it must be detected at startup. Hardcoding one name
    // makes the slider and OSD stay at 0% on any machine using another device.
    property string backlight: ""
    property int maxBrightness: 0
    property real lastBrightness: -1

    function applyBacklight(name: string): void {
        if (!name || name === osd.backlight) return;
        osd.backlight = name;
        // The FileView paths follow `backlight`; re-read both files so the
        // value shows immediately after detection.
        maxFile.reload();
        brightnessFile.reload();
    }

    Process {
        id: blDetect
        running: false
        command: ["sh", "-c", "ls -1 /sys/class/backlight | head -1"]
        stdout: StdioCollector {
            onStreamFinished: osd.applyBacklight(this.text.trim())
        }
    }

    // Writes are serialized: while brightnessctl runs, further slider moves are
    // coalesced into pendingBrightness and applied when it exits. This keeps
    // dragging smooth instead of spawning one process per pixel moved.
    property real pendingBrightness: -1
    property bool applying: false

    FileView {
        id: maxFile
        path: osd.backlight ? ("/sys/class/backlight/" + osd.backlight + "/max_brightness") : ""
        blockLoading: true
        onLoaded: {
            const n = parseInt(maxFile.text());
            if (!isNaN(n) && n > 0) osd.maxBrightness = n;
        }
    }

    // sysfs does not emit inotify events, so it cannot be watched. Instead of
    // polling, we read on demand: after every write settles, and when
    // `qs ipc call osd refresh` is called for changes made by external tools,
    // so nothing here keeps the CPU awake while idle.
    FileView {
        id: brightnessFile
        path: osd.backlight ? ("/sys/class/backlight/" + osd.backlight + "/brightness") : ""
        blockLoading: true
        onLoaded: osd.onBrightnessChange()
    }

    // Detect the backlight device; `applyBacklight` performs the first read so
    // the slider shows the real value before any keypress.
    Component.onCompleted: blDetect.running = true

    function onBrightnessChange(): void {
        // Ignore reads that race with our own write while it is in flight.
        if (osd.applying || osd.pendingBrightness >= 0) return;
        // The two files load independently, so at startup `brightness` may
        // finish before `max_brightness` and the scale would still be unknown
        // (discarding the read below and leaving the OSD/CC stuck at 0%). Read
        // it synchronously then; it is a one-shot because `maxBrightness` is
        // remembered once set.
        if (osd.maxBrightness <= 0) {
            const m = parseInt(maxFile.text());
            if (!isNaN(m) && m > 0) osd.maxBrightness = m;
        }
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

    // Updates the UI instantly and schedules the actual brightness write.
    function setBrightness(v: real): void {
        v = Math.max(0, Math.min(1, v));
        osd.brightness = v;
        osd.pendingBrightness = v;
        osd.showBrightness(v);
        osd.applyNext();
    }

    function applyNext(): void {
        if (osd.applying || osd.pendingBrightness < 0) return;
        osd.applying = true;
        setBrightProc.command = ["brightnessctl", "set",
            Math.round(osd.pendingBrightness * 100) + "%"];
        osd.pendingBrightness = -1;
        setBrightProc.running = true;
    }

    Process {
        id: setBrightProc
        running: false
        onExited: {
            osd.applying = false;
            osd.applyNext();
            brightnessFile.reload();
        }
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
    readonly property real brightnessStep: 0.10

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

    function stepBrightness(up: bool): void {
        // setBrightness() clamps, shows the OSD and coalesces the sysfs write.
        osd.setBrightness(osd.brightness + (up ? osd.brightnessStep : -osd.brightnessStep));
    }

    // External control. Media keys use the relative steps; anything else
    // (scripts, tests) can set absolute values. `refresh` re-reads the
    // backlight after it was changed with an external tool.
    IpcHandler {
        target: "osd"

        function volup(): void { osd.applyVolume(osd.volumeStep) }
        function voldown(): void { osd.applyVolume(-osd.volumeStep) }
        function mute(): void { osd.toggleMute() }

        function brightup(): void { osd.stepBrightness(true) }
        function brightdown(): void { osd.stepBrightness(false) }

        function brightness(value: string): void {
            osd.brightness = Math.max(0, Math.min(1, parseFloat(value) / 100));
            osd.showBrightness(osd.brightness);
        }

        function volume(value: string): void {
            osd.showVolume(parseFloat(value) / 100, false);
        }

        function refresh(): void {
            brightnessFile.reload();
        }
    }
}
