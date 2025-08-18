#!/bin/bash
#  _   _                      _               _
# | | | |_   _ _ __  _ __ ___| |__   __ _  __| | ___
# | |_| | | | | '_ \| '__/ __| '_ \ / _` |/ _` |/ _ \
# |  _  | |_| | |_) | |  \__ \ | | | (_| | (_| |  __/
# |_| |_|\__, | .__/|_|  |___/_| |_|\__,_|\__,_|\___|
#        |___/|_|
#

# Remove legacy shaders folder
# if [ -d $HOME/.config/hypr/shaders ]; then
#     rm -rf $HOME/.config/hypr/shaders
# fi

if [[ "$1" == "wofi" ]]; then
  # Open wofi to select Hyprshade filter for toggle.
  options="$(hyprshade ls | sed 's/^[ *]*//')\noff"

  # Open wofi
  choice=$(echo -e "$options" | wofi --dmenu --insensitive --allow-images=false --lines=4 --width=30 --prompt="Hyprshade")
  if [ ! -z "$choice" ]; then
    echo "hyprshade_filter=\"$choice\"" >~/.config/hypr/settings/hyprshade.sh
    if [ "$choice" == "off" ]; then
      hyprshade off
      notify-send "Hyprshade deactivated"
      echo ":: hyprshade turned off"
    else
      notify-send "Changing Hyprshade to $choice" "Toggle shader with SUPER+SHIFT+H"
    fi
  fi

else
  # Toggle Hyprshade based on the selected filter
  hyprshade_filter="blue-light-filter-50"

  # Check if hyprshade.sh settings file exists and load
  if [ -f "$HOME/.config/hypr/settings/hyprshade.sh" ]; then
    source "$HOME/.config/hypr/settings/hyprshade.sh"
  fi

  # Toggle Hyprshade
  if [ "$hyprshade_filter" != "off" ]; then
    if [ -z "$(hyprshade current)" ]; then
      echo ":: hyprshade is not running"
      hyprshade on $hyprshade_filter
      notify-send "Hyprshade activated" "with $(hyprshade current)"
      echo ":: hyprshade started with $(hyprshade current)"
    else
      notify-send "Hyprshade deactivated"
      echo ":: Current hyprshade $(hyprshade current)"
      echo ":: Switching hyprshade off"
      hyprshade off
    fi
  else
    hyprshade off
    echo ":: hyprshade turned off"
  fi
fi
