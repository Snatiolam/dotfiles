# Snatiolam Dotfiles & Configs

![i3-preview](.screenshots/preview.png)

***Quick links***
- [i3wm-config](.config/i3/config)
- [vimfile](.vimrc)
- [polybar](.config/polybar/config)

# Table of contents
- [Software](#software-i-use)
  - [Basic utilities](#basic)
  - [Fonts, theming and GTK](#theming)
  - [Apps](#apps)

# Software I Use

## Basic

| Software                                                              | Utility                                      |
| --------------------------------------------------------------------- | -------------------------------------------- |
| [networkmanager](https://wiki.archlinux.org/index.php/NetworkManager) | Managing network                             |
| network-manager-applet                                                | networkmanager tray                          |
| pulseaudio                                                            | Proxy for sound/sound system                 |
| pavucontrol                                                           | GUI for pulse audio                          |
| [udiskie](https://wiki.archlinux.org/index.php/udisks)                | Wrapper of udisks for automount              |
| [dunst](https://wiki.archlinux.org/index.php/Dunst)                   | Notification system                          |
| [lightdm](https://wiki.archlinux.org/title/LightDM)                   | Display Manager (Login)                      |
  
---
**NOTE**

If you are using pulseaudio in an Asus Zenbook machine please read this: [Asus Zenbook UX390](https://wiki.archlinux.org/title/ASUS_Zenbook_UX390_(Espa%C3%B1ol))

Configure .xprofile since your ~/.xinitrc won't be loaded if you are using lightdm

---


## Theming

| Software                                                        | Utility                         |
| --------------------------------------------------------------- | ------------------------------- |
| feh                                                             | CLI for setting wallpapers      |
| picom                                                           | Compositor for Xorg             |
| lxappearance                                                    | GUI for changing themes         |
| [Material-Black-Cherry](https://www.gnome-look.org/p/1316887/)  | GTK-Theme                       |
| [Material-Black-Cherry-Numix](https://www.pling.com/p/1333360/) | GTK-Icons                       |

## Apps

| Software                                                              | Utility                          |
| --------------------------------------------------------------------- | -------------------------------- |
| Alacritty                                                             | Terminal emulator                |
| Vim / Neovim                                                          | Best editor ever                 |
| [maim](https://github.com/naelstrof/maim)                             | Take screenshots                 |
| redshift                                                              | Eye care                         |
| ranger                                                                | Terminal file manager            |
| thunar                                                                | GUI file manager                 |
| [mpd](https://wiki.archlinux.org/index.php/Music_Player_Daemon)       | music player daemon              |
| ncmpcpp                                                               | Client for mpd                   |
| [OpenShot](https://www.openshot.org/)                                 | Video Editor                     |
| [SongRec](https://github.com/marin-m/SongRec)                         | Song recognition (Shazam client) |
| [OBS](https://obsproject.com/)                                        | Screen recording / streaming     |
