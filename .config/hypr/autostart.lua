-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper & quickshell")
    -- Polkit authentication agent (needed for GUI privilege prompts)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- Dark mode for GTK4 / libadwaita apps (Ghostty, Nautilus, ...): the
    -- freedesktop color-scheme, read through the XDG portal. GTK3 apps
    -- (Thunar, ...) read it differently and are handled by
    -- .config/gtk-3.0/settings.ini; see README "Dark mode".
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
end)
