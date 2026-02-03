#!/bin/bash

# Function to get current volume
get_vol() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po "[0-9]+(?=%)" | head -1
}

# Function to check if muted
is_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"
}

case $1 in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
esac

# Send the notification
if is_muted; then
    notify-send -h string:x-canonical-private-synchronous:volume "Muted" -i audio-volume-muted -t 800
else
    VOL=$(get_vol)
    notify-send -h string:x-canonical-private-synchronous:volume -h int:value:"$VOL" "Volume: ${VOL}%" -i audio-volume-high -t 800
fi
