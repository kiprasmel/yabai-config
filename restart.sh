#!/bin/sh

# https://github.com/koekeishiya/skhd/issues/74#issuecomment-1668747282

# to check skhd config, do:
# rm /tmp/skhd_$USER.*
# skhd -c ./skhdrc

brew services stop yabai
brew services stop skhd

yabai --stop-service
skhd --stop-service

rm /tmp/skhd_$USER.*
rm /tmp/yabai_$USER.*

yabai --start-service

if test -n "$DEBUG"; then
	skhd -c ./skhdrc
else
	skhd --start-service
fi

