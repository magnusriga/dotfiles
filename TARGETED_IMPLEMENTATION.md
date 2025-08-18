# Targeted Hyprland Implementation Plan

## Philosophy
Only include what we actually use. Every component must have a clear purpose.

## Directory Structure
```
~/dotfiles/stow/
├── hypr/.config/hypr/
│   ├── conf/           # Modular Hyprland configs
│   ├── scripts/        # Hyprland/Wayland specific scripts
│   └── settings/       # Hyprland-specific settings (app launchers, etc.)
└── my/.config/my/
    ├── scripts/        # General OS scripts (updates, backups, etc.)
    ├── settings/       # General settings (blur values, themes, etc.)
    └── wallpapers/     # Default wallpapers
```

## Essential Components Only

### What We NEED:
1. **Core Hyprland functionality**
   - Modular config loading
   - Basic autostart
   - Keybindings
   
2. **Essential UI**
   - Waybar (status bar)
   - Wofi (app launcher)
   - SwayNC (notifications)
   
3. **Wallpaper & Theming**
   - Waypaper (wallpaper setter)
   - Matugen (color generation)
   - Basic GTK theming

4. **System Integration**
   - XDG desktop portal
   - Polkit agent
   - Clipboard manager

### What We DON'T NEED:
- ML4W Welcome app
- ML4W branding/assets
- Game mode features
- Multiple theme variations (start with one)
- Unnecessary listeners
- Update checking scripts (unless you want them)

## Testing Plan - Bottom Up

### Phase 1: Fix Basic Structure
```bash
# 1. Fix the settings directory typo
cd ~/dotfiles/stow/my/.config/my/
mv setttings settings

# 2. Create essential cache directories
mkdir -p ~/.cache/ml4w/hyprland-dotfiles

# 3. Create minimal settings files
echo "blur.sh" > ~/dotfiles/stow/my/.config/my/settings/blur.sh
echo "50x30" >> ~/dotfiles/stow/my/.config/my/settings/blur.sh
```

### Phase 2: Test Core Scripts Individually

#### Test 1: Library Functions
```bash
# Test library.sh
source ~/.config/my/library.sh
_writeLog "Test message"
# Expected: Should write to log file
```

#### Test 2: Wallpaper System
```bash
# First test wallpaper-restore.sh
~/.config/hypr/scripts/wallpaper-restore.sh
# Expected: Should set default wallpaper

# Then test wallpaper.sh with an image
~/.config/hypr/scripts/wallpaper.sh /path/to/test/image.jpg
# Expected: Should change wallpaper and generate colors
```

#### Test 3: GTK Settings
```bash
# Test GTK script
~/.config/hypr/scripts/gtk.sh
# Expected: Should apply GTK theme and cursor
```

#### Test 4: Waybar
```bash
# Test waybar launch directly
~/.config/waybar/launch.sh
# Expected: Waybar should start with theme
```

### Phase 3: Test Keybindings
Test each keybinding manually using hyprctl:

```bash
# Terminal
hyprctl dispatch exec kitty

# App launcher
hyprctl dispatch exec "wofi --show drun"

# Screenshot
hyprctl dispatch exec "grim -g \"$(slurp)\" - | wl-copy"

# Waybar reload
hyprctl dispatch exec "~/.config/waybar/launch.sh"
```

### Phase 4: Minimal Autostart Integration
Add to autostart.conf one at a time:

```bash
# Start with essentials only:
exec-once = ~/.config/hypr/scripts/gtk.sh
exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh
exec-once = swaync
exec-once = wl-paste --watch cliphist store

# Test after each addition
hyprctl reload
```

### Phase 5: Full Configuration
Only after everything works individually:

1. Enable the modular config structure
2. Test with minimal hyprland.conf first
3. Add complexity gradually

## Current Issues to Fix

### Immediate Fixes Needed:
1. [ ] Fix `setttings` → `settings` directory name
2. [ ] Create cache directories
3. [ ] Check if waypaper is configured correctly
4. [ ] Verify matugen templates exist and are configured
5. [ ] Ensure scripts are executable

### Script Dependencies to Verify:
```bash
# Check installed programs
which waypaper
which matugen
which waybar
which wofi
which swaync
which wl-paste
which cliphist
which grim
which slurp
```

## Testing Commands by Component

### Wallpaper Chain:
```bash
# Test each step
waypaper --wallpaper ~/Pictures/test.jpg
# Check if post-command is configured
cat ~/.config/waypaper/config.toml

# Test wallpaper script directly
bash -x ~/.config/hypr/scripts/wallpaper.sh ~/Pictures/test.jpg

# Check if colors generated
ls -la ~/.config/hypr/colors.conf
ls -la ~/.config/waybar/colors.css
```

### Waybar:
```bash
# Test launch
~/.config/waybar/launch.sh

# Check for errors
waybar -l debug

# Test with specific config
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css
```

### Notifications:
```bash
# Test SwayNC
swaync

# Send test notification
notify-send "Test" "This is a test"

# Toggle panel
swaync-client -t
```

## Success Metrics

Each component works when:
1. **No errors** in terminal output
2. **Expected behavior** occurs
3. **Can be triggered** via keybinding
4. **Survives** hyprctl reload

## Next Immediate Steps

1. **Fix directory structure** (setttings → settings)
2. **Create cache directories**
3. **Test wallpaper-restore.sh** - most critical path
4. **Test waybar launch** - second most critical
5. **Add working components to autostart** one by one

## Minimal Working Config

Start with this minimal hyprland.conf:
```bash
# Monitor
monitor=,preferred,auto,1

# Basic settings
input {
    kb_layout = us
}

# Essential autostart only
exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh
exec-once = swaync

# Basic keybindings
$mainMod = SUPER
bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit

# Test one at a time
# exec-once = ~/.config/hypr/scripts/gtk.sh
# exec-once = wl-paste --watch cliphist store
```

Then add complexity only after base works.