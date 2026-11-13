#!/usr/bin/env bash
# Toggles an external monitor between extended and mirrored mode.
set -euo pipefail

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/monitor-mode"
INTERNAL_PATTERN='^(eDP|LVDS|DSI)'
INTERNAL_SCALE=1.5
EXTERNAL_SCALE=1

notify() {
  notify-send -a "Monitors" "$1" "$2" 2>/dev/null || true
}

find_monitor() {
  local filter="$1"
  hyprctl monitors all -j | jq -r ".[] | select(.name | $filter).name" | head -n1
}

configure_monitor() {
  local output="$1" fields="$2"
  hyprctl eval "hl.monitor({ output = '$output', disabled = false, mode = 'preferred', $fields })" >/dev/null
}

reset_internal() {
  configure_monitor "$1" "position = '0x0', scale = $INTERNAL_SCALE"
}

internal="$(find_monitor "test(\"$INTERNAL_PATTERN\")")"
external="$(find_monitor "test(\"$INTERNAL_PATTERN\") | not")"

mkdir -p "$(dirname "$STATE_FILE")"

if [[ -z "$external" ]]; then
  [[ -n "$internal" ]] && reset_internal "$internal"
  rm -f "$STATE_FILE"
  notify "External monitor disconnected" "Laptop mode"
  exit 0
fi

if [[ -z "$internal" ]]; then
  notify "Monitors" "No internal screen to mirror or extend"
  exit 0
fi

if [[ "$(cat "$STATE_FILE" 2>/dev/null)" == "mirror" ]]; then
  reset_internal "$internal"
  configure_monitor "$external" "position = 'auto-right', scale = $EXTERNAL_SCALE, mirror = ''"
  echo "extend" > "$STATE_FILE"
  notify "Extended mode" "$external to right"
else
  configure_monitor "$external" "position = 'auto', scale = $EXTERNAL_SCALE, mirror = '$internal'"
  echo "mirror" > "$STATE_FILE"
  notify "Mirror mode" "Copying $internal into $external screen"
fi
