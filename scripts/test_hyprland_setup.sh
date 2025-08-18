#!/usr/bin/env bash

echo "=== Testing Hyprland Setup ==="

# Test 1: Check directories
echo "1. Checking directories..."
[ -d ~/.cache/my ] && echo "✓ Cache directory exists" || echo "✗ Missing cache directory"
[ -d ~/.cache/my/hyprland-dotfiles ] && echo "✓ Hyprland cache exists" || echo "✗ Missing hyprland cache"
[ -d ~/.config/my ] && echo "✓ Config directory exists" || echo "✗ Missing config directory"

# Test 2: Check symlinks
echo -e "\n2. Checking symlinks..."
[ -L ~/.config/hypr ] && echo "✓ Hypr config linked" || echo "✗ Hypr not linked"
[ -L ~/.config/waybar ] && echo "✓ Waybar config linked" || echo "✗ Waybar not linked"
[ -L ~/.config/wofi ] && echo "✓ Wofi config linked" || echo "✗ Wofi not linked"
[ -L ~/.config/waypaper ] && echo "✓ Waypaper config linked" || echo "✗ Waypaper not linked"

# Test 3: Check executables
echo -e "\n3. Checking installed programs..."
which hyprland &>/dev/null && echo "✓ Hyprland installed" || echo "✗ Hyprland missing"
which waybar &>/dev/null && echo "✓ Waybar installed" || echo "✗ Waybar missing"
which wofi &>/dev/null && echo "✓ Wofi installed" || echo "✗ Wofi missing"
which waypaper &>/dev/null && echo "✓ Waypaper installed" || echo "✗ Waypaper missing"
which matugen &>/dev/null && echo "✓ Matugen installed" || echo "✗ Matugen missing"
which swaync &>/dev/null && echo "✓ SwayNC installed" || echo "✗ SwayNC missing"
which wl-paste &>/dev/null && echo "✓ wl-clipboard installed" || echo "✗ wl-clipboard missing"
which cliphist &>/dev/null && echo "✓ Cliphist installed" || echo "✗ Cliphist missing"

# Test 4: Check script permissions
echo -e "\n4. Checking script permissions..."
[ -x ~/.config/hypr/scripts/wallpaper-restore.sh ] && echo "✓ wallpaper-restore.sh executable" || echo "✗ wallpaper-restore.sh not executable"
[ -x ~/.config/hypr/scripts/wallpaper.sh ] && echo "✓ wallpaper.sh executable" || echo "✗ wallpaper.sh not executable"
[ -x ~/.config/waybar/launch.sh ] && echo "✓ waybar launch.sh executable" || echo "✗ waybar launch.sh not executable"

# Test 5: Check config files
echo -e "\n5. Checking config files..."
[ -f ~/.config/my/settings/blur.sh ] && echo "✓ blur.sh exists" || echo "✗ blur.sh missing"
[ -f ~/.config/my/settings/waybar-theme.sh ] && echo "✓ waybar-theme.sh exists" || echo "✗ waybar-theme.sh missing"
[ -f ~/.config/hypr/settings/wallpaper-effect.sh ] && echo "✓ wallpaper-effect.sh exists" || echo "✗ wallpaper-effect.sh missing"
[ -f ~/.config/my/wallpapers/default.jpg ] && echo "✓ default wallpaper exists" || echo "✗ default wallpaper missing"

# Test 6: Check waypaper config
echo -e "\n6. Checking waypaper configuration..."
if [ -f ~/.config/waypaper/config.toml ]; then
  grep -q "post_command" ~/.config/waypaper/config.toml && echo "✓ Waypaper post_command configured" || echo "✗ Waypaper post_command not set"
else
  echo "✗ Waypaper config.toml missing"
fi

# Test 7: Test individual components
echo -e "\n7. Component tests (manual):"
echo "   Run: ~/.config/hypr/scripts/wallpaper-restore.sh"
echo "   Run: ~/.config/waybar/launch.sh"
echo "   Run: wofi --show drun"
echo "   Run: swaync"

echo -e "\n=== Summary ==="
echo "Review the above results and fix any ✗ items before proceeding."