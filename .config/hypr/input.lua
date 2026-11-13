--------------
---- INPUT ----
--------------

hl.config({
    input = {
        kb_layout  = "us,es",
        kb_variant = "",
        kb_model   = "",
        -- Ctrl+Space switches layout (Super+Space is the launcher).
        kb_options = "grp:ctrl_space_toggle",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,

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
