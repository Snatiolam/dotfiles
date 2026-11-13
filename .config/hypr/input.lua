--------------
---- INPUT ----
--------------

hl.config({
    input = {
        kb_layout  = "us,es",
        kb_variant = "",
        kb_model   = "",
        -- Ctrl+Space switches layout, as on macOS (Super+Space is the app
        -- launcher). Other common choices: "grp:alt_shift_toggle" (classic
        -- Windows/Linux) and "grp:caps_toggle" (single key).
        kb_options = "grp:ctrl_space_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
