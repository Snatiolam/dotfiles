-- Hyprland entry point; each concern lives in its own module.

dofile((os.getenv("HOME") or "") .. "/.config/hypr/bootstrap.lua")

require("hypr.monitors")
require("hypr.envs")
require("hypr.looknfeel")
require("hypr.input")
require("hypr.windows")
require("hypr.bindings")
require("hypr.autostart")
require("hypr.permissions")
