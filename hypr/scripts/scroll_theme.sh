#!/bin/bash

curr_theme=$(cat "${HOME}/.config/themes/current/name")
cmd="${HOME}/.config/themes/ch_t.sh"

case $curr_theme in
	"blue")
		$cmd violet
		;;
	"violet")
		$cmd pink
		;;
	"pink")
		$cmd blue
		;;
esac

exit 0
