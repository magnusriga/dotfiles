-- -----------------------------------------------------
-- General window decoration
-- name: "Rounding All Blur No Shadows"
-- -----------------------------------------------------

hl.config({
  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = true,
      size = 12,
      passes = 4,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
    },

    shadow = {
      enabled = true,
      range = 10,
      render_power = 2,
      color = 0x33000000,
    },
  },
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
