------------------
---- MONITORS ----
------------------

-- "auto" picks the scale from the monitor PPI, so one config fits every machine.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- The TV only offers 4K at 30 Hz, so run it at 1080p60 for a readable UI.
hl.monitor({
    output   = "desc:LG Electronics LG TV SSCR2 0x01010101",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = 1,
})
