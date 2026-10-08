#!/bin/bash

# Directory to save screenshots
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

# Generate filename with timestamp
FILENAME="Screenshot_$(date +'%Y%m%d_%H%M%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

# Handle arguments
case "$1" in
    --now)
        # Capture the whole screen
        grim "$FILEPATH"
        ;;
    --area)
        # Capture a selected region (exits gracefully if canceled)
        REGION=$(slurp)
        if [ -z "$REGION" ]; then
            exit 0
        fi
        grim -g "$REGION" "$FILEPATH"
        ;;
    *)
        echo "Usage: $0 [--now | --area]"
        exit 1
        ;;
esac

# Check if the screenshot was actually created
if [ -f "$FILEPATH" ]; then
    # Copy to clipboard automatically in the background
    wl-copy < "$FILEPATH"

    # Send notification using SwayNC action capabilities
    # --action=[label]:[command] sets up clickable buttons in the notification card
    notify-send \
        -i "$FILEPATH" \
        -a "Screenshot" \
        --action="Check it out" \
        "Screenshot saved." | while read -r action; do
            echo "$action"
            case "$action" in
                "0")
                    # Open the file using your default image viewer
                    imv $FILEPATH
                    ;;
            esac
        done
else
    notify-send -u critical "Screenshot Failed" "Could not capture the screen."
fi
