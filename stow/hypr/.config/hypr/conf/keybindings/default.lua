-- -----------------------------------------------------
-- Key bindings
-- name: "Default"
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- -----------------------------------------------------

-- SUPER KEY
local mainMod = "SUPER"
local HYPRSCRIPTS = "~/.config/hypr/scripts"

-- Focus a named workspace and launch its app there unless a window of `class` is already on it.
local function openOnWorkspace(name, class, cmd)
  local workspace = "name:" .. name
  hl.dispatch(hl.dsp.focus({ workspace = workspace }))
  for _, window in ipairs(hl.get_workspace_windows(workspace)) do
    if window.class:lower() == class:lower() then
      return
    end
  end
  hl.dispatch(hl.dsp.exec_cmd(cmd, { workspace = workspace }))
end

-- Screen zoom, https://wiki.hypr.land/Configuring/Code-Snippets/#windows-magnifier-like-cursor-zoom
local MIN_ZOOM = 1

local function zoom(offset)
  local current = hl.get_config("cursor.zoom_factor") + offset
  hl.config({ cursor = { zoom_factor = math.max(MIN_ZOOM, current) } })
end

-- Recording mode: active window floating at 1600x900, centered.
local RECORD_W, RECORD_H = 1600, 900

-- Toggle the active window between recording mode and normal tiled mode.
local function toggleRecordSize()
  local window = hl.get_active_window()
  if window == nil then
    return
  end
  if window.floating and window.size.x == RECORD_W and window.size.y == RECORD_H then
    hl.dispatch(hl.dsp.window.float({ action = "disable" }))
  else
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.resize({ x = RECORD_W, y = RECORD_H }))
    hl.dispatch(hl.dsp.window.center())
  end
end

-- Move every window on the active workspace to `workspace`, then follow them.
local function moveAllToWorkspace(workspace)
  for _, window in ipairs(hl.get_workspace_windows(hl.get_active_workspace())) do
    hl.dispatch(hl.dsp.window.move({ workspace = workspace, follow = false, window = window }))
  end
  hl.dispatch(hl.dsp.focus({ workspace = workspace }))
end

-- Applications
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("~/.config/hypr/settings/terminal.sh"), { description = "Open terminal" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/.config/hypr/settings/browser.sh"), { description = "Open browser" })
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("~/.config/hypr/settings/filemanager.sh"), { description = "Open filemanager" }) -- `E`: Used by other filemanager binding
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("~/.config/hypr/settings/calculator.sh"), { description = "Open calculator" })

-- Open certain applications in preset letter workspaces
hl.bind(mainMod .. " + M", function()
  openOnWorkspace("m", "Spotify", "spotify")
end, { description = "Open Spotify on workspace m" })
hl.bind(mainMod .. " + N", function()
  openOnWorkspace("n", "com.mitchellh.ghostty", "ghostty --working-directory=$HOME/notes")
end, { description = "Open notes terminal on workspace n" })
hl.bind(mainMod .. " + E", function()
  openOnWorkspace("e", "org.gnome.Nautilus", "nautilus --new-window")
end, { description = "Open file manager on workspace e" })

-- Display
hl.bind(mainMod .. " + SHIFT + mouse_down", function()
  zoom(0.5)
end, { description = "Increase display zoom" })
hl.bind(mainMod .. " + SHIFT + mouse_up", function()
  zoom(-0.5)
end, { description = "Decrease display zoom" })
hl.bind(mainMod .. " + SHIFT + Z", function()
  hl.config({ cursor = { zoom_factor = MIN_ZOOM } })
end, { description = "Reset display zoom" })

-- Windows
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("ghostty"), { description = "Open terminal" })
hl.bind(mainMod .. " + C", hl.dsp.window.close(), { description = "Kill active window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.signal({ signal = 15 }), { description = "Quit active window and all open instances" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen on active window" })
-- hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize window" }) -- `M`: Used by Spotify, OK as `F` toggles
hl.bind(mainMod .. " + V", hl.dsp.window.float(), { description = "Toggle active window into floating mode" })
hl.bind(mainMod .. " + SHIFT + T", function()
  for _, window in ipairs(hl.get_workspace_windows(hl.get_active_workspace())) do
    hl.dispatch(hl.dsp.window.float({ window = window }))
  end
end, { description = "Toggle all windows on the workspace into floating mode" })
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"), { description = "Toggle split (dwindle)" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Pseudotile" })
hl.bind(mainMod .. " + W", hl.dsp.group.toggle(), { description = "Toggle window group" })
hl.bind(mainMod .. " + R", toggleRecordSize, { description = "Toggle active window between recording mode (1600x900 floating, centered) and normal tiled mode" })

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })

-- hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { description = "Increase window width with keyboard" })
-- hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Reduce window width with keyboard" })
-- hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { description = "Increase window height with keyboard" })
-- hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Reduce window height with keyboard" })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with the mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with the mouse" })

hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"), { description = "Swapsplit (dwindle)" })
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.swap({ direction = "left" }), { description = "Swap tiled window left" })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.swap({ direction = "down" }), { description = "Swap tiled window down" })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.swap({ direction = "up" }), { description = "Swap tiled window up" })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.swap({ direction = "right" }), { description = "Swap tiled window right" })

hl.bind("ALT + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end, { repeating = true, description = "Cycle between windows and bring the active one to the top" })

-- Actions
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland configuration" })
hl.bind(mainMod .. " + SHIFT + A", function()
  hl.config({ animations = { enabled = not hl.get_config("animations.enabled") } })
end, { description = "Toggle animations" })

-- Screenshots via HyprCapture plugin (see `plugin.hyprcapture` in conf/my.lua).
-- The plugin loads after startup via `hyprpm reload` and then reloads the config.
if hl.plugin.hyprcapture ~= nil then
  hl.bind("PRINT", function()
    hl.plugin.hyprcapture.open("region")
  end, { description = "Take screenshot of selected region" })
  hl.bind("SHIFT + PRINT", function()
    hl.plugin.hyprcapture.open("fullscreen")
  end, { description = "Take screenshot of entire screen" })
  hl.bind(mainMod .. " + PRINT", function()
    hl.plugin.hyprcapture.open("window")
  end, { description = "Take screenshot of a window" })
end

hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/wlogout.sh"), { description = "Start wlogout" })

hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/wallpaper.sh"), { description = "Change wallpaper" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper --random"), { description = "Change wallpaper" })
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("waypaper"), { description = "Open wallpaper selector" })
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/wallpaper-automation.sh"), { description = "Start random wallpaper script" })

hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd("pkill wofi || wofi --show=drun --insensitive"), { description = "Open application launcher" })
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("pkill wofi || wofi --show=drun --insensitive"), { description = "Open application launcher (space)" })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/keybindings.sh"), { description = "Show keybindings" })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/waybar/launch.sh"), { description = "Reload waybar" })
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("~/.config/waybar/toggle.sh"), { description = "Toggle waybar" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload hyprland config" })
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd([[pkill wofi; sleep 0.1; cliphist list | wofi --dmenu --prompt="Clipboard" | cliphist decode | wl-copy]]), { description = "Open clipboard history" })

hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/power.sh lock"), { description = "Lock screen" })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/hyprshade.sh"), { description = "Toggle hyprshade" })

-- Workspaces
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Open workspace " .. i })
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move active window to workspace " .. i })
  hl.bind(mainMod .. " + CTRL + " .. key, function()
    moveAllToWorkspace(i)
  end, { description = "Move all windows to workspace " .. i })
end

hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }), { description = "Open next workspace" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), { description = "Open previous workspace" })

-- Letter-based workspaces
for _, letter in ipairs({ "a", "s", "d" }) do
  hl.bind(mainMod .. " + " .. letter:upper(), hl.dsp.focus({ workspace = "name:" .. letter }), { description = "Open workspace " .. letter })
end

-- Move windows to letter workspaces
for _, letter in ipairs({ "a", "s", "d", "e", "m", "n" }) do
  hl.bind(mainMod .. " + SHIFT + " .. letter:upper(), hl.dsp.window.move({ workspace = "name:" .. letter }), { description = "Move active window to workspace " .. letter })
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Open next workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Open previous workspace" })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }), { description = "Open the next empty workspace" })

-- Fn keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { description = "Increase brightness by 5%" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { description = "Reduce brightness by 5%" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"), { locked = true, repeating = true, description = "Increase volume by 10% (hard-capped at 100%)" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"), { locked = true, repeating = true, description = "Reduce volume by 10%" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, description = "Toggle mute" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Audio play pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"), { description = "Audio pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Audio next" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Audio previous" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { description = "Toggle microphone" })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("~/.config/hypr/settings/calculator.sh"), { description = "Open calculator" })
hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("hyprlock"), { description = "Open screenlock" })

hl.bind("code:238", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight s +10"), { description = "Increase keyboard brightness by 10%" })
hl.bind("code:237", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight s 10-"), { description = "Reduce keyboard brightness by 10%" })
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight set +10%"), { description = "Increase keyboard brightness by 10%" })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight set 10%-"), { description = "Reduce keyboard brightness by 10%" })
