# ML4W Dotfiles Implementation Plan

## Overview
Systematic implementation and testing of ML4W-style Hyprland configuration, testing each component in isolation before integration.

## Current Status
- Have: Basic Hyprland config working (hyprland.conf)
- Have: ML4W config files copied but not working (hyprland-new-broken.conf)
- Directory structure: Using stow from ~/dotfiles/stow/
- Config directory: ~/.config/my/ (instead of ml4w)

## Implementation Phases

### Phase 0: Preparation and Audit
- [ ] Create missing directories
- [ ] Fix directory structure (setttings -> settings)
- [ ] Install missing packages
- [ ] Create test scripts for each component

### Phase 1: Core Infrastructure Testing
Test each foundational script independently:

1. **Library Script** (`~/.config/my/library.sh`)
   - [ ] Test _writeLog function
   - [ ] Verify it sources correctly

2. **Cache and Settings Directories**
   - [ ] Create ~/.cache/ml4w/hyprland-dotfiles/
   - [ ] Create proper settings files in ~/.config/my/settings/
   - [ ] Test read/write to cache

3. **Environment Variables**
   - [ ] Test XDG_CURRENT_DESKTOP setting
   - [ ] Verify WAYLAND_DISPLAY

### Phase 2: Individual Script Testing
Test each script manually before adding to autostart:

1. **GTK Settings Script** (`gtk.sh`)
   - [ ] Test reading GTK settings
   - [ ] Test cursor setting with hyprctl
   - [ ] Verify gsettings commands work

2. **Wallpaper Scripts**
   - [ ] Test wallpaper-restore.sh standalone
   - [ ] Test wallpaper.sh with a sample image
   - [ ] Verify waypaper configuration
   - [ ] Test matugen color generation

3. **Listeners Script** (`listeners.sh`)
   - [ ] Test --startall flag
   - [ ] Verify individual listeners work
   - [ ] Check file monitoring works

4. **Cleanup Script** (`cleanup.sh`)
   - [ ] Test gamemode flag removal
   - [ ] Verify other cleanup tasks

### Phase 3: UI Component Testing

1. **Waybar**
   - [ ] Test launch.sh manually
   - [ ] Verify theme loading
   - [ ] Check if colors.css is found
   - [ ] Test toggle and reload keybindings

2. **Notification System (SwayNC)**
   - [ ] Test swaync launch
   - [ ] Verify notification display
   - [ ] Test reload command

3. **Application Launchers**
   - [ ] Test wofi launch
   - [ ] Verify configuration loading

4. **Lock Screen**
   - [ ] Test hypridle configuration
   - [ ] Test hyprlock manually

### Phase 4: Keybinding Testing
Test each keybinding category:

1. **Application Launchers**
   - [ ] Terminal (kitty)
   - [ ] Browser
   - [ ] File manager
   - [ ] App launcher (wofi)

2. **System Controls**
   - [ ] Screenshot tools
   - [ ] Color picker
   - [ ] Wallpaper picker
   - [ ] Lock screen

3. **UI Controls**
   - [ ] Waybar reload/toggle
   - [ ] Notification center toggle
   - [ ] Theme switcher

### Phase 5: Integration Testing

1. **Autostart Sequence**
   - [ ] Add scripts to autostart.conf one by one
   - [ ] Test with minimal config first
   - [ ] Add complexity gradually

2. **Configuration Files**
   - [ ] Test each conf file individually
   - [ ] Source them one by one in hyprland.conf
   - [ ] Identify which causes breaks

3. **Full Integration**
   - [ ] Enable complete configuration
   - [ ] Test full startup sequence
   - [ ] Verify all components work together

## Testing Commands

### Script Testing
```bash
# Test individual scripts
bash -x ~/.config/hypr/scripts/gtk.sh  # Debug mode
~/.config/hypr/scripts/wallpaper-restore.sh
~/.config/my/listeners.sh --startall

# Test waybar
~/.config/waybar/launch.sh

# Test notifications
swaync
swaync-client -t  # Toggle

# Test keybindings (in Hyprland)
hyprctl dispatch exec kitty
hyprctl dispatch exec "wofi --show drun"
```

### Debug Commands
```bash
# Check running processes
ps aux | grep -E "waybar|swaync|hypridle|polkit"

# Check Hyprland logs
hyprctl version
journalctl --user -xe | grep hypr

# Test environment
echo $XDG_CURRENT_DESKTOP
echo $WAYLAND_DISPLAY

# Check file paths
ls -la ~/.cache/ml4w/hyprland-dotfiles/
ls -la ~/.config/my/settings/
```

## Common Issues and Solutions

### Issue: Scripts not found
- Check shebang: `#!/usr/bin/env bash`
- Make executable: `chmod +x script.sh`
- Use full paths in scripts

### Issue: Waybar doesn't start
- Check if launch.sh is executable
- Verify theme files exist
- Test with default theme first

### Issue: Colors not applying
- Check matugen installation: `matugen --version`
- Verify template files exist
- Check output paths in matugen config

### Issue: Keybindings not working
- Check $mainMod variable is set
- Verify applications are installed
- Test with hyprctl dispatch

## Next Steps

1. Start with Phase 0: Fix directory structure
2. Move to Phase 1: Test core infrastructure
3. Progress through phases systematically
4. Document what works/fails at each step
5. Only integrate working components

## Success Criteria

Each phase is complete when:
- All components test successfully in isolation
- No error messages in logs
- Expected behavior is observed
- Ready to integrate with next phase