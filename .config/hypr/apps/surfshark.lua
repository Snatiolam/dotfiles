-- Surfshark opens as a floating window.
--
-- Surfshark is an XWayland client with a fixed window size, so it works
-- better as a floating window than as part of the tiling layout. Opt it out
-- of tiling explicitly instead of relying on the app's own size hints.
hl.window_rule({
    name  = "surfshark-floating",
    match = { class = "^Surfshark$" },
    float = true,
    pin   = false,
})
