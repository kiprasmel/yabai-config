#!/bin/bash

# fix-displays.sh
# Universal fix script that detects display count and runs the appropriate fix.
#
# - If 1 display (unplugged): runs fix-unplug.sh
# - If 2+ displays (plugged in): runs fix-plugin.sh
#
# This is the recommended script for manual use or hotkey binding.
#
# Usage: ~/.config/yabai/scripts/fix-displays.sh

SCRIPT_DIR="$HOME/.config/yabai/scripts"

# Get current display count
DISPLAY_COUNT=$(yabai -m query --displays | jq '. | length')

echo "Detected $DISPLAY_COUNT display(s)"

if [ "$DISPLAY_COUNT" -eq 1 ]; then
    echo "Single display detected - running fix-unplug.sh"
    exec "$SCRIPT_DIR/fix-unplug.sh"
else
    echo "Multiple displays detected - running fix-plugin.sh"
    exec "$SCRIPT_DIR/fix-plugin.sh"
fi
