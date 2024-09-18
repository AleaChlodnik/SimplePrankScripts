#!/bin/bash

# Check if xdotool is installed
if ! command -v xdotool &> /dev/null; then
    echo "xdotool is required but not installed."
    exit 1
fi

# Interval in seconds (5 minutes)
INTERVAL=300

while true; do
    # Simulate Alt+Tab using xdotool
    xdotool key alt+Tab

    # Wait for the specified interval
    sleep "$INTERVAL"
done
