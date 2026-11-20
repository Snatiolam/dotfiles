----------------------------
---- TILING KEYBINDINGS ----
----------------------------

local mod = require("hypr.settings").mod

hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mod .. " + TAB",          hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + SHIFT + TAB",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mod .. " + CTRL + TAB",   hl.dsp.focus({ workspace = "previous_per_monitor" }))

-- Going back lowers the window it leaves: raising the one it lands on would
-- ping-pong, since bring_to_top reorders the list cycle_next walks.
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.alter_zorder({ mode = "bottom" }))
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))
hl.bind("ALT + TAB",         hl.dsp.window.bring_to_top())

hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
