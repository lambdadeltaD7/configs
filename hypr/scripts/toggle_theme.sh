#!/usr/bin/bash
current=$(caelestia scheme get -m 2>/dev/null)
echo "current=  ${current}"
if [[ $current = dark ]]; then
    caelestia scheme set -m light
else
    caelestia scheme set -m dark
fi
