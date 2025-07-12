#!/bin/bash
first_wall=$(find "/home/$USER/Pictures/Wallpapers" -type f | sort -R | head -n 1)
wal -i "$first_wall" -n -a 92 -q
(killall i3bar && i3bar) &
"$HOME/.config/i3/src/dunst.sh" &
feh --bg-fill "$first_wall"
