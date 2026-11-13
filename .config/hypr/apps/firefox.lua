-- Firefox: file dialogs and extension windows as floating popups.
--
-- 1. File dialogs: Firefox routes its open/save/upload pickers through
--    xdg-desktop-portal-gtk, so they arrive as portal windows titled
--    "Open File - <page> — Mozilla Firefox". Every window that portal
--    opens is a dialog, so match on class alone: the portal can map a
--    dialog with an empty title first (the title arrives right after),
--    and static rules only see the title at window creation.
hl.window_rule({
    name  = "firefox-file-dialogs",
    match = { class = "^xdg-desktop-portal-gtk$" },

    float  = true,
    center = true,
    size   = "875 600",
})

-- 2. Extension windows (e.g. the NordPass vault opened from a page's
--    login field). These open with the generic "Mozilla Firefox" title
--    and only get their real "Extension: (...)" title after mapping, so
--    a static window rule cannot catch them: static effects are
--    evaluated once, at open time. Follow the wiki pattern instead:
--    float new generic-titled Firefox windows, wait for the real title,
--    and keep only actual extension windows floating.
--    https://wiki.hypr.land/configuring/code-snippets/
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
