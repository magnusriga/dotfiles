-- ==============================================================
-- NOTES
-- ==============================================================
-- Search
-- --------------------------------------------------------------
-- CTRL-SHIFT-F and CMD-F to search.
-- CTRL-SHIFT-C will copy the selected text to the clipboard.
-- Esc to escape.
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

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font("JetBrains Mono")

-- Changing the color scheme.
-- config.color_scheme = 'Batman'
-- config.color_scheme = "AdventureTime"

-- Enable the scrollbar.
-- It will occupy the right window padding space.
-- If right padding is set to 0 then it will be increased
-- to a single cell width
config.enable_scroll_bar = true

-- and finally, return the configuration to wezterm
return config
