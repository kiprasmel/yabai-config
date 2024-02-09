#!/bin/zsh

# NOTE: THIS IS FOR SYSTEM-INTEGRITY-PROTECTION.
#
# my config does not need this - if shortcuts aren't working,
# it's skhd -- use ./restart.sh
#

# https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)
# https://github.com/koekeishiya/yabai/discussions/1904

# if disabling system integrity protection:
# 1st install cert
# 2nd create YABAI_SUDOERS file w/ contents generated thru yabai install
# 3rd run this script

# scripting-addition;
# function to update sudoers file
function suyabai () {
    SHA256=$(shasum -a 256 $(which yabai) | awk "{print \$1;}")
	YABAI_SUDOERS="/private/etc/sudoers.d/yabai" 
    if [ -f "$YABAI_SUDOERS" ]; then
        sudo /usr/bin/sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' "$YABAI_SUDOERS"
        echo "sudoers > yabai > sha256 hash update complete"
    else
		echo "sudoers file does not exist yet. Create one before running this script (see output above to generate)."
		exit 1
    fi
}

# check & unpin yabai from brew
if brew list --pinned | grep -q yabai; then
    brew unpin yabai
fi

# set cert & stop yabai services
export YABAI_CERT=yabai-cert
echo "Stopping yabai.."
yabai --stop-service

# reinstall yabai & codesign
echo "Updating yabai.."
brew reinstall koekeishiya/formulae/yabai
codesign -fs "${YABAI_CERT:-yabai-cert}" "$(brew --prefix yabai)/bin/yabai"

# update sudoers file & start yabai
suyabai
echo "Starting yabai.."
yabai --start-service

# pin yabai back to brew
brew pin yabai
if brew list --pinned | grep -q yabai; then
    echo "Yabai pinned to brew"
fi

# Success message
sleep 1
YABAI_V=$(yabai --version)
echo "Your running $YABAI_V"
echo "Yabai update completed successfully."

