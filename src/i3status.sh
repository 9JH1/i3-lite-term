#!/bin/bash
source ~/.cache/wal/colors.sh
color_good=$color5 
color_bad=$foreground 
color_degraded=$color6
font="Mononoki Nerd Font"
read -r -d '' tmp << EOM
general {
	colors = true
  interval = 5
	markup = "pango"
	output_format = "i3bar"
	color_good = "$color_good"
	color_bad  = "$color_bad"
	color_degraded = "$color_degraded"
}

order += "wireless _first_"
order += "volume master"
order += "cpu_usage"
order += "load"
order += "memory"
order += "tztime local"

wireless _first_ {
	format_up = "<span>󰖩 %quality</span>"
  format_down = "<span>󰖪 </span>"
} 

load {
  format = "<span> %1min</span>"
	max_threshold = "2.0"
}

memory {
  format = "<span>  %percentage_used</span>"
	threshold_degraded = 75%
	threshold_critical = 25%
}

tztime local {
	format = "<span>%l:%M </span>"
}

volume master {
	format = "<span foreground='$color_bad'>󰕾 %volume</span>"
  format_muted = "<span foreground='$color_good'>󰖁 %volume</span>"
  device = "default"
  mixer = "Master"
  mixer_idx = 0
}

cpu_usage {
	format = "<span> %usage</span>"
	max_threshold = 75
	degraded_threshold = 50
	format_above_threshold = "<span> %usage</span>"
}
EOM
tmp2=$(mktemp --suffix=".conf")
echo "$tmp" >> "$tmp2"
killall i3status
i3status -c "$tmp2" \
	| python /home/$USER/.config/i3/src/i3status.py "/home/$USER/.config/i3/src/playerctl.sh" \
	| python /home/$USER/.config/i3/src/i3status.py "/home/$USER/.config/i3/src/notify.sh"
