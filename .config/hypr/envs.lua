-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Let Qt (quickshell) read the desktop icon theme through GTK.
-- Without this, Qt falls back to "hicolor" (nearly empty) and every themed
-- icon fails to load, so notifications show Quickshell's magenta placeholder
-- instead of the real icon.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- XWayland cannot scale by fractional amounts. Stop Hyprland from rescaling
-- X11 apps (Steam, etc.) so they stay sharp; those apps scale themselves per
-- toolkit.
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
