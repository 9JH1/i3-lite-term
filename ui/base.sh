#!/bin/bash

# handle arguments
out=$($HOME/.config/i3/ui/libs/base $@)
if [[ "$?" = "1" ]];then 
	$HOME/.config/i3/ui/libs/base $@
	exit
fi

eval set -- $out

geo_x=$1
geo_y=$2
wid_r=$3 
wid_c=$4
fnt_s=$5
prg_c=$6

echo Geo_x: $geo_x
echo Prg_c: $prg_c


# spawn st with unique identifyer
UNIQUE_TITLE="st-$(date +%s%N)"
i3-msg "[class=\"floating_menu_i3\"] floating enable" &>/dev/null
st -t "$UNIQUE_TITLE" -g $geo_x'x'$geo_y -f "Mononoki Nerd Font:size=12" -c "floating_menu_i3" -e "sh" -c "$prg_c"&>/dev/null &

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

# count++
	count=$((count+1))
done

# set st geometry
wmctrl -i -r "$window_id" -e 0,"$geo_x","$geo_y",-1,-1
echo "finished successfully!"
