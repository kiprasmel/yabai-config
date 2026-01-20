#!/bin/bash

# save-space-snapshot.sh
# Saves current window-to-space mappings to a JSON file.
# Runs on any display configuration to track window positions.

CACHE_DIR="$HOME/.cache/yabai"
SNAPSHOT_FILE="$CACHE_DIR/space-snapshot.json"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Query all windows and create a mapping of windowId -> spaceIndex
# We store the space index (not ID) since that's what we use to restore
yabai -m query --windows | jq -c '
    [.[] | {id: .id, space: .space, app: .app, title: .title}]
    | map({(.id | tostring): {space: .space, app: .app, title: .title}})
    | add
' > "$SNAPSHOT_FILE"

# Uncomment for debugging:
# >&2 echo "$(date): Saved snapshot with $(jq 'keys | length' "$SNAPSHOT_FILE") windows"
