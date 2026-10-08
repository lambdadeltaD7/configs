#!/bin/bash



NORMAL_BG="$HOME/.config/themes/current/lockscreen.jpg"
FAIL_BG="$HOME/.config/hypr/res/fail_bg.jpg"

if journalctl --user --since -5sec | grep -q "pam_unix(hyprlock:auth)"; then
    echo "$FAIL_BG"
else
    echo "$NORMAL_BG"
fi
