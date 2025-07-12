 	#z4h settings 
	zstyle ':z4h:' auto-update      'no'
	zstyle ':z4h:' auto-update-days '28'
	zstyle ':z4h:bindkey' keyboard  'pc'
	zstyle ':z4h:' prompt-at-bottom 'no'
	zstyle ':z4h:' term-shell-integration 'yes'
	zstyle ':z4h:autosuggestions' forward-char 'accept'
	zstyle ':z4h:fzf-complete' recurse-dirs 'no'
	zstyle ':z4h:direnv'         enable 'no'
	zstyle ':z4h:direnv:success' notify 'yes'
	if [ "$ZSH_ISOLATE" -eq  "0" ]; then
		zstyle ':z4h:' start-tmux command ""
	else
		zstyle ':z4h:' start-tmux command tmux -u -f ~/.config/i3/conf/tmux.conf new-session -A
	fi
	# Only show fastfetch if not already inside tmux, and not being launched by z4h for tmux

	get_remaining_lines() {
		local pos
		pos=$(tmux display-message -p '#{cursor_y}')
		echo $(( LINES - pos ))
	}
	stty -echo -icanon
	echo -ne '\033[?25l'

	# define settings for greeter loading
	if [ "$ZSH_ISOLATE" -eq "1" ] && [ -n "$TMUX" ] && [ "$(tmux display-message -p '#{pane_index}')" = "0" ] && [ "$(tmux display-message -p '#{window_index}')" = "0" ] && [ -z "$FASTFETCH_SHOWN" ]; then
			export FASTFETCH_SHOWN=1
			export ABSOLUTE_SWITCH=0
			fastfetch=$(fastfetch --logo arch_old --config "$HOME/.config/i3/conf/fastfetch.jsonc")

			if [[ $(fastfetch | wc -L) -le $(tput cols) ]]; then 
				echo $fastfetch | lolcat -a -s 2000 > /dev/tty
				ABSOLUTE_SWITCH=1
			else
				echo "Terminal too small, change font size"
			fi
			if [[ $ABSOLUTE_SWITCH -eq 1 ]]; then
				read < /dev/tty
			for i in {0..$((
					$(get_remaining_lines)-2
				))}; do 
				echo
			done
		fi
	fi

echo -ne '\e[?25h'
stty sane

z4h init

# custom cd functions for better navigation
export localcd=""
function cd(){
	builtin cd "$@"
	echo "$(pwd)" > ~/.pwd.tmp
}

function n(){
	nvim "$@"
}

function cds(){
	localcd="$(cat ~/.pwd.tmp)"
}
function cdd(){
	cd "$(cat ~/.pwd.tmp)"
}

# move to last cd'd dir
cds
function linecount(){
	ls -R | wc -l
}
function cdr() {
	dirs=(*/)
	[[ $dirs ]] && cd -- "${dirs[RANDOM%${#dirs[@]}]}"
}

# Define aliases.
alias tree='tree -a -I .git'

function ls {
	lsd $@ --color=auto -r -t
}

eval "$(zoxide init zsh)"
