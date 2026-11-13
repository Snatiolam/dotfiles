--------------------------------
---- APPLICATION KEYBINDINGS ----
--------------------------------

local settings = require("hypr.settings")
local mod = settings.mod

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(settings.terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("qs ipc call launcher toggle")) -- app launcher (macOS/Omarchy style)
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(settings.file_manager))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(settings.browser))
hl.bind(mod .. " + C",      hl.dsp.exec_cmd(settings.calculator)) -- Qalculate!
hl.bind(mod .. " + D",      hl.dsp.exec_cmd("qs ipc call launcher toggle")) -- alias, old muscle memory
hl.bind(mod .. " + L",      hl.dsp.exec_cmd("qs ipc call lock lock")) -- lock screen
hl.bind(mod .. " + M",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
