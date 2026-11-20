#!/usr/bin/env bash
# Clipboard history kept in RAM (gone at logout) that skips entries apps mark as secret.
set -euo pipefail

DB="${XDG_RUNTIME_DIR:?}/cliphist.db"
MAX_ITEMS=50

cliphist_db() {
  cliphist -db-path "$DB" -max-items "$MAX_ITEMS" "$@"
}

store() {
  if wl-paste --list-types | grep -qx 'x-kde-passwordManagerHint'; then
    return
  fi
  cliphist_db store
}

watch() {
  wl-paste --type text --watch "$0" store &
  wl-paste --type image --watch "$0" store &
  wait
}

case "${1:-}" in
  store) store ;;
  watch) watch ;;
  list | decode | delete | wipe) cliphist_db "$@" ;;
  *) echo "usage: clipboard.sh store|watch|list|decode|delete|wipe" >&2; exit 1 ;;
esac
