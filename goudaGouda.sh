#!/bin/bash

# URL of the video
VIDEO_URL=$1

# Function to set volume using amixer (ALSA)
set_volume_amixer() {
    amixer sset Master 100% > /dev/null
}

# Function to set volume using pactl (PulseAudio)
set_volume_pactl() {
    pactl set-sink-volume @DEFAULT_SINK@ 100% > /dev/null
}

# Function to open the video
open_video() {
    xdg-open "$VIDEO_URL" > /dev/null
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
        exit 1
    fi

    # Open the video
    open_video

    # Wait for 5 seconds before the next iteration
    sleep 5
done
