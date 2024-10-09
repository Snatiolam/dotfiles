# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess

from libqtile import bar, layout, qtile, widget, layout
from libqtile import hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from color import colors # My own theme

mod = "mod4"
terminal = guess_terminal()

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    
    # --------- App configs ---------

    Key([mod], "m", lazy.spawn("rofi -show drun"), desc="Launch Menu"),
    Key([mod, "shift"], "m", lazy.spawn("rofi -show"), desc="Launch Window Navigator"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Launch Browser"),
    Key([mod], "e", lazy.spawn("thunar"), desc="Launch File Manager"),
    Key([mod], "s", lazy.spawn("scrot 'screenshot_%Y-%m-%d-%T_$wx$h.png' -e 'mkdir -p ~/images/screenshots/ | mv $f ~/images/screenshots/'")),
    Key([mod, "shift"], "s", lazy.spawn("scrot -s")),

    # --------- System configs ---------
    Key([], "XF86AudioLowerVolume", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ -5%"
    )),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ +5%"
    )),
    Key([], "XF86AudioMute", lazy.spawn(
        "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    )),   
    Key([mod], "Print", lazy.spawn(
        "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    )),   
    Key([mod, "shift"], "Print", lazy.spawn(
        "scrot -s"
    )),   
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


# groups = [Group(i) for i in "123456789"]
groups = [Group(i) for i in [
        "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ",
    ]]


for i, group in enumerate(groups):
    actual_key = str(i + 1)
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                actual_key,
                lazy.group[group.name].toscreen(),
                desc="Switch to group {}".format(group.name),
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                actual_key,
                lazy.window.togroup(group.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(group.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_conf = {
        #'border_normal' : colors["orange"],
        'border_focus' : colors["magenta"],
        'border_width' : 1,
        'margin' : 4,
        }

layouts = [
    layout.Max(),
    layout.Columns(**layout_conf),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)

widget_defaults = dict(
    font="UbuntuMono Nerd Font",
    fontsize=15,
    padding=5,
)
extension_defaults = widget_defaults.copy()

groupbox = widget.GroupBox(
        foreground= colors["cyan"],
        background= colors["black"],
        active = colors["fg"],
        inactive = colors["cyan"],
        fontsize=19,
        margin_x=0,
        margin_y=3,
        padding_x=5,
        padding_y=8,
        borderwidth=1,
        highlight_method = "text",
        highlight_color=[colors["fg"], colors["yellow"]],
        rounded=False,
        disable_drag=True,
        spacing = 5,
        this_current_screen_border = colors["yellow"],
        block_highlight_text_color = colors["white"],
        urgent_alert_method = "line",
        urgent_text = colors["red"],
        urgent_border = colors["red"],
        hide_unused = False,
)

def powerline(fg="fg", bg="bg"):
    return widget.TextBox(
               text="", # Icon: nf-oct-triangle_left
               fontsize=37,
               padding=0,
               foreground = colors[fg],
               background = colors[bg],
            )

screens = [
    Screen(
        wallpaper="~/.config/qtile/rose-pine.png",
        top=bar.Bar(
            [
                groupbox,
                widget.Prompt(),
                powerline(fg="fg_gutter", bg="black"),
                widget.WindowName(background=colors["fg_gutter"]),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),
                widget.Systray(),
                powerline(fg="yellow", bg="fg_gutter"),
                widget.CPU(format="  {freq_current}GHz {load_percent}%", background=colors["yellow"], foreground= colors["bg"]),
                powerline(fg="magenta", bg="yellow"),
                widget.Battery(format=" {char} {percent:2.0%}", background=colors["magenta"], foreground= colors["bg"]),
                powerline(fg="pink", bg="magenta"),
                widget.Net(format="  {interface}: {down:3.0f}{down_suffix:<2}   {up:3.0f}{up_suffix:<2}", background=colors['pink'], interface='wlp2s0'),
                powerline(fg="black", bg="pink"),
                widget.Memory(format=": {MemUsed:.2f}/{MemTotal:.2f}{mm}", measure_mem = "G", background=colors["black"]),
                powerline(fg="pink", bg="black"),
                widget.CurrentLayoutIcon(background=colors["pink"], scale=0.8),
                widget.CurrentLayout(background=colors["pink"]),
                # widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
                powerline(fg="orange", bg="pink"),
                widget.Clock(format="  %d/%m/%Y - %H:%M ", background=colors["orange"]),
                # widget.QuickExit(),
            ],
            24,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.run([home])
