-- -----------------------------------------------------
-- Custom / personal Hyprland configuration.
-- Additions here override anything required earlier.
-- -----------------------------------------------------

local mainMod = "SUPER"

-- Global shortcut that Whispering (voice-to-text) listens for.
local whispering = { mods = "CTRL SHIFT", key = "semicolon", window = "class:^(Whispering)$" }

-- -----------------------------------------------------
-- Environment
-- -----------------------------------------------------
hl.env("SDL_VIDEODRIVER", "wayland")

-- -----------------------------------------------------
-- Personal autostart
-- -----------------------------------------------------
hl.on("hyprland.start", function()
  -- Wallpaper daemon + redshift-alike
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hyprsunset")

  -- Tray helpers
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("pasystray")

  -- XDG file-chooser portal (terminal-based)
  hl.exec_cmd("/usr/lib/xdg-desktop-portal-termfilechooser -r")

  -- Clipboard history (type-specific — replaces default cliphist autostart)
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Whispering (voice-to-text) + wake its global shortcut after startup
  hl.exec_cmd("env GDK_BACKEND=x11 GDK_DPI_SCALE=1.6 whispering")
  hl.timer(function()
    hl.dispatch(hl.dsp.send_shortcut(whispering))
  end, { timeout = 5000, type = "oneshot" })

  -- rclone mounts for Google Drive
  hl.exec_cmd([[rclone mount nfront-shared: ~/google-drive/nfront-shared --daemon --volname "nfront-shared" --temp-dir ~/.tmp/google-drive/nfront-shared/ --cache-dir ~/.cache/google-drive/nfront-shared/ --vfs-cache-mode full --vfs-cache-max-age 2y --dir-cache-time 2y --vfs-refresh --vfs-write-back 1s --transfers 8 --log-file ~/.log/google-drive/nfront-shared/nfront-shared.log --log-level INFO]])
  hl.exec_cmd([[rclone mount personal: ~/google-drive/personal --daemon --volname "personal" --temp-dir ~/.tmp/google-drive/personal/ --cache-dir ~/.cache/google-drive/personal/ --vfs-cache-mode full --vfs-cache-max-age 2y --dir-cache-time 2y --vfs-refresh --vfs-write-back 1s --transfers 8 --log-file ~/.log/google-drive/personal/personal.log --log-level INFO]])
end)

-- -----------------------------------------------------
-- Input devices
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
-- -----------------------------------------------------
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

-- -----------------------------------------------------
-- Personal keybindings
-- -----------------------------------------------------
hl.bind("CTRL + SHIFT + semicolon", hl.dsp.send_shortcut(whispering), { description = "Send the Whispering shortcut" })

-- Move the current workspace to the next/previous monitor
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "r" }), { description = "Move current workspace to next monitor" })
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.workspace.move({ monitor = "l" }), { description = "Move current workspace to previous monitor" })
