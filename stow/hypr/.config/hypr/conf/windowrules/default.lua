-- -----------------------------------------------------
-- Window rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- -----------------------------------------------------

hl.window_rule({ match = { title = [[^(Microsoft-edge)$]] }, tile = true })
hl.window_rule({ match = { title = [[^(Brave-browser)$]] }, tile = true })
hl.window_rule({ match = { title = [[^(Chromium)$]] }, tile = true })
hl.window_rule({ match = { title = [[^(pavucontrol)$]] }, float = true })
hl.window_rule({ match = { title = [[^(blueman-manager)$]] }, float = true })
hl.window_rule({ match = { title = [[^(nm-connection-editor)$]] }, float = true })
hl.window_rule({ match = { title = [[^(qalculate-gtk)$]] }, float = true })

-- Browser Picture in Picture
hl.window_rule({
  match = { title = [[^(Picture-in-Picture)$]] },
  float = true,
  pin = true,
  move = { "monitor_w*0.695", "monitor_h*0.04" },
})
