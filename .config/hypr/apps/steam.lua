-- The client and its child windows share one class: float them all, then tile
-- the main window (the last matching rule wins).
hl.window_rule({
    name  = "steam-float",
    match = { class = "^steam$" },

    float        = true,
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name  = "steam-main-tiled",
    match = { class = "^steam$", title = "^Steam$" },

    tile = true,
})

hl.window_rule({
    name  = "steam-friends",
    match = { class = "^steam$", title = "^Friends List$" },

    size = "460 800",
})
