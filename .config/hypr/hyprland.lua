-- Hyprland entry point.
--
-- Keep this file small: each concern lives in its own module.
-- bootstrap.lua clears the module cache so every `hyprctl reload`
-- picks up edits in these files.

dofile((os.getenv("HOME") or "") .. "/.config/hypr/bootstrap.lua")

require("hypr.monitors")
require("hypr.envs")
require("hypr.looknfeel")
require("hypr.input")
require("hypr.windows")
require("hypr.bindings")
require("hypr.autostart")
require("hypr.permissions")
