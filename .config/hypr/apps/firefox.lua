-- File dialogs come from xdg-desktop-portal-gtk; match on class because the
-- title arrives after the window maps.
hl.window_rule({
    name  = "firefox-file-dialogs",
    match = { class = "^xdg-desktop-portal-gtk$" },

    float  = true,
    center = true,
    size   = "875 600",
})

-- Extension windows (e.g. NordPass) open with a generic title and get their
-- real one after mapping, which static rules cannot see: float new windows,
-- then keep only the ones titled "Extension:" floating.
local GENERIC_TITLES = { [""] = true, ["Mozilla Firefox"] = true, ["about:blank"] = true }

local function has_generic_title(title)
    return GENERIC_TITLES[title] or title:match("^about:.*Mozilla Firefox$") ~= nil
end

local function settle_extension_window(w)
    local on_title, on_close

    local function stop_watching()
        on_title:remove()
        on_close:remove()
    end

    on_title = hl.on("window.title", function(tw)
        if tw.address ~= w.address or has_generic_title(tw.title) then return end

        stop_watching()

        if tw.title:match("^Extension:") then
            hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
            hl.dispatch(hl.dsp.window.center({ window = tw }))
            hl.dispatch(hl.dsp.focus({ window = tw }))
        else
            hl.dispatch(hl.dsp.window.float({ action = "unset", window = tw }))
        end
    end)

    on_close = hl.on("window.close", function(cw)
        if cw.address == w.address then stop_watching() end
    end)
end

hl.on("window.open", function(w)
    if w.class ~= "firefox" or w.initial_title ~= "Mozilla Firefox" then return end

    -- A lone generic-titled Firefox window is the browser itself starting up.
    if #hl.get_windows({ class = "firefox" }) <= 1 then return end

    hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
    settle_extension_window(w)
end)
