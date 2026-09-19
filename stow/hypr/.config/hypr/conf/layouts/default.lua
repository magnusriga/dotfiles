-- -----------------------------------------------------
-- Layouts
-- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- -----------------------------------------------------

hl.config({
  dwindle = {
    preserve_split = true,
  },
})

-- Touchpad gestures: bind them explicitly with `hl.gesture()` if wanted.
-- Example: hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.config({
  binds = {
    workspace_back_and_forth = true,
    allow_workspace_cycles = true,
    pass_mouse_when_bound = false,
  },
})
