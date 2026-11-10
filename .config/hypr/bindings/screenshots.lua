--------------------------------
---- SCREENSHOT KEYBINDINGS ----
--------------------------------

-- PRINT (fullscreen) and SHIFT+PRINT (selection), copy to clipboard + notify
-- with preview.
hl.bind("print", hl.dsp.exec_cmd("sh -c 'f=$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png; grim \"$f\" && wl-copy -t image/png < \"$f\" && notify-send --hint=string:image-path:\"$f\" -a Screenshot \"Full screenshot\" \"Copied to clipboard\"'"), { locked = true })
hl.bind("SHIFT + print", hl.dsp.exec_cmd("sh -c 'g=\"$(slurp)\"; [ -n \"$g\" ] && f=$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g \"$g\" \"$f\" && wl-copy -t image/png < \"$f\" && notify-send --hint=string:image-path:\"$f\" -a Screenshot \"Selection screenshot\" \"Copied to clipboard\"'"), { locked = true })
