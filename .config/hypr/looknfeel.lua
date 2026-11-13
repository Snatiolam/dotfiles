-----------------------
---- LOOK AND FEEL ----
-----------------------

local col_mauve       = "rgba(c6a0f6ee)"
local col_rosewater   = "rgba(f4dbd6ee)"
local col_baseAlpha00 = "rgba(00000000)"

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = {col_mauve, col_rosewater}, angle = 45 },
            inactive_border = col_baseAlpha00,
        },

        resize_on_border = true,
        extend_border_grab_area = 8,
        hover_icon_on_border = true,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Workspaces are not animated: switching or sending a window is instant.
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- A spring keeps its velocity when interrupted; a bezier restarts and jerks.
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 8,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 4.31, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.19, bezier = "linear",       style = "popin 87%" })
-- Clients reflow at once, so animating the frame alone clips their content.
hl.animation({ leaf = "windowsMove",   enabled = false })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.38, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.17, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 2.42, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch",    enabled = false })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.05, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 3.2,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.2,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.43, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.11, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- force_split = 2: new windows always open to the right or below.
hl.config({
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.49,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper   = 0,
        disable_hyprland_logo     = true,
        disable_splash_rendering  = true,
        background_color          = "rgb(000000)",
        disable_scale_notification = true,
        focus_on_activate         = true,
        anr_missed_pings          = 3,
        on_focus_under_fullscreen = 1,
        initial_workspace_tracking = 0,
        -- Lets a restarted Quickshell retake the lock (see LockScreen.qml).
        allow_session_lock_restore = true,
    },

    cursor = {
        hide_on_key_press       = true,
        warp_on_change_workspace = 1,
    },

    binds = {
        hide_special_on_workspace_change = true,
    },
})
