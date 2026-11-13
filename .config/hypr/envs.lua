-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Without this Qt falls back to the near-empty hicolor theme and notification
-- icons fail to load.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- Keep X11 apps sharp instead of letting Hyprland rescale them.
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
