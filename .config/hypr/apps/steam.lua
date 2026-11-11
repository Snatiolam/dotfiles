-- Steam: child windows (Friends List, settings, dialogs) float, while the
-- main client stays in the tiling layout.
--
-- Steam's client and its child windows all share the "steam" class, so the
-- float rule catches everything and the later "tile" rule opts the main
-- window back into tiling. Static rules are applied in registration order,
-- so the last match wins.
--
-- Games launched through Steam use the "steam_app_<id>" class, so they are
-- not affected: they keep tiling/fullscreening as usual.
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
