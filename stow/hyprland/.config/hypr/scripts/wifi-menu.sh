#!/usr/bin/env bash

# Option 1: Launch nmtui in a floating terminal window with proper size
# ghostty --class=nmtui-wifi -e nmtui-connect

# Option 2: Use iwgtk if installed (better for menus)
if command -v iwgtk &> /dev/null; then
  iwgtk
else
  # Fallback to nmtui in a properly sized floating window
  ghostty --class=nmtui-wifi --width=80 --height=24 -e nmtui-connect
fi