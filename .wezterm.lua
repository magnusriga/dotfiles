-- ==============================================================
-- NOTES
-- ==============================================================
-- Search and copy
-- --------------------------------------------------------------
-- CTRL-SHIFT-F and CMD-F to search.
-- Not that useful to copy, as it just copies search term.
--
-- --------------------------------------------------------------
-- Copy and Paste
-- --------------------------------------------------------------
-- Copy: CTRL-SHIFT-C
-- Paste: CTRL-SHIFT-V
-- Uses system clipboard, so cannot paste with p.
--
-- --------------------------------------------------------------
-- Quick Select Mode
-- --------------------------------------------------------------
-- CTRL-SHIFT-SPACE
-- In Quick Select mode hit prefix to copy, or upper case prefix
-- to copy, paste and exit Quick Search mode.
-- URLs etc. are highlighted by default.
--
-- --------------------------------------------------------------
-- Copy Mode
-- --------------------------------------------------------------
-- CTRL-SHIFT-X
-- Move, select, and copy like Vim.
-- ESC to exit, then paste as shown above.
-- ==============================================================

-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font("JetBrains Mono")

-- Changing the color scheme.
-- config.color_scheme = 'Batman'
-- config.color_scheme = "AdventureTime"
config.color_scheme = "OneHalfDark"

-- Enable the scrollbar.
-- It will occupy the right window padding space.
-- If right padding is set to 0 then it will be increased
-- to a single cell width
config.enable_scroll_bar = true

config.keys = {
  { key = "UpArrow", mods = "SHIFT", action = act.ScrollToPrompt(-1) },
  { key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
}

-- and finally, return the configuration to wezterm
return config
