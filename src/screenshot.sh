#!/bin/bash
mkdir ~/Pictures/screenshots/
file_path=~/Pictures/screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png
maim -u "$file_path" & # hide cursor
maim -s -u | xclip -selection clipboard -t image/png
