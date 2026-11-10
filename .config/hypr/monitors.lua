------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- "auto" lets Hyprland pick the scale from the monitor PPI, so the same config
-- works on a standard-DPI desktop monitor (usually 1) and on a HiDPI display.
-- Pin it to a number only if auto gives an unexpected result on a given screen.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
