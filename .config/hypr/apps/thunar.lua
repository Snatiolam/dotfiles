-- Thunar: the file manager window stays tiled (it is a primary app,
-- same as Omarchy treats Nautilus), while its utility dialogs open as
-- floating windows.
--
-- Every Thunar dialog is its own toplevel with class "thunar" and one
-- of these titles (verified against Thunar 4.20): progress, properties,
-- bulk rename, open-with and the replace confirmation. The main window
-- is always titled "<folder> - Thunar", so it never collides.
hl.window_rule({
    name  = "thunar-dialogs",
    match = {
        class = "^thunar$",
        title = "^(File Operation Progress|Properties|Open With|Bulk Rename.*|Confirm to replace files)$",
    },

    float  = true,
    center = true,
})
