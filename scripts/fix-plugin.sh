#!/bin/bash

# fix-plugin.sh
# Fixes the space shuffling that occurs when plugging into an external monitor.
#
# What macOS does on plug-in:
#   - A new space appears at index 11
#   - All existing spaces 11+ shift forward by one index (become 12+)
#
# What this script does:
#   - Moves space 11 to the last position
#   - This shifts all spaces 12+ back by one index, restoring their original positions
#
# Usage: ~/.config/yabai/scripts/fix-plugin.sh

set -e

CACHE_DIR="$HOME/.cache/yabai"
LOG_FILE="$CACHE_DIR/fix-plugin.log"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

notify() {
    osascript -e "display notification \"$1\" with title \"Yabai Space Fix\""
}

log "=== Starting fix-plugin ==="

# Get current space count
SPACE_COUNT=$(yabai -m query --spaces | jq '. | length')
log "Current space count: $SPACE_COUNT"

if [ "$SPACE_COUNT" -lt 11 ]; then
    log "Only $SPACE_COUNT spaces exist, nothing to fix"
    notify "Only $SPACE_COUNT spaces - nothing to fix"
    exit 0
fi

# Move space 11 to the last position
# We do this by repeatedly moving it to "next" until it reaches the end
log "Moving space 11 to position $SPACE_COUNT..."

CURRENT_POS=11
TARGET_POS=$SPACE_COUNT

while [ "$CURRENT_POS" -lt "$TARGET_POS" ]; do
    log "  Moving space 11 to next..."
    if ! yabai -m space 11 --move next 2>&1; then
        log "  Warning: Could not move space 11"
        break
    fi
    CURRENT_POS=$((CURRENT_POS + 1))
    sleep 0.05
done

log "=== Fix-plugin complete ==="
notify "Spaces fixed! Space 11 moved to end"
