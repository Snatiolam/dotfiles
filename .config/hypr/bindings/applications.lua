--------------------------------
---- APPLICATION KEYBINDINGS ----
--------------------------------

local settings = require("hypr.settings")
local launch_or_focus = require("hypr.launch").launch_or_focus
local mod = settings.mod

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(settings.terminal), { description = "Terminal" })
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("qs ipc call launcher toggle"), { description = "App launcher" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(settings.file_manager), { description = "File manager" })
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(settings.browser), { description = "Browser" })
hl.bind(mod .. " + C",      launch_or_focus("io.github.Qalculate.qalculate-qt", settings.calculator), { description = "Calculator" })
hl.bind(mod .. " + D",      hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mod .. " + ALT + D", launch_or_focus("discord", settings.discord), { description = "Discord" })
hl.bind(mod .. " + L",      hl.dsp.exec_cmd("qs ipc call lock lock"), { description = "Lock screen" })
hl.bind(mod .. " + M",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), { description = "Exit Hyprland" })

hl.bind(mod .. " + K",        hl.dsp.exec_cmd("qs ipc call picker toggle keybinds"), { description = "Show keybindings" })
hl.bind(mod .. " + CTRL + V", hl.dsp.exec_cmd("qs ipc call picker toggle clipboard"), { description = "Clipboard history" })
hl.bind(mod .. " + CTRL + I", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/idle-toggle.sh"), { description = "Toggle idle lock" })
