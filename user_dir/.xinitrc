#!/bin/sh

# Disable screensaver
xset s off

# Turn off power saving
xset -dpms

# Start Chrome
~/start_chrome.sh &

# Run window manager, we need this 
# for Chrome to fullscreen properly and
# hold the X session open
exec openbox
