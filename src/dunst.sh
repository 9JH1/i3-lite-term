#!/bin/bash
source ~/.config/i3/src/i3.sh
source "$HOME/.cache/wal/colors.sh"
read -r -d '' DUNSTRC << EOM
[global]
font = MonaspiceRN NFM $dpi
markup = full
format = "<b>%s</b>\n<b>%b</b>"
icon_position = left
icon_path = /usr/share/icons/
max_icon_size = 64
show_indicators = false
separator_height = 2
padding = $border_size
frame_width = $border_size
separator_color = frame
shrink = yes
mouse_left_click = do_action
mouse_middle_click = close_current
mouse_right_click = close_current
width = 400
progress_bar = true
progress_bar_min_width = 300
offset = ($((gap_number*2)),$((gap_number*2)))
origin = bottom-right
[urgency_low]
foreground = "${color3}"
background = "${color0}"
frame_color = "${color4}"

[urgency_normal]
foreground = "${color3}"
background = "${color0}"
frame_color = "${color4}"

[urgency_critical]
foreground = "#ffffff"
background = "#ff5050"
frame_color = "#ff0000"
EOM
killall -q dunst
dunst_config_file=$(mktemp)
echo "$DUNSTRC" >  $dunst_config_file
echo "starting dunst"
dunst -config "$dunst_config_file" & 
notify-send "Changed Wallpaper"
