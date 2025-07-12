#!/bin/bash
source ~/.cache/wal/colors.sh
source ~/.config/i3/src/i3.sh
dmenu_run -fn "Mononoki Nerd Font:size=$((dpi_number-2))" -nb "$background" -nf "$color1" -sb "$foreground" -sf "$background" -l 15 && off=1
