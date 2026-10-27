#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
STATE_FILE="$STATE_DIR/monitor-mode"

notify() {
  notify-send -a "Monitors" "$1" "$2" 2>/dev/null || true
}

MONITORS="$(hyprctl monitors all -j 2>/dev/null)"

INTERNAL="$(echo "$MONITORS" | jq -r '.[] | select(.name|test("^(eDP|LVDS|DSI)")).name' | head -n1)"
EXTERNAL="$(echo "$MONITORS" | jq -r '.[] | select(.name|test("^(eDP|LVDS|DSI)")|not).name' | head -n1)"

mkdir -p "$STATE_DIR"

if [[ -z "$EXTERNAL" ]]; then
  if [[ -n "$INTERNAL" ]]; then
    hyprctl eval "hl.monitor({ output = '$INTERNAL', mode = 'preferred', position = '0x0', scale = 1.5 })" >/dev/null 2>&1
    # hyprctl monitor "$INTERNAL,preferred,0x0,1.5 2">/dev/null
  fi
  rm -f "$STATE_FILE" 2>/dev/null
  notify "External monitor disconnected" "Laptop mode"
  exit 0
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "extend" > "$STATE_FILE"
fi

MODE="$(cat "$STATE_FILE")"

if [[ "$MODE" == "extend" ]]; then
  # hyprctl monitor "$EXTERNAL,preferred,0x0,1,mirror,$INTERNAL"
  hyprctl eval "hl.monitor({ output = '$EXTERNAL', disabled = false, mode = 'preferred', position = 'auto', scale = 1, mirror = '$INTERNAL' })" >/dev/null 2>&1
  echo "mirror" > "$STATE_FILE"
  notify "Mirror mode" "Copying $INTERNAL into $EXTERNAL screen"
else
  if [[ -n "$INTERNAL" ]]; then
    hyprctl eval "hl.monitor({ output = '$INTERNAL', mode = 'preferred', position = '0x0', scale = 1.5 })" >/dev/null 2>&1
    # hyprctl monitor "$INTERNAL,preferred,0x0,1.5"
  fi
  hyprctl eval "hl.monitor({ output = '$EXTERNAL', disabled = false, mode = 'preferred', position = 'auto-right', scale = 1, mirror = '' })" >/dev/null 2>&1
  # hyprctl monitor "$EXTERNAL,preferred,1920x0,1"
  echo "extend" > "$STATE_FILE"
  notify "Extended mode" "$EXTERNAL to right"
fi
