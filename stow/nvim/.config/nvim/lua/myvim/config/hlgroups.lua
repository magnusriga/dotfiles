-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--   callback = function()
--     -- Set when entering buffer.
--     vim.cmd([[
--       highlight Cursor guifg=red guibg=yellow
--     ]])
--   end,
-- })

-- Lazygit.
vim.cmd([[
  highlight LazygitMain guifg=#2ac3de
  highlight LazygitActiveBorderColor cterm=bold gui=bold guifg=#ff9e64
  highlight LazygitCherryPickedCommitBgColor guifg=#bb9af7
  highlight LazygitCherryPickedCommitFgColor guifg=#7aa2f7
  highlight LazygitDefaultFgColor guifg=#c0caf5 guibg=#1a1b26
  highlight LazygitInactiveBorderColor guifg=#27a1b9 guibg=#16161e

  highlight! link LazygitOptionsTextColor LazygitCherryPickedCommitFgColor
  highlight! link LazygitSearchingActiveBorderColor LazygitActiveBorderColor

  highlight LazygitSelectedLineBgColor guibg=#283457
  highlight LazygitUnstagedChangesColor guifg=#db4b4b
]])

-- Vimdiff, from onehalf dark, inspired by signify.
-- `https://github.com/BBaoVanC/onehalf/blob/diff-highlighting/vim/colors/onehalfdark.vim`.
vim.cmd([[
  highlight DiffAdd guifg=#282c34 guibg=#98c379
  highlight DiffChange guifg=#282c34 guibg=#e5c07b
  highlight DiffDelete guifg=#282c34 guibg=#e06c75
  highlight DiffText guifg=#282c34 guibg=#61afef
]])

-- FzfLua.
-- - `FzfLuaTitle`: Title of window.
-- - `FzfLuaHeaderText`: Actual keybinding description, in fzf `header` line.
-- - `FzfLuaFzfHeader`: `fzf --color=header`, i.e. line with keybindings.
--
-- - Not working:
--   - Counter text: `highlight link FzfLuaFzfInfo Comment`.
--
-- - Links:
--   - Must use `!`, since `{to-group}` already set.
--
-- - Other color settings in `fzf-lua.nvim`.
--   - `TermCursor`: Used by `fzf-lua`.
--   - `highlight link FzfLuaPreviewNormal Normal`:
--     Ensures preview window background is same as normal coding window.
--
-- - Colors from `tokyodark`, overwritten:
--   - `highlight FzfLuaLiveSym guifg=PaleVioletRed1`.
--   - `highlight FzfLuaLivePrompt guifg=PaleVioletRed1`.
--
-- - Colors from `tokyodark`, not used:
--   - `highlight @punctuation.special guifg=#89ddff`.
vim.cmd([[
  highlight CursorLine guibg=#2f334d
  highlight CursorLineNr cterm=bold gui=bold guifg=#ff966c
  highlight TermCursor guifg=bg guibg=fg
  " highlight Title cterm=bold gui=bold guifg=#82aaff
  highlight Directory guifg=#82aaff
  highlight TabLine guifg=#3b4261 guibg=#1e2030
  highlight Visual guibg=#2d3f76
  highlight NonText guifg=#545c7e guibg=Normal

  highlight FzfLuaTitle guifg=#ff966c guibg=#1e2030
  highlight FzfLuaPreviewNormal guibg=#ff007c
  highlight! link FzfLuaPath Directory
  highlight FzfLuaBorder guifg=#589ed7 guibg=#1e2030
  highlight FzfLuaCursor guifg=#1b1d2b guibg=#ff966c
  highlight FzfLuaNormal guifg=#c8d3f5 guibg=#1e2030
  highlight FzfLuaSearch guifg=#1b1d2b guibg=#ff966c
  highlight FzfLuaDirPart guifg=#828bb8
  highlight! link FzfLuaFilePart FzfLuaFzfNormal
  highlight! link FzfLuaHeaderText FzfLuaFzfHeader
  highlight! link FzfLuaHeaderBind FzfLuaFzfHeader

  highlight FzfLuaFzfNormal guifg=#c8d3f5
  highlight! link FzfLuaFzfHeader Comment
  highlight FzfLuaFzfSeparator guifg=#ff966c guibg=#1e2030
  highlight FzfLuaFzfMatch guifg=#ff966c guibg=#1e2030
  highlight FzfLuaFzfPointer guifg=#ff007c
  highlight! link FzfLuaFzfCursorLine Visual

  highlight! link FzfLuaFzfInfo Comment

  highlight FzfLuaLiveSym guifg=#ff966c guibg=#1e2030
  highlight! link FzfLuaLivePrompt FzfLuaFzfQuery

  highlight FzfLuaScrollBorderBackCompat guifg=#1e2030 guibg=#589ed7

  highlight! link FzfLuaPreviewNormal Normal
  highlight FzfLuaPreviewTitle guifg=#589ed7 guibg=None
  highlight FzfLuaPreviewBorder guifg=#589ed7 guibg=None
]])

