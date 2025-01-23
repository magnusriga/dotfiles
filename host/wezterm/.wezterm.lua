-- ==============================================================
-- NOTES
-- ==============================================================
-- General
-- This file must be placed in OS home directory,
-- where Wezterm is installed, not e.g. in WSL home directory.
--
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

-- This is where you actually apply your config choices.

-- Ensure TERM is set to `wezterm`,
-- to enable colored underline and undercurl.
config.term = 'wezterm'

-- Honor kitty keyboard protocol escape sequences that modify keyboard encoding.
-- https://wezfurlong.org/wezterm/config/key-encoding.html
-- https://sw.kovidgoyal.net/kitty/keyboard-protocol
-- Enabling it, as that is what ghostty does by default.
-- config.enable_kitty_keyboard = true
-- config.enable_csi_u_key_encoding = true

-- Remember to install all the fonts in the chosen family, in OS.
config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.font = wezterm.font("JetBrains Mono")
-- config.font = wezterm.font("Hack Nerd Font")
-- config.font = wezterm.font_with_fallback("Hack Nerd Font")

-- vscode uses 14px (12pt) by default.
-- 12 in WezTerm corresponds to 11 in Ghostty.
config.font_size = 12

-- Changing the color scheme.
-- config.color_scheme = 'Batman'
-- config.color_scheme = "AdventureTime"
config.color_scheme = "OneHalfDark"

config.underline_thickness = 2
config.underline_position = -2

-- Enable the scrollbar.
-- It will occupy the right window padding space.
-- If right padding is set to 0 then it will be increased
-- to a single cell width.
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

wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

-- true (default): Tab bar is rendered in native style with proportional fonts.
-- false: Tab bar is rendered using retro aesthetic using main terminal
config.use_fancy_tab_bar = true

-- RESIZE: Disable title bar, but enable resizable border.
-- TTLE | RESIZE (default): Enable titlebar and border.
config.window_decorations = "RESIZE"

-- Finally, return the configuration to wezterm.
return config
