#!/bin/bash

res=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')
case "$res" in
"English (US)")
echo US
;;
"Russian")
echo RU
;;
esac
