--    ___       __           __           __
--   / _ |__ __/ /____  ___ / /____ _____/ /_
--  / __ / // / __/ _ \(_-</ __/ _ `/ __/ __/
-- /_/ |_\_,_/\__/\___/___/\__/\_,_/_/  \__/
--
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
  -- Load hyprpm plugins (HyprCapture, etc.) into the running compositor.
  -- `enable` only marks state on disk — `reload` is what injects the .so.
  hl.exec_cmd("hyprpm reload -n")

  -- Start Listeners, e.g. for gtk theme switches.
  hl.exec_cmd("~/.config/my/listeners.sh --startall")

  -- Start Polkit (hyprpolkitagent replaces polkit-gnome)
  hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")

  -- Load Wallpaper (also starts waybar via wallpaper.sh post-command chain)
  hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")

  -- Load Notification Daemon
  hl.exec_cmd("swaync")

  -- Load GTK settings (also applies the cursor theme via `hyprctl setcursor`)
  hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")

  -- Using hypridle to start hyprlock
  hl.exec_cmd("hypridle")

  -- Start autostart cleanup
  hl.exec_cmd("~/.config/hypr/scripts/cleanup.sh")
end)
