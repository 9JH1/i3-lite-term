#!/bin/bash
if [[ "$(playerctl metadata --format '-' 2>/dev/null)" == *-* ]]; then
	raw_title=$(playerctl metadata --format '{{ title }}')
	# Shorten to 10 chars max with ...
	title=$(echo "$raw_title" | awk '{if(length > 25) printf "%.25s...\n", $0; else print}')
	
	echo -e " "
	echo -e "<span font_family='Victor Mono' font_weight='ultrabold' font_style='italic'>"
	echo -e "$title "
	echo -e "</span>"
	
	if [ $(playerctl status) == "Playing" ]; then
		echo -e ""
	else 
		echo -e ""
	fi

else 
	echo "󰝛 "
fi

