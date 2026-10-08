muted="$(pamixer --default-source --get-mute)"
    level="$(pamixer --default-source --get-volume)"
    icon message
    if [[ "$muted" == "true" || "$level" -eq 0 ]]; then
        notify-send -e -h "string:x-canonical-private-synchronous:volume_notif" \
            -h boolean:SWAYNC_BYPASS_DND:true -u low  \
            " Mic Level:" " Muted"
    else
  
        notify-send -e -h int:value:"$level" -h "string:x-canonical-private-synchronous:volume_notif" \
            -h boolean:SWAYNC_BYPASS_DND:true -u low  \
            " Mic Level:" " ${level}%"
    fi
