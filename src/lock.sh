#!/bin/bash
source "/home/$USER/.cache/wal/colors.sh"
hex="${color3:1}"

if [ ! -v $1 ]; then 
	if [ "$1" = "--image" ];then
		sleep 0.5
		maim -u  /tmp/screen.png 
		i3lock -i /tmp/screen.png 
		rm /tmp/screen.png
	else 
		i3lock -c "$hex" & 
		sleep 1
		systemctl suspend
	fi
else 
	i3lock -c "$hex"
fi

