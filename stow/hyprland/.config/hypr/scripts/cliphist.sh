#!/usr/bin/env bash
#   ____ _ _       _     _     _
#  / ___| (_)_ __ | |__ (_)___| |_
# | |   | | | '_ \| '_ \| / __| __|
# | |___| | | |_) | | | | \__ \ |_
#  \____|_|_| .__/|_| |_|_|___/\__|
#           |_|
#

case $1 in
d)
  pkill wofi
  sleep 0.1
  cliphist list | wofi --dmenu --prompt="Delete clipboard entry" | cliphist delete
  ;;

w)
  if [ "$(echo -e "Clear\nCancel" | wofi --dmenu --prompt="Clear Clipboard")" == "Clear" ]; then
    cliphist wipe
  fi
  ;;

*)
  pkill wofi
  sleep 0.1
  cliphist list | wofi --dmenu --prompt="Clipboard" | cliphist decode | wl-copy
  ;;
esac
