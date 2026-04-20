#!/usr/bin/env bash
# Wofi power-profile picker (tuned-ppd).

SCRIPT_DIR="$(cd -- "$(dirname "$BASH_SOURCE")" &>/dev/null && pwd -P)"

current=$("$SCRIPT_DIR/power-profiles.sh" | grep -oP '"alt":"\K[^"]+')

choice=$(printf "Performance\nBalanced\nPower Saver" \
  | wofi --dmenu --prompt "Power ($current)")

case "$choice" in
  "Performance") "$SCRIPT_DIR/power-profiles.sh" set performance ;;
  "Balanced")    "$SCRIPT_DIR/power-profiles.sh" set balanced ;;
  "Power Saver") "$SCRIPT_DIR/power-profiles.sh" set power-saver ;;
esac
