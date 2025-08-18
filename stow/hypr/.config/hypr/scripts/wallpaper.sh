#!/usr/bin/env bash
#  _      __     ____
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/
#                /_/       /_/

# Source library.sh
source "$HOME/.config/my/library.sh"

# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

if [ -f ~/.config/hypr/settings/wallpaper_cache ]; then
  use_cache=1
  _writeLog "Using Wallpaper Cache"
else
  use_cache=0
  _writeLog "Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Create cache folder
# -----------------------------------------------------
my_cache_folder="$HOME/.cache/my/hyprland-dotfiles"

if [ ! -d "$my_cache_folder" ]; then
  mkdir -p "$my_cache_folder"
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0

# Cache for generated wallpapers with effects
generatedversions="$my_cache_folder/wallpaper-generated"
if [ ! -d "$generatedversions" ]; then
  mkdir -p "$generatedversions"
fi

# Will be set when waypaper is running
waypaperrunning="$my_cache_folder/waypaper-running"
if [ -f "$waypaperrunning" ]; then
  rm "$waypaperrunning"
  exit
fi

cachefile="$my_cache_folder/current_wallpaper"
blurredwallpaper="$my_cache_folder/blurred_wallpaper.png"
squarewallpaper="$my_cache_folder/square_wallpaper.png"
rasifile="$my_cache_folder/current_wallpaper.rasi"
blurfile="$HOME/.config/my/settings/blur.sh"
defaultwallpaper="$HOME/.config/my/wallpapers/default.jpg"
wallpapereffect="$HOME/.config/hypr/settings/wallpaper-effect.sh"
blur="50x30"
blur=$(cat "$blurfile")

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z "$1" ]; then
  if [ -f "$cachefile" ]; then
    wallpaper=$(cat "$cachefile")
  else
    wallpaper=$defaultwallpaper
  fi
else
  wallpaper=$1
fi
used_wallpaper=$wallpaper
_writeLog "Setting wallpaper with source image $wallpaper"
tmpwallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f "$cachefile" ]; then
  touch "$cachefile"
fi
echo "$wallpaper" >"$cachefile"
_writeLog "Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------

wallpaperfilename=$(basename "$wallpaper")
_writeLog "Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

if [ -f "$wallpapereffect" ]; then
  effect=$(cat "$wallpapereffect")
  if [ ! "$effect" == "off" ]; then
    used_wallpaper=$generatedversions/$effect-$wallpaperfilename
    if [ -f "$generatedversions/$effect-$wallpaperfilename" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
      _writeLog "Use cached wallpaper $effect-$wallpaperfilename"
    else
      _writeLog "Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"
      notify-send --replace-id=1 "Using wallpaper effect $effect..." "with image $wallpaperfilename" -h int:value:33
      source "$HOME/.config/hypr/effects/wallpaper/$effect"
    fi
    _writeLog "Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
    _writeLog "Setting wallpaper with $used_wallpaper"
    touch "$waypaperrunning"
    waypaper --wallpaper "$used_wallpaper"
  else
    _writeLog "Wallpaper effect is set to off"
  fi
else
  effect="off"
fi

# -----------------------------------------------------
# Detect Theme
# -----------------------------------------------------

SETTINGS_FILE="$HOME/.config/gtk-4.0/settings.ini"
THEME_PREF=$(grep -E '^gtk-application-prefer-dark-theme=' "$SETTINGS_FILE" 2>/dev/null | awk -F'=' '{print $2}')

# Set default to 1 (dark) if THEME_PREF is empty or not a number
if [[ ! "$THEME_PREF" =~ ^[0-9]+$ ]]; then
  THEME_PREF=1
fi

# -----------------------------------------------------
# Execute matugen
# -----------------------------------------------------

_writeLog "Execute matugen with $used_wallpaper"
if [ "$THEME_PREF" -eq 1 ]; then
  matugen image "$used_wallpaper" -m "dark"
else
  matugen image "$used_wallpaper" -m "light"
fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------

sleep 1
"$HOME/.config/waybar/launch.sh"

# -----------------------------------------------------
# Reload nwg-dock-hyprland
# -----------------------------------------------------

"$HOME/.config/nwg-dock-hyprland/launch.sh" &

# -----------------------------------------------------
# Update Pywalfox
# -----------------------------------------------------

if type pywalfox >/dev/null 2>&1; then
  pywalfox update
fi

# -----------------------------------------------------
# Update SwayNC
# -----------------------------------------------------

sleep 0.1
swaync-client -rs

# -----------------------------------------------------
# Process all wallpaper versions in parallel
# -----------------------------------------------------

# Blurred wallpaper (background process)
(
  if [ -f "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
    _writeLog "Use cached wallpaper blur-$blur-$effect-$wallpaperfilename"
  else
    _writeLog "Generate new cached wallpaper blur-$blur-$effect-$wallpaperfilename with blur $blur"
    # notify-send --replace-id=1 "Generate new blurred version" "with blur $blur" -h int:value:66
    magick "$used_wallpaper" -resize 75% "$blurredwallpaper"
    _writeLog "Resized to 75%"
    if [ ! "$blur" == "0x0" ]; then
      magick "$blurredwallpaper" -blur "$blur" "$blurredwallpaper"
      cp "$blurredwallpaper" "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png"
      _writeLog "Blurred"
    fi
  fi
  cp "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" "$blurredwallpaper"
  
  # Create rasi file after blurred wallpaper is ready
  if [ ! -f "$rasifile" ]; then
    touch "$rasifile"
  fi
  echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"
) &

# Square wallpaper (background process)
(
  _writeLog "Generate new cached wallpaper square-$wallpaperfilename"
  magick "$tmpwallpaper" -gravity Center -extent 1:1 "$squarewallpaper"
  cp "$squarewallpaper" "$generatedversions/square-$wallpaperfilename.png"
) &

# -----------------------------------------------------
# Create unblurred wallpaper with generic name (in parallel)
# -----------------------------------------------------

(
  currentwallpaper="$my_cache_folder/current_wallpaper.png"
  # Check if source is already PNG to avoid unnecessary conversion
  if [[ "${used_wallpaper##*.}" == "png" ]]; then
    cp "$used_wallpaper" "$currentwallpaper"
    _writeLog "Copied PNG wallpaper as current_wallpaper.png"
  else
    # Resize to 75% for non-PNG (same as blurred version for consistency)
    magick "$used_wallpaper" -resize 75% "$currentwallpaper"
    _writeLog "Converted to current_wallpaper.png (resized to 75%)"
  fi
) &

# Wait for background processes to complete
wait
