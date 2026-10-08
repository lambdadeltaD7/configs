#!/usr/bin/env bash

brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
notify-send -e \
    -h string:x-canonical-private-synchronous:brightness_notif \
    -h int:value:"$brightness" \
    -u low \
    "Screen" "Brightness: ${brightness}%"
