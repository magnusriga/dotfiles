#!/usr/bin/env bash
# Toggle the active window between recording mode (floating, 1600x900, centered)
# and normal tiled mode.
#
# - Floating at 1600x900: assume recording mode -> untoggle floating (back to tiled).
# - Anything else: apply recording mode.

read -r floating w h < <(hyprctl activewindow -j | jq -r '"\(.floating) \(.size[0]) \(.size[1])"')

if [ "$floating" = "true" ] && [ "$w" = "1600" ] && [ "$h" = "900" ]; then
  hyprctl dispatch togglefloating
else
  hyprctl --batch 'dispatch setfloating active; dispatch resizewindowpixel exact 1600 900,activewindow; dispatch centerwindow'
fi
