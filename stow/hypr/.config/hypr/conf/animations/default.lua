-- name "End-4"
-- credit https://github.com/end-4/dots-hyprland
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.config({ animations = { enabled = true } })

-- Animation curves
local function bezier(name, x0, y0, x1, y1)
  hl.curve(name, { type = "bezier", points = { { x0, y0 }, { x1, y1 } } })
end

bezier("linear", 0, 0, 1, 1)
bezier("md3_standard", 0.2, 0, 0, 1)
bezier("md3_decel", 0.05, 0.7, 0.1, 1)
bezier("md3_accel", 0.3, 0, 0.8, 0.15)
bezier("overshot", 0.05, 0.9, 0.1, 1.1)
bezier("crazyshot", 0.1, 1.5, 0.76, 0.92)
bezier("hyprnostretch", 0.05, 0.9, 0.1, 1.0)
bezier("menu_decel", 0.1, 1, 0, 1)
bezier("menu_accel", 0.38, 0.04, 1, 0.07)
bezier("easeInOutCirc", 0.85, 0, 0.15, 1)
bezier("easeOutCirc", 0, 0.55, 0.45, 1)
bezier("easeOutExpo", 0.16, 1, 0.3, 1)
bezier("softAcDecel", 0.26, 0.26, 0.15, 1)
bezier("md2", 0.4, 0, 0.2, 1) -- use with .2s duration

-- Animation configs
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "md3_decel" })

-- Layer shells (wofi, swaync, slurp, etc.) — all instant, no fade or slide.
hl.animation({ leaf = "layersIn", enabled = false })
hl.animation({ leaf = "layersOut", enabled = false })
hl.animation({ leaf = "fadeLayersIn", enabled = false })
hl.animation({ leaf = "fadeLayersOut", enabled = false })
hl.animation({ leaf = "workspaces", enabled = false }) -- instant workspace swap
hl.animation({ leaf = "specialWorkspace", enabled = false })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "softAcDecel", style = "slide" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slidefade 15%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidefadevert 15%" })
