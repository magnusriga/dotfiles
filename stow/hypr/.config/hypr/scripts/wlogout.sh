#!/usr/bin/env bash
# Open wlogout with top/bottom margins of 27% of the focused monitor's logical height.
margin=$(hyprctl -j monitors | jq '.[] | select(.focused) | .height / .scale * 0.27 | floor')
wlogout -b 5 -T "$margin" -B "$margin"
