#!/bin/bash

# Get the window ID of the currently focused window
win_id=$(xdotool getwindowfocus)

# Get the process ID (PID) of the application associated with this window
pid=$(xprop -id "$win_id" _NET_WM_PID | awk '{print $3}')

# Check if PID was found
if [ -n "$pid" ]; then
    # Force kill the application by PID
    kill -9 "$pid"
fi
