#!/bin/bash

# URL of the Rick Astley video
VIDEO_URL="https://www.youtube.com/watch?v=EHKCJyEb1uA"

# Function to set volume using amixer (ALSA)
set_volume_amixer() {
    echo "Using amixer to set volume..."
    amixer sset Master 100% > /dev/null
}

# Function to set volume using pactl (PulseAudio)
set_volume_pactl() {
    echo "Using pactl to set volume..."
    pactl set-sink-volume @DEFAULT_SINK@ 100%
}

# Function to open the Rick Astley video
open_video() {
    echo "Opening the Rick Astley video..."
    xdg-open "$VIDEO_URL"
}

# Main loop to execute every 15 seconds
while true; do
    # Detect which volume control tool is available
    if command -v amixer &> /dev/null; then
        # amixer is available
        set_volume_amixer
    elif command -v pactl &> /dev/null; then
        # pactl is available
        set_volume_pactl
    else
        echo "No volume control tool found. Please install amixer or pactl."
        exit 1
    fi

    # Open the Rick Astley video
    open_video

    # Wait for 15 seconds before the next iteration
    sleep 15
done
