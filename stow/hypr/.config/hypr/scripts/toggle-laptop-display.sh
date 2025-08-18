#!/usr/bin/env bash

# Get number of active monitors
MONITOR_COUNT=$(hyprctl monitors -j | jq '[.[] | select(.disabled == false)] | length')

# Get laptop monitor status
LAPTOP_DISABLED=$(hyprctl monitors -j | jq '.[] | select(.name == "eDP-1") | .disabled')

if [ "$LAPTOP_DISABLED" = "true" ]; then
  # Enable laptop display if it's disabled
  hyprctl keyword monitor eDP-1,preferred,auto,1.6
  notify-send "Display" "Laptop display enabled"
elif [ "$MONITOR_COUNT" -gt 1 ]; then
  # Only disable if there are other monitors active
  hyprctl keyword monitor eDP-1,disable
  notify-send "Display" "Laptop display disabled"
else
  notify-send "Display" "Cannot disable only active monitor" -u critical
fi