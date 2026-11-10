---------------------------
---- MEDIA KEYBINDINGS ----
---------------------------

-- Laptop multimedia keys for volume and LCD brightness.
-- One `qs ipc call osd <cmd>` per keypress: quickshell applies the step over
-- its live PipeWire connection (volume) or its coalesced sysfs writer
-- (brightness) and shows the OSD itself, so no sh/wpctl/brightnessctl is
-- spawned per repeat while the key is held. Mic mute keeps wpctl because the
-- OSD tracks only the default sink.
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("qs ipc call osd volup"),      { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("qs ipc call osd voldown"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("qs ipc call osd mute"),       { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("qs ipc call osd brightup"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call osd brightdown"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
