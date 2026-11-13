# AGENTS.md

Personal dotfiles for an Arch Linux system running **Hyprland + Quickshell**
on Wayland. The owner configures the system by hand and likes it that way.

## Language

All code, comments, commit messages and documentation are written in **English**.

## What is active and what is legacy

Active (maintain and extend these):

- Hyprland (`.config/hypr`), written in Lua
- Quickshell (`.config/quickshell`), written in QML (+ small Python helpers)
- Ghostty (`.config/ghostty`)
- Thunar (file manager; Hyprland window rules in `.config/hypr/apps/thunar.lua`)

Legacy (do not edit unless explicitly asked): everything X11-based, plus
kitty and sway. In the repo that means `.config/i3`, `.config/i3blocks`,
`.config/polybar`, `.config/sway`, `.config/kitty`, `.Xresources`, `.vimrc`,
and the X11-era scripts in `.local/bin`.

Not classified by the owner (ask before assuming): `.config/nvim`, `.zshrc`,
`.tmux.conf`, `.config/waybar`, `.config/rofi`, `.config/fastfetch`,
`.config/sddm`, `.config/tuigreet`, `.config/uwsm`, `firefox/policies.json`.

## Repository layout

The repo mirrors `$HOME`: `.config/<app>` here maps to `~/.config/<app>`.

- `setup.sh`: installer (see below)
- `packages.txt`: official-repo packages, one per line, `#` comments
- `aur-packages.txt`: AUR-only packages, same format
- `.config/hypr/`
  - `hyprland.lua`: entry point, kept small; only `require`s modules
  - `bootstrap.lua`: clears the Lua module cache (prefix `hypr`) so each
    `hyprctl reload` picks up edits
  - `monitors.lua`, `envs.lua`, `looknfeel.lua`, `input.lua`, `windows.lua`,
    `bindings.lua`, `autostart.lua`, `permissions.lua`, `settings.lua`:
    one concern per file
  - `bindings/`: `applications`, `tiling`, `media`, `screenshots`, `monitors`
  - `apps/`: per-app window rules (firefox, steam, surfshark, thunar),
    required from `windows.lua`
  - `scripts/`: `quickshell-watchdog.py` (supervises Quickshell, restarts it
    after monitor hotplug or crash; started from `autostart.lua`),
    `monitor-toggle.sh`
- `.config/quickshell/`
  - `shell.qml`: entry point; mounts `Bar`, `OsdOverlay`, `Toast`,
    `NotificationCenter`, `PowerMenu`, `Launcher`, `LockScreen` and runs the
    BlueZ pairing agent (`scripts/bt-agent.py`)
  - `config/`: singletons (`Theme`, `Ui`, `Icons`, `Notifs`, `Osd`)
  - `components/`: reusable widgets
  - `modules/`: bar modules and overlays; `modules/popups/` for popups
  - `pam/password.conf`: PAM config used by the lock screen

## Conventions

Hyprland Lua:
- Config uses the `hl.*` API (`hl.bind`, `hl.exec_cmd`, `hl.env`, `hl.config`,
  `hl.monitor`, `hl.on`). Modules are loaded with `require("hypr.<module>")`.
- Shared values (`mod`, `terminal`, `browser`, ...) live in `settings.lua`.
- Files start with a boxed `-----` section header and use explanatory comments.
  Comments explain the *why* (e.g. workarounds), not just the what.
- Keep `hyprland.lua` minimal; add new concerns as new modules.
- `monitors.lua` uses `scale = "auto"` on purpose so the same config works
  across machines; do not pin values unless asked.

Quickshell QML:
- Colors, fonts and metrics come from the `Theme` singleton (Catppuccin
  Macchiato). Do not hard-code colors in modules.
- Popup state goes through the `Ui` singleton: only one popout open at a
  time (`Ui.togglePopout("<name>")`).
- Imports use `qs.config`, `qs.components`, `qs.modules`.
- Files start with a short comment describing what the component does.
- The Quickshell version in use is 0.3.2; several workarounds in the repo
  exist because of its limitations (documented inline). Keep those comments.

Shell scripts: `setup.sh` uses `set -euo pipefail`, helper functions
(`die`, `check_command`) and is meant to be idempotent and safe to re-run.

## Setup and deployment

`setup.sh` **copies** configs (`cp -r`) into `$HOME`; it does not symlink
(`install_config_dir` asks before deleting an existing destination). Options:
`--packages`, `--yay`, `--aur`, `--git`, `--hypr`, `--ghostty`, `--gtk`,
`--fastfetch`, `--tuigreet`, `--nvim`, `--zsh`, `--tmux`, `--vim`, `--fonts`,
`--bin`, `--firefox`, `--all`, `--help`. With no arguments it runs
interactively.

Because the deployed copies in `~/.config` are separate from the repo,
**when changing an active config, edit both** the repo file and the matching
file under `~/.config`, and keep them identical. Do not run `setup.sh`
to sync, since it can delete the existing directory.

When adding a package, add it to `packages.txt` (official repos) or
`aur-packages.txt` (AUR), not to `setup.sh`.

## Validation

There are no tests or linters. Changes are checked by reloading and looking:
`hyprctl reload` for Hyprland; Quickshell is supervised by the watchdog and
the owner checks the result visually. Do not claim a UI change works unless
it was actually observed.

## Git

- Never commit or push unless explicitly asked.
- When asked, use short English messages in the imperative style of the
  existing history (e.g. "Quick watchdog", "Powermenu").
- The README documents the software list and install steps; update it when
  adding or removing something it describes.
