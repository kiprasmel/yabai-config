#!/usr/bin/env bash

open_app() {
	app="/Applications/iTerm.app"
    open -a "$app"
}

# Detects if iTerm2 is running
if ! pgrep -f "iTerm" &>/dev/null; then
	open_app
else
    # Create a new window
    script='tell application "iTerm2" to create window with default profile'
    ! osascript -e "${script}" &>/dev/null && {
        # Get pids for any app with "iTerm" and kill
        while IFS="" read -r pid; do
            kill -15 "${pid}"
        done < <(pgrep -f "iTerm")
		open_app
    }
fi
