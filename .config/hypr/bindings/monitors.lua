------------------------------
---- MONITOR KEYBINDINGS ----
------------------------------

local mod = require("hypr.settings").mod

hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/monitor-toggle.sh"))
hl.bind(mod .. " + CTRL + left",  hl.dsp.focus({ monitor = "-1" }))
hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mod .. " + ALT + left",   hl.dsp.window.move({ monitor = "-1" }))
hl.bind(mod .. " + ALT + right",  hl.dsp.window.move({ monitor = "+1" }))
