#!/bin/bash





geo_x="$1"
geo_y="$2"
wid_r="$3"
wid_c="$4"
fnt_s="$5"
prg_c="$6"


# spawn st with unique identifyer
UNIQUE_TITLE="st-$(date +%s%N)"
i3-msg "[class=$UNIQUE_TITLE] floating enable" &>/dev/null
st -t "$UNIQUE_TITLE" -g $geo_x'x'$geo_y -f "Mononoki Nerd Font:size=12" -c "$UNIGUE_TITLE" -e "sh" -c "$prg_c"&>/dev/null &

# await the st spawn
window_id=""
count=0;
while [[ "$window_id" = "" ]];do 
	
	# timeout dialog
	if [[ $count -gt 50 ]]; then 
		echo "ST took to long to launch"
		echo "Check your settings"
		exit
	fi

	# fetch the window id using xdotool
	window_id=$(xdotool search --name "$UNIQUE_TITLE" | head -n 1);
	echo "Waiting for ST spawn.. $count"

	# count++
	count=$((count+1))
done

# set st geometry
wmctrl -i -r "$window_id" -e 0,"$geo_x","$geo_y",-1,-1
