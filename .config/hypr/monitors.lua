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

-- TVs prefer 4K at 30 Hz over HDMI: run them at 1080p60.
local function tame_tv(monitor)
    if not monitor.description:find("TV") then return end

    hl.monitor({
        output   = monitor.name,
        mode     = "1920x1080@60",
        position = "auto",
        scale    = 1,
    })
end

for _, monitor in ipairs(hl.get_monitors()) do tame_tv(monitor) end
hl.on("monitor.added", tame_tv)
