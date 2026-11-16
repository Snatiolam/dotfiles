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
    name  = "steam-big-picture",
    match = { class = "^steam$", title = "^Steam Big Picture Mode$" },

    tile       = true,
    fullscreen = true,
})

-- Big Picture drops out of fullscreen while a game runs and is not restored
-- when the game closes.
local function is_big_picture(w)
    return w.class == "steam" and w.title == "Steam Big Picture Mode"
end

local function restore_big_picture(w)
    if w.fullscreen and w.fullscreen ~= 0 then return end
    hl.dispatch(hl.dsp.window.fullscreen({ action = "set", window = w }))
end

hl.on("window.active", function(w)
    if w and is_big_picture(w) then restore_big_picture(w) end
end)

hl.on("window.close", function()
    for _, w in ipairs(hl.get_windows({ class = "steam" })) do
        if is_big_picture(w) then restore_big_picture(w) end
    end
end)

hl.window_rule({
    name  = "steam-friends",
    match = { class = "^steam$", title = "^Friends List$" },

    size = "460 800",
})
