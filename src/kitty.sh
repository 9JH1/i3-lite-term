#!/bin/bash
isolate=0;
if [ -v $1 ]; then 
	isolate=1;
fi
read -r -d '' KITTY_CONFIG << EOM
include ~/.config/i3/conf/kitty-extra.conf
font_family Mononoki Nerd Font Bold
bold_font MonaspiceRN NFM Bold 
italic_font Victor Mono Bold Italic 
bold_italic_font Victor Mono Bold Italic
font_size 13
disable_ligatures never 

cursor_shape beam
cursor_shape_unfocused underline
cursor_trail 1
cursor_trail_decay 0.1 0.4
cursor_trail_start_threshold 2

scrollback_indicator_opacity 0.1
mouse_hide_wait 0.1

url_style curly
detect_urls yes
show_hyperlink_targets yes

confirm_os_window_close 0
initial_window_width  85c 
initial_window_height 23c 
remember_window_size no 
allow_remote_control yes
background_blur 0
EOM

KITTY_PATH="/home/$USER/.config/i3/conf/kitty.conf"
KITTY_COLORS=$(cat /home/$USER/.cache/wal/colors-kitty.conf | grep -v "background_opacity")
echo "$KITTY_CONFIG" > "$KITTY_PATH"
echo "$KITTY_COLORS" >> "$KITTY_PATH"
killall -SIGUSR1 kitty

if [ "$1" = "no-run" ]; then
	exit
fi 

if [ -v $1 ]; then 
	kitty --config="$KITTY_PATH" /bin/sh -c "export ZDOTDIR=/home/$USER/.config/i3/conf/ && export ZSH_ISOLATE=$isolate && zsh"

else 
	kitty --config="$KITTY_PATH" --class="isolated_terminal" /bin/sh -c "bash --rcfile $HOME/.config/i3/conf/bashrc"
fi
