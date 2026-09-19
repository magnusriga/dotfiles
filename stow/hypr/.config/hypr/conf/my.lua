--    __  _____  _____      __  _____          ___
--   /  |/  / / / / / | /| / / / ___/__  ___  / _/
--  / /|_/ / /_/_  _/ |/ |/ / / /__/ _ \/ _ \/ _/
-- /_/  /_/____//_/ |__/|__/  \___/\___/_//_/_/
--
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Pavucontrol floating
hl.window_rule({
  match = { class = [[^(.*org\.pulseaudio\.pavucontrol.*)$]] },
  float = true,
  size = { 700, 600 },
  center = true,
  pin = true,
})

-- OpenAI ChatGPT floating
hl.window_rule({ match = { title = [[^(ChatGPT.*)$]] }, float = true })
hl.window_rule({
  match = { title = [[^(.*chat\.openai\.com.*)$]] },
  float = true,
  size = { 500, "monitor_h*0.5" },
  move = { 20, 70 },
})

-- Waypaper
hl.window_rule({
  match = { class = [[^(.*waypaper.*)$]] },
  float = true,
  size = { 900, 700 },
  center = true,
  pin = true,
})

-- SwayNC
hl.layer_rule({ match = { namespace = [[^(swaync-control-center)$]] }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = [[^(swaync-notification-window)$]] }, blur = true, ignore_alpha = 0.5 })

-- Calendar floating
hl.window_rule({
  match = { class = [[^(gnome-calendar)$]] },
  float = true,
  move = { "monitor_w-window_w-16", 66 },
  pin = true,
  size = { 400, 400 },
})

-- Sidebar floating
hl.window_rule({
  match = { class = [[^(com\.my\.sidebar)$]] },
  float = true,
  move = { "monitor_w-window_w-16", 66 },
  pin = true,
  size = { 400, 740 },
})

-- Gnome Control Center App floating
hl.window_rule({
  match = { class = [[^(gnome-control-center)$]] },
  float = true,
  size = { 800, 600 },
  move = { "monitor_w*0.1", "monitor_h*0.2" },
})

-- Blueman Manager
hl.window_rule({
  match = { class = [[^(blueman-manager)$]] },
  float = true,
  size = { 800, 600 },
  center = true,
})

-- nwg-look
hl.window_rule({
  match = { class = [[^(nwg-look)$]] },
  float = true,
  size = { 700, 600 },
  move = { "monitor_w*0.1", "monitor_h*0.2" },
  pin = true,
})

-- nwg-displays
hl.window_rule({
  match = { class = [[^(nwg-displays)$]] },
  float = true,
  size = { 900, 600 },
  move = { "monitor_w*0.1", "monitor_h*0.2" },
  pin = true,
})

-- System Mission Center
hl.window_rule({
  match = { class = [[^(io\.missioncenter\.MissionCenter)$]] },
  float = true,
  pin = true,
  center = true,
  size = { 900, 600 },
})

-- System Mission Center Preference Window
hl.window_rule({
  match = { class = [[^(missioncenter)$]], title = [[^(Preferences)$]] },
  float = true,
  pin = true,
  center = true,
})

-- Gnome Calculator
hl.window_rule({
  match = { class = [[^(org\.gnome\.Calculator)$]] },
  float = true,
  size = { 700, 600 },
  center = true,
})

-- Emoji Picker Smile
hl.window_rule({
  match = { class = [[^(it\.mijorus\.smile)$]] },
  float = true,
  pin = true,
  move = { "monitor_w-window_w-40", 90 },
})

-- Hyprland Share Picker
hl.window_rule({
  match = { class = [[^(hyprland-share-picker)$]] },
  float = true,
  pin = true,
  center = true,
  size = { 600, 400 },
})

-- Floating for Ghostty
hl.window_rule({
  match = { class = [[^(my\.dotfiles\.floating)$]] },
  float = true,
  size = { 1000, 700 },
  center = true,
  pin = true,
})

-- Float and center file pickers
hl.window_rule({
  match = { class = [[^(xdg-desktop-portal-gtk)$]], title = [[^(Open.*Files?|Save.*Files?|All Files|Save)$]] },
  float = true,
  center = true,
})

-- Network Manager TUI (nmtui in Ghostty with a specific title)
hl.window_rule({
  match = { class = [[^(com\.mitchellh\.ghostty)$]], title = [[^(NetworkManager)$]] },
  float = true,
  center = true,
  size = { 1100, 700 },
})

-- Suppress maximize events (apps you don't want auto-maximizing)
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Autoplace Whispering on workspace 4 (`silent` = don't steal focus)
hl.window_rule({ match = { class = [[^(Whispering)$]] }, workspace = "4 silent" })

-- Don't animate wofi
hl.layer_rule({ match = { namespace = [[^(wofi)$]] }, no_anim = true })

-- -----------------------------------------------------
-- Environment
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- -----------------------------------------------------

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- GDK
hl.env("GDK_SCALE", "1")

-- Toolkit Backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")

-- Mozilla
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Set the cursor size for xcursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Ozone
hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- -----------------------------------------------------
-- XWayland
-- -----------------------------------------------------
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

-- -----------------------------------------------------
-- HyprCapture (screenshot/recording plugin) — keybindings live in conf/keybindings/default.lua.
-- The plugin loads after startup via `hyprpm reload` and then reloads the config.
-- https://github.com/gfhdhytghd/HyprCapture#configuration
-- -----------------------------------------------------
if hl.plugin.hyprcapture ~= nil then
  hl.config({
    plugin = {
      hyprcapture = {
        default_mode = "region",
        fullscreen_scope = "all",
        save = true,
        clipboard = true,
        show_thumbnail = true,
        save_dir = "$HOME/Downloads/screenshots",
        filename_template = "screenshot-%Y%m%d-%H%M%S.png",
        record_save_dir = "$HOME/Downloads/screenshots",
        record_filename_template = "recording-%Y%m%d-%H%M%S.mp4",
        record_codec = "auto",
        record_fps = 60,
        include_cursor = true,
      },
    },
  })
end
