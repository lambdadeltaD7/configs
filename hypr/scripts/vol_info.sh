#!/usr/bin/env bash
muted="$(pamixer --get-mute)"
level="$(pamixer --get-volume)"

if [[ "$muted" == "true" || "$level" -eq 0 ]]; then
    notify-send -e -h string:x-canonical-private-synchronous:volume_notif \
        -h boolean:SWAYNC_BYPASS_DND:true -u low  \
        " Volume:" " Muted"
else
    notify-send -e -h int:value:"$level" -h string:x-canonical-private-synchronous:volume_notif \
        -h boolean:SWAYNC_BYPASS_DND:true -u low  \
        " Volume Level:" " ${level}%"
fi
