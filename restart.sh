#!/bin/sh

# https://github.com/koekeishiya/skhd/issues/74#issuecomment-1668747282

# to check skhd config, do:
# rm /tmp/skhd_$USER.*
# skhd -c ./skhdrc

yabai --stop-service
skhd --stop-service

# --stop-service is asynchronous; wait for processes to exit
# before unlinking lock/socket files they still hold.
for _ in $(seq 1 50); do
	pgrep -x yabai >/dev/null || pgrep -x skhd >/dev/null || break
	sleep 0.1
done

rm -f /tmp/skhd_$USER.* /tmp/yabai_$USER.*

yabai --start-service

if test -n "$DEBUG"; then
	skhd -c ./skhdrc
else
	skhd --start-service
fi
