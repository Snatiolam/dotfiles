-- The main window stays tiled; its dialogs float (titles verified on Thunar 4.20).
hl.window_rule({
    name  = "thunar-dialogs",
    match = {
        class = "^thunar$",
        title = "^(File Operation Progress|Properties|Open With|Bulk Rename.*|Confirm to replace files)$",
    },

    float  = true,
    center = true,
})
