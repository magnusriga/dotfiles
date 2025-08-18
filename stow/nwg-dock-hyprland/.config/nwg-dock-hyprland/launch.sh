#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

cd "$HOME" || exit
if [ ! -f "$HOME"/.config/hypr/settings/dock-disabled ]; then
  killall nwg-dock-hyprland
  sleep 0.5
  nwg-dock-hyprland -i 32 -w 5 -mb 10 -ml 10 -mr 10 -x -s style.css -c "wofi --show=drun"
else
  killall nwg-dock-hyprland 2>/dev/null
  echo ":: Dock disabled"
fi
