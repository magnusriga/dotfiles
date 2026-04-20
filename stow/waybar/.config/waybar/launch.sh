#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# -----------------------------------------------------
# Prevent duplicate launches: only the first parallel
# invocation proceeds; all others exit immediately.
# -----------------------------------------------------

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------

killall waybar || true
pkill waybar || true
sleep 0.5

# Check if waybar-disabled file exists, launch if not
if [ ! -f "$HOME/.config/waybar/waybar-disabled" ]; then
  HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
  HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar &
else
  echo ":: Waybar disabled"
fi

# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-
