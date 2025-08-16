#!/usr/bin/env bash

# ==========
# Wallpaper selector script for hyprland using wofi
# ==========

WALLPAPER_DIR="$HOME/.config/my/wallpapers"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR not found"
  exit 1
fi

# Check if wofi is available
if ! command -v wofi >/dev/null 2>&1; then
  notify-send "Wallpaper Error" "wofi not found"
  exit 1
fi

# Check if hyprctl is available
if ! command -v hyprctl >/dev/null 2>&1; then
  notify-send "Wallpaper Error" "hyprctl not found"
  exit 1
fi

# Kill any existing wofi instances
pkill wofi 2>/dev/null
sleep 0.1

# Get list of wallpapers (jpg, png, jpeg)
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)

if [ -z "$wallpapers" ]; then
  notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Create wofi menu with just filenames
selected=$(echo "$wallpapers" | sed "s|$WALLPAPER_DIR/||g" | wofi --dmenu --prompt="Select Wallpaper" --height=400 --width=600)

if [ -n "$selected" ]; then
  NEW_WALL="$WALLPAPER_DIR/$selected"

  # Check if selected file exists
  if [ ! -f "$NEW_WALL" ]; then
    notify-send "Wallpaper Error" "Selected wallpaper not found: $NEW_WALL"
    exit 1
  fi

  # Get currently loaded wallpaper
  OLD_WALL=$(hyprctl hyprpaper listloaded 2>/dev/null | head -1)

  # Set new wallpaper
  if hyprctl hyprpaper preload "$NEW_WALL" 2>/dev/null; then
    if hyprctl hyprpaper wallpaper ",$NEW_WALL" 2>/dev/null; then
      # Only unload old wallpaper if we successfully set the new one
      if [ -n "$OLD_WALL" ] && [ "$OLD_WALL" != "$NEW_WALL" ]; then
        hyprctl hyprpaper unload "$OLD_WALL" 2>/dev/null
      fi
      notify-send "Wallpaper Changed" "Set to: $(basename "$NEW_WALL")"
    else
      notify-send "Wallpaper Error" "Failed to set wallpaper"
      exit 1
    fi
  else
    notify-send "Wallpaper Error" "Failed to preload wallpaper"
    exit 1
  fi
fi

