#!/bin/bash

# fix-unplug.sh
# Fixes the space shuffling that occurs when unplugging from an external monitor.
#
# What macOS does on unplug:
#   - Space 11 windows get merged into Space 1
#   - Space 11 (the container) moves to the last position
#   - All spaces 12+ shift back by one index
#
# What this script does:
#   1. Moves the last space back to position 11
#   2. Reads the snapshot and moves windows that belonged to Space 11 back there
#
# Usage: ~/.config/yabai/scripts/fix-unplug.sh

set -e

CACHE_DIR="$HOME/.cache/yabai"
SNAPSHOT_FILE="$CACHE_DIR/space-snapshot.json"
LOG_FILE="$CACHE_DIR/fix-unplug.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

notify() {
    osascript -e "display notification \"$1\" with title \"Yabai Space Fix\""
}

log "=== Starting fix-unplug ==="

# Check if snapshot exists
USE_SNAPSHOT=true
if [ ! -f "$SNAPSHOT_FILE" ]; then
    log "WARNING: No snapshot file found at $SNAPSHOT_FILE"
    log "Will assume all windows in Space 1 belong to Space 11"
    USE_SNAPSHOT=false
fi

# Get current space count
SPACE_COUNT=$(yabai -m query --spaces | jq '. | length')
log "Current space count: $SPACE_COUNT"

if [ "$SPACE_COUNT" -lt 11 ]; then
    log "ERROR: Only $SPACE_COUNT spaces exist, expected at least 11"
    notify "Not enough spaces to fix"
    exit 1
fi

# Step 1: Move the last space back to position 11
# The last space is where Space 11 ended up after macOS shuffled things
log "Step 1: Moving space $SPACE_COUNT to position 11..."

CURRENT_POS=$SPACE_COUNT
TARGET_POS=11

while [ "$CURRENT_POS" -gt "$TARGET_POS" ]; do
    log "  Moving space $CURRENT_POS to prev..."
    if ! yabai -m space "$CURRENT_POS" --move prev 2>&1; then
        log "  Warning: Could not move space $CURRENT_POS"
    fi
    CURRENT_POS=$((CURRENT_POS - 1))
    sleep 0.05
done

log "Space repositioning complete"

# Step 2: Move windows that belonged to Space 11 back to Space 11
log "Step 2: Restoring windows to Space 11..."

if [ "$USE_SNAPSHOT" = true ]; then
    # Get windows that were on space 11 from the snapshot
    WINDOWS_TO_MOVE=$(jq -r 'to_entries[] | select(.value.space == 11) | .key' "$SNAPSHOT_FILE")
else
    # No snapshot - assume all windows currently in Space 1 belong to Space 11
    log "No snapshot available - moving ALL windows from Space 1 to Space 11"
    WINDOWS_TO_MOVE=$(yabai -m query --windows --space 1 | jq -r '.[].id')
fi

if [ -z "$WINDOWS_TO_MOVE" ]; then
    log "No windows to restore to Space 11"
else
    for window_id in $WINDOWS_TO_MOVE; do
        # Check if window still exists
        if yabai -m query --windows --window "$window_id" &>/dev/null; then
            if [ "$USE_SNAPSHOT" = true ]; then
                app_name=$(jq -r ".[\"$window_id\"].app // \"unknown\"" "$SNAPSHOT_FILE")
            else
                app_name=$(yabai -m query --windows --window "$window_id" | jq -r '.app // "unknown"')
            fi
            log "  Moving window $window_id ($app_name) to space 11..."
            if yabai -m window "$window_id" --space 11 2>&1; then
                log "    Success"
            else
                log "    Failed to move window $window_id"
            fi
        else
            log "  Window $window_id no longer exists, skipping"
        fi
        sleep 0.02
    done
fi

log "=== Fix-unplug complete ==="
if [ "$USE_SNAPSHOT" = true ]; then
    notify "Spaces fixed! Windows restored to Space 11"
else
    notify "Spaces fixed! All Space 1 windows moved to Space 11 (no snapshot)"
fi

# Optionally focus space 11 after fixing
# yabai -m space --focus 11
