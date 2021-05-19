#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
#echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar bar1 >>/tmp/polybar1.log 2>&1 & disown
#polybar bar2 >>/tmp/polybar2.log 2>&1 & disown

for m in $(polybar --list-monitors | cut -d":" -f1); do
    echo "---" | tee -a /tmp/polybarTop-$m.log /tmp/polybarBottom-$m.log
    MONITOR=$m polybar bottom-bar >> /tmp/polybarBottom-$m.log 2>&1 & disown
    MONITOR=$m polybar top-bar >> /tmp/polybarTop-$m.log 2>&1 & disown
    #MONITOR=$m polybar --reload example &
done

echo "Bars launched..."
