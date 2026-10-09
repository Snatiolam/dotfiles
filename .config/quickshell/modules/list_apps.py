#!/usr/bin/env python3
"""Scans desktop entries and writes a TSV for the quickshell launcher.

Output (/tmp/qs_apps.tsv): Name TAB Exec TAB IconPath TAB Comment
"""
import configparser
import glob
import os
import re
import shutil

APP_DIRS = [
    "/usr/share/applications",
    "/usr/local/share/applications",
    os.path.expanduser("~/.local/share/applications"),
    "/var/lib/flatpak/exports/share/applications",
    os.path.expanduser("~/.local/share/flatpak/exports/share/applications"),
]

ICON_BASES = [
    "/usr/share/icons",
    os.path.expanduser("~/.local/share/icons"),
    "/var/lib/flatpak/exports/share/icons",
    os.path.expanduser("~/.local/share/flatpak/exports/share/icons"),
]

ICON_THEMES = ["hicolor", "Papirus", "Tela", "Adwaita", "breeze-dark", "breeze", "elementary"]
ICON_SIZES = ["512x512", "256x256", "128x128", "64x64", "48x48", "32x32", "24x24", "22x22", "16x16"]

OUT = "/tmp/qs_apps.tsv"


def icon_dirs():
    dirs = []
    for base in ICON_BASES:
        for theme in ICON_THEMES:
            for size in ICON_SIZES:
                d = os.path.join(base, theme, size, "apps")
                if os.path.isdir(d):
                    dirs.append(d)
            d = os.path.join(base, theme, "scalable", "apps")
            if os.path.isdir(d):
                dirs.append(d)
    if os.path.isdir("/usr/share/pixmaps"):
        dirs.append("/usr/share/pixmaps")
    return dirs


def resolve_icon(dirs, name):
    if not name:
        return ""
    if name.startswith("/"):
        return name if os.path.exists(name) else ""
    for d in dirs:
        for ext in ("png", "svg", "xpm"):
            p = os.path.join(d, name + "." + ext)
            if os.path.exists(p):
                return p
    return ""


def main():
    dirs = icon_dirs()
    seen = set()
    lines = []
    found = 0
    for base in APP_DIRS:
        if not os.path.isdir(base):
            continue
        for path in glob.glob(base + "/*.desktop"):
            try:
                cp = configparser.ConfigParser(
                    interpolation=None, strict=False, delimiters=("=",)
                )
                with open(path, "r", encoding="utf-8", errors="ignore") as fh:
                    cp.read_file(fh)
            except Exception:
                continue
            if not cp.has_section("Desktop Entry"):
                continue
            sec = cp["Desktop Entry"]
            if sec.get("Type", "").strip().lower() not in ("", "application"):
                continue
            if sec.get("NoDisplay", "false").strip().lower() == "true":
                continue
            name = sec.get("Name", "").strip().splitlines()[0] if sec.get("Name", "").strip() else ""
            execs = sec.get("Exec", "").strip()
            if not name or not execs:
                continue
            key = name.lower() + "\t" + execs
            if key in seen:
                continue
            seen.add(key)
            # Strip desktop field codes: %f %u %U %c %k etc.
            execs = re.sub(r"%\w", "", execs).strip()
            if not execs:
                continue
            icon = resolve_icon(dirs, sec.get("Icon", "").strip())
            comment = sec.get("Comment", "").strip().splitlines()[0] if sec.get("Comment", "").strip() else ""
            lines.append("\t".join((name, execs, icon, comment)))
            found += 1
    lines.sort(key=lambda l: l.lower())
    try:
        with open(OUT, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines))
    except OSError:
        pass
    print(f"{found} apps -> {OUT}")


if __name__ == "__main__":
    main()