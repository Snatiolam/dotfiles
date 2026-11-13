-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- The watchdog restarts Quickshell after monitor hotplug (0.3.2 does not
    -- remap its windows) and on crashes.
    hl.exec_cmd("hyprpaper & $HOME/.config/hypr/scripts/quickshell-watchdog.py")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- Dark mode for GTK4 apps; GTK3 is set in gtk-3.0/settings.ini.
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
end)
