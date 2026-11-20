#!/usr/bin/env bash
# Turns idle locking off or on for this session; hypridle starts again at login.

if pkill -x hypridle; then
  notify-send -a "Idle" "Idle lock off"
else
  setsid hypridle >/dev/null 2>&1 &
  notify-send -a "Idle" "Idle lock on"
fi
