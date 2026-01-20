#!/bin/bash

# toggle-autofix.sh
# Toggle automatic space fixing on monitor plug-in AND unplug.
#
# When enabled: yabai will automatically run:
#   - fix-unplug.sh when a display is removed
#   - fix-plugin.sh when a display is added
#
# When disabled: you must manually run the fix scripts (or use fix-displays.sh)
#
# Usage: ~/.config/yabai/scripts/toggle-autofix.sh

CACHE_DIR="$HOME/.cache/yabai"
FLAG_FILE="$CACHE_DIR/autofix-enabled"
SCRIPT_DIR="$HOME/.config/yabai/scripts"
SIGNAL_LABEL_REMOVED="autofix_display_removed"
SIGNAL_LABEL_ADDED="autofix_display_added"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

notify() {
    osascript -e "display notification \"$1\" with title \"Yabai Autofix\""
}

is_enabled() {
    [ -f "$FLAG_FILE" ] && [ "$(cat "$FLAG_FILE")" = "1" ]
}

enable_autofix() {
    echo "1" > "$FLAG_FILE"
    
    # Add the signals to yabai (remove first to avoid duplicates)
    yabai -m signal --remove "$SIGNAL_LABEL_REMOVED" 2>/dev/null || true
    yabai -m signal --remove "$SIGNAL_LABEL_ADDED" 2>/dev/null || true
    
    yabai -m signal --add label="$SIGNAL_LABEL_REMOVED" event=display_removed action="$SCRIPT_DIR/fix-unplug.sh"
    yabai -m signal --add label="$SIGNAL_LABEL_ADDED" event=display_added action="$SCRIPT_DIR/fix-plugin.sh"
    
    echo "Autofix ENABLED"
    notify "Autofix ENABLED - spaces will auto-fix on plug/unplug"
}

disable_autofix() {
    echo "0" > "$FLAG_FILE"
    
    # Remove both signals from yabai
    yabai -m signal --remove "$SIGNAL_LABEL_REMOVED" 2>/dev/null || true
    yabai -m signal --remove "$SIGNAL_LABEL_ADDED" 2>/dev/null || true
    
    echo "Autofix DISABLED"
    notify "Autofix DISABLED - use fix-displays.sh manually"
}

# Toggle based on current state
if is_enabled; then
    disable_autofix
else
    enable_autofix
fi
