-- Fixed-size XWayland client: float it.
hl.window_rule({
    name  = "surfshark-floating",
    match = { class = "^Surfshark$" },
    float = true,
    pin   = false,
})
