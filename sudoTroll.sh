#!/bin/bash

# Function to prompt for sudo before executing the command
force_sudo() {
    if [ "$BASH_COMMAND" != "" ]; then
        echo "You need to enter your sudo password for this command:"
        sudo -v
        if [ $? -ne 0 ]; then
            echo "Failed to authenticate. Exiting."
            exit 1
        fi
    fi
}

# Set PROMPT_COMMAND to call the force_sudo function before displaying the prompt
export PROMPT_COMMAND='force_sudo'
