#!/usr/bin/env bash
# Waybar hardware stats toggle: click once to expand, click again to collapse.

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-hardware-open"
ICON=$'\uf080'  # nf-fa-bar_chart_o

case "${1:-}" in
  toggle)
    if [ -f "$STATE_FILE" ]; then
      rm -f "$STATE_FILE"
    else
      : > "$STATE_FILE"
    fi
    pkill -RTMIN+10 waybar
    exit 0
    ;;
esac

if [ -f "$STATE_FILE" ]; then
  disk=$(df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %')
  mem=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
  cpu=$(top -bn1 2>/dev/null | awk '/^%?Cpu/ {print int($2+$4); exit}')
  text="$ICON  D ${disk}% / C ${cpu}% / M ${mem}%"
  tooltip="Disk / CPU / Memory — click to collapse"
else
  text="$ICON"
  tooltip="Click to show disk / CPU / memory"
fi

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
