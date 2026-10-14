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

    // A default-sink switch (jack unplug, device selection) always re-shows the
    // new sink's volume, after letting it settle/bind.
    onSinkChanged: osd.deferAudio()

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
    readonly property string backlight: "intel_backlight"
    property int maxBrightness: 0
    property real lastBrightness: -1

    // Writes are serialized: while brightnessctl runs, further slider moves are
    // coalesced into pendingBrightness and applied when it exits. This keeps
    // dragging smooth instead of spawning one process per pixel moved.
    property real pendingBrightness: -1
    property bool applying: false

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + osd.backlight + "/max_brightness"
        blockLoading: true
        onLoaded: {
            const n = parseInt(maxFile.text());
            if (!isNaN(n) && n > 0) osd.maxBrightness = n;
        }
    }

    // sysfs does not emit inotify events, so it cannot be watched. Instead of
    // polling, we read on demand: the compositor's brightness keybinds call
    // `qs ipc call osd refresh` and the control-center slider refreshes on its
    // own, so nothing here keeps the CPU awake while idle.
    FileView {
        id: brightnessFile
        path: "/sys/class/backlight/" + osd.backlight + "/brightness"
        blockLoading: true
        onLoaded: osd.onBrightnessChange()
    }

    // One initial read so the slider shows the real value before any keypress.
    Component.onCompleted: brightnessFile.reload()

    function onBrightnessChange(): void {
        // Ignore reads that race with our own write while it is in flight.
        if (osd.applying || osd.pendingBrightness >= 0) return;
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

    // External control: `qs ipc call osd brightness 70` / `... volume 40`
    IpcHandler {
        target: "osd"

        function brightness(value: string): void {
            osd.brightness = Math.max(0, Math.min(1, parseFloat(value) / 100));
            osd.showBrightness(osd.brightness);
        }

        function volume(value: string): void {
            osd.showVolume(parseFloat(value) / 100, false);
        }

        // Re-read the backlight. Call this after changing brightness externally
        // (e.g. from a Hyprland keybind) so the OSD reflects the real value.
        function refresh(): void {
            brightnessFile.reload();
        }
    }
}
