-- -----------------------------------------------------
-- General window layout and colors
-- name: "Default"
-- -----------------------------------------------------

local mocha = require("mocha")

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 3,
    col = {
      active_border = { colors = { mocha.mauve, mocha.flamingo }, angle = 90 },
      inactive_border = mocha.subtext0,
    },
    layout = "dwindle",
    resize_on_border = true,
  },
})
