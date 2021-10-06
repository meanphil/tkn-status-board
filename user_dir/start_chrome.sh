#!/bin/sh

export DISPLAY=:0

set -e
sleep 5

chrome \
    --disable \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --autoplay-policy=no-user-gesture-required \
    --start-fullscreen \
    --app=http://10.10.10.121:8080/  &

