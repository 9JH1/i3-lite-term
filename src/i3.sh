#!/bin/bash
#set $dpi         15px
dpi=$(cat ~/.config/i3/config | grep "set \$dpi " | awk '{print $3}')
dpi_number=${dpi::-2}

dpi_half=$((dpi_number / 2 ))
dpi_two_thirds=$(( (dpi_number / 3) * 2 ))
gap=$(cat ~/.config/i3/config | grep "set \$dpi_gap" | awk '{print $3}')
gap_number=${gap::-2}

border_size=$(cat ~/.config/i3/config | grep "set \$border_size" | awk '{print $3}')
border_size=${border_size::-2}