-- WhichKey.
-- - `WhichKeyFloat`: Links to NormalFloat, below linked to Normal,
-- - `WhichKeyBorder`: Links to FloatBorder, below changed to match `fzf-lua`.
-- - Result: Floating windows have same background as normal windows, just with border.
vim.cmd([[
  highlight! link NormalFloat Normal
  highlight FloatBorder guifg=#589ed7 guibg=None
]])

-- Pmenu.
vim.cmd([[
  highlight Pmenu guifg=#c8d3f5 guibg=#1e2030
  highlight PmenuSel guibg=#363c58
  highlight! link PmenuKind Pmenu
  highlight! link PmenuKindSel PmenuSel
  highlight! link PmenuExtra Pmenu
  highlight! link PmenuExtraSel PmenuSel
  highlight PmenuSbar guibg=#27293a
  highlight PmenuThumb guibg=#3b4261
  highlight PmenuMatch guifg=#65bcff guibg=#1e2030
  highlight PmenuMatchSel guifg=#65bcff guibg=#363c58
]])

-- MiniIcons.
-- `onedarkpro` blue is better than `tokyodark`: `highlight MiniIconsBlue guifg=#82aaff`.
-- `onedarkpro` green is better than `tokyodark`: `highlight MiniIconsGreen guifg=#c3e88d`.
-- `onedarkpro` purple is better than `tokyodark`: ` highlight MiniIconsPurple guifg=#fca7ea`.
vim.cmd([[
  highlight MiniIconsRed guifg=#ff757f
  highlight MiniIconsCyan guifg=#4fd6be
  highlight MiniIconsGrey guifg=#c8d3f5
  highlight MiniIconsAzure guifg=#0db9d7
  highlight MiniIconsOrange guifg=#ff966c
  highlight MiniIconsYellow guifg=#ffc777
]])

-- Treesitter.
-- `TreesitterContext`                : Background and foreground color of context area, default `NormalFloat`.
-- `TreesitterContextLineNumbers`     : Background and foreground color of line numbers in
--                                      context area, default `LineNr`.
-- `TreesitterContextSeparator`       : Background and foreground color of separator, default `FloatBorder`.
-- `TreesitterContextBottom`          : Highlight of last line of context window, by default
--                                      `NONE`, use to create border via underline highlight.
-- `TreesitterContextLineNumberBottom`: Same as `..Bottom` above, just for line number.
--
-- highlight TreesitterContextLineNumbers highlight Treesitter guifg=#ff757f
-- highlight TreesitterContextSeparator highlight MiniIconsGrey guifg=#c8d3f5
-- highlight TreesitterContextBottom gui=underline guisp=#495162
-- highlight TreesitterContextLineNumberBottom gui=underline guisp=#495162
vim.cmd([[
  highlight! link TreesitterContext Normal
  highlight! link TreesitterContextSeparator LineNr
]])
