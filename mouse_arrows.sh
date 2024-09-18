#!/bin/bash

# Reverses touchpad scroll direction every 5 seconds, and for the X11 display server, it also randomizes the arrow key mappings.

# Detect display server
detect_display_server() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        return 1
    elif [ -n "$DISPLAY" ]; then
        return 0
    else
        echo "Unknown display server"
        exit 1
    fi
}

# Check if xinput is installed
check_xinput() {
    if ! command -v xinput &>/dev/null; then
        echo "Error: xinput is not installed. Please install xinput to use this script."
        exit 1
    fi
}

# Check if gsettings is installed
check_gsettings() {
    if ! command -v gsettings &>/dev/null; then
        echo "Error: gsettings is not installed. Please install gsettings to use this script."
        exit 1
    fi
}

# Save original settings - X11
save_x11_settings() {
    ALL_DEVICES=$(xinput list --id-only --name-only)
    if [ -z "$ALL_DEVICES" ]; then
        echo "No devices found for X11."
        return
    fi
    >/tmp/x11_original_settings.txt # Clear the file before writing
    for DEVICE in $ALL_DEVICES; do
        if xinput list-props "$DEVICE" | grep -q "libinput Natural Scrolling Enabled"; then
            ORIGINAL_SCROLL=$(xinput list-props "$DEVICE" | grep "libinput Natural Scrolling Enabled" | awk '{print $NF}')
            echo "$DEVICE $ORIGINAL_SCROLL" >>/tmp/x11_original_settings.txt
        else
            ORIGINAL_BUTTON_MAP=$(xinput list-props "$DEVICE" | grep "Device Button Mapping" | awk '{print $NF}')
            echo "$DEVICE $ORIGINAL_BUTTON_MAP" >>/tmp/x11_original_settings.txt
        fi
    done
}

# Restore original settings - X11
restore_x11_settings() {
    if [ -f /tmp/x11_original_settings.txt ]; then
        while IFS= read -r LINE; do
            DEVICE_ID=$(echo "$LINE" | awk '{print $1}')
            ORIGINAL_SETTING=$(echo "$LINE" | awk '{print $2}')

            if [ "$ORIGINAL_SETTING" = "1" ] || [ "$ORIGINAL_SETTING" = "0" ]; then
                xinput set-prop "$DEVICE_ID" "libinput Natural Scrolling Enabled" "$ORIGINAL_SETTING"
            else
                xinput set-button-map "$DEVICE_ID" "$ORIGINAL_SETTING"
            fi
        done </tmp/x11_original_settings.txt
        rm /tmp/x11_original_settings.txt
    else
        echo "/tmp/x11_original_settings.txt not found. No settings to restore."
    fi
}

# Reverse scroll direction - X11
reverse_scroll_x11() {
    local DEVICE_ID=$1
    echo "Reversing scroll direction for X11 device ID $DEVICE_ID"
    xinput set-button-map "$DEVICE_ID" 3 2 1 2>/dev/null
}


# Save original settings - Wayland
save_wayland_settings() {
    if command -v gsettings &>/dev/null; then
        ORIGINAL_SETTING=$(gsettings get org.gnome.desktop.peripherals.touchpad natural-scroll)
        if [ $? -eq 0 ]; then
            echo "$ORIGINAL_SETTING" >/tmp/wayland_original_setting.txt
        else
            echo "Failed to retrieve Wayland touchpad settings."
        fi
    else
        echo "gsettings command not found. Cannot save Wayland settings."
    fi
}

# Restore original settings - Wayland
restore_wayland_settings() {
    if [ -f /tmp/wayland_original_setting.txt ]; then
        ORIGINAL_SETTING=$(cat /tmp/wayland_original_setting.txt)
        if [ "$ORIGINAL_SETTING" = "true" ]; then
            gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
        elif [ "$ORIGINAL_SETTING" = "false" ]; then
            gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
        else
            echo "Scroll direction setting not applicable or cannot be restored."
        fi
        rm /tmp/wayland_original_setting.txt
    else
        echo "/tmp/wayland_original_setting.txt not found. No settings to restore."
    fi
}

# Reverse scroll direction - Wayland
reverse_scroll_wayland() {
    CURRENT_SETTING=$(gsettings get org.gnome.desktop.peripherals.touchpad natural-scroll)

    if [ "$CURRENT_SETTING" = "true" ]; then
        gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
    elif [ "$CURRENT_SETTING" = "false" ]; then
        gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    else
        echo "Scroll direction setting not applicable or cannot be toggled."
    fi
}

# Randomize arrow key mappings - X11 only
randomize_arrow_keys() {
    local DEVICE_ID=$1
    ARROWS=$(shuf -e 8 9 10 11 -n 4 | tr '\n' ' ')
    xinput set-button-map "$DEVICE_ID" $ARROWS
}

# Restore arrow key mappings - X11 only
restore_arrow_keys() {
    local DEVICE_ID=$1
    xinput set-button-map "$DEVICE_ID" 1 2 3 4 5 6 7 8 9 10 11 12
}

# Clean up and exit
cleanup() {
    echo " ;) "
    if [ "$WAYLAND_DISPLAY" ]; then
        restore_wayland_settings
    elif [ "$DISPLAY" ]; then
        restore_x11_settings
        ALL_DEVICES=$(xinput list --id-only --name-only)
        if [ -n "$ALL_DEVICES" ]; then
            for DEVICE in $ALL_DEVICES; do
                restore_arrow_keys "$DEVICE"
            done
        fi
    fi
    exit 0
}

trap cleanup SIGINT # On Ctrl+C do cleanup

# Check dependencies and save original settings
detect_display_server
if [ $? -eq 0 ]; then
    # X11
    check_xinput
    save_x11_settings
else
    # Wayland
    check_gsettings
    save_wayland_settings
fi

# Main loop
while true; do
    if [ "$WAYLAND_DISPLAY" ]; then
        # Wayland environment (no arrow key randomization)
        reverse_scroll_wayland
    else
        # X11 environment
        ALL_DEVICES=$(xinput list --id-only --name-only)
        for DEVICE in $ALL_DEVICES; do
            reverse_scroll_x11 "$DEVICE"
            randomize_arrow_keys "$DEVICE"
        done
    fi
    sleep 5 # Repeat every 5 seconds
done
