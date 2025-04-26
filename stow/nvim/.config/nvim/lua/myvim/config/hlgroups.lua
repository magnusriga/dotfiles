-- Colors.
-- - Bright pink: #EA0FFA
-- - Bright green: #39D877

-- General.
-- - Also applies to WhichKey and others.
-- - `WhichKeyFloat`: Links to NormalFloat, below linked to Normal,
-- - `WhichKeyBorder`: Links to FloatBorder, below changed to match `fzf-lua`.
-- - Result: Floating windows have same background as normal windows, just with border.
vim.cmd([[
  " highlight Normal guifg=#c8d3f5 guibg=#16161d

  highlight NormalFloat guifg=#c8d3f5 guibg=#1e2030
  highlight FloatBorder guifg=#589ed7 guibg=#1e2030
  highlight WinSeparator guifg=#495162 guibg=#1e2030

  highlight LineNrAbove guifg=#495162 guibg=#16161d
  " LineNr set in condition logic below.
  " highlight LineNr guifg=#ff966c guibg=#16161d
  highlight LineNrBelow guifg=#495162 guibg=#16161d
]])

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
  highlight! link FzfLuaPreviewTitle FloatTitle
  highlight FzfLuaPreviewBorder guifg=#589ed7 guibg=None
]])

-- `snacks.nvim` picker.
vim.cmd([[
  highlight SnacksPicker guifg=#c8d3f5 guibg=#1e2030
  highlight SnacksPickerBorder guifg=#589ed7 guibg=#1e2030
  highlight SnacksPickerIcon guifg=#589ed7 guibg=#1e2030
  highlight SnacksPickerPrompt guifg=#589ed7 guibg=#1e2030
  highlight SnacksPickerDir guifg=#828bb8
  " `SnacksPickerToggle`: Characters next to title, indicating:
  " - follow (`f`): Follow symlinks when searching, i.e. in grep list.
  " - hidden (`h`): Show hidden files.
  " - ignored (`i`): Show ignored files.
  " - modified (`m`): Show only modified buffers, i.e. buffer list only.
  highlight SnacksPickerToggle guifg=#828bb8 guibg=#1e2030

  " `SnacksPickerBox`: First box of picker, i.e. not preview box.
  highlight SnacksPickerBoxTitle guifg=#ff966c guibg=#1e2030 

  " `SnacksPickerPreview`: Second box of picker, i.e. preview box.
  highlight! link SnacksPickerPreview Normal
  highlight SnacksPickerPreviewBorder guifg=#589ed7 guibg=None

  highlight SnacksPickerSelected guifg=#ff007c
  highlight SnacksPickerTree guifg=#495162 guibg=None
  highlight! link SnacksPickerCursorLine CursorLine

  " `SnacksPickerInput`: Applies to search box at top of picker list, not to `vim.input` box.
  highlight SnacksPickerInput guifg=#ff966c guibg=#1e2030
  highlight SnacksPickerInputTitle guifg=#ff966c guibg=#1e2030
  highlight SnacksPickerInputBorder guifg=#ff966c guibg=#1e2030 
  highlight SnacksPickerInputIcon guifg=#ff966c guibg=#1e2030

  " `SnacksInput`: Applies to `vim.input` box, not to search box at top of list.
  highlight SnacksInput guifg=#c8d3f5 guibg=#1e2030
  highlight SnacksInputNormal guifg=#c8d3f5 guibg=#1e2030
  highlight SnacksInputTitle guifg=#ffc777 guibg=#1e2030
  highlight SnacksInputBorder guifg=#ffc777 guibg=#1e2030
  highlight SnacksInputIcon guifg=#589ed7 guibg=#1e2030
  highlight! link SnacksInputCursorLine CursorLine

  " Same as above, but with `None` background.
  " highlight SnacksInput guifg=#c8d3f5 guibg=None
  " highlight SnacksInputNormal guifg=#c8d3f5 guibg=None
  " highlight SnacksInputTitle guifg=#ffc777 guibg=None
  " highlight SnacksInputBorder guifg=#ffc777 guibg=None
  " highlight SnacksInputIcon guifg=#589ed7 guibg=None
  " highlight SnacksInputCursorLine  guibg=None
]])

-- Pmenu, e.g. completion menu.
-- - Used by `blink.cmp`, etc.
vim.cmd([[
  highlight Pmenu guifg=#c8d3f5 guibg=#1e2030
  highlight! link PmenuSel CursorLine
  highlight PmenuThumb guifg=#1e2030 guibg=#589ed7

  " highlight! link PmenuKind Pmenu
  " highlight! link PmenuKindSel PmenuSel

  " highlight! link PmenuExtra Pmenu
  " highlight! link PmenuExtraSel PmenuSel

  " `PmenuSbar`: Scrollbar gutter.
  " highlight PmenuSbar guibg=#27293a

  " `PmenuThumb`: Scrollbar thumb.
  " highlight PmenuThumb guibg=#3b4261

  " highlight PmenuMatch guifg=#589ed7 guibg=#1e2030
  " highlight PmenuMatchSel guifg=#589ed7 guibg=#363c58
]])

-- Avante.
vim.cmd([[
  highlight AvanteSidebarWinSeparator guifg=#495162 guibg=#1e2030
  highlight AvanteSidebarWinHorizontalSeparator guifg=#495162 guibg=#1e2030
]])

-- Blink.cmp.
-- - `*Menu`: Links to `Pmenu*`, set above.
-- - `*Doc`: Links to `NormalFloat`, set above.
vim.cmd([[
  " Links to Pmenu, set above.
  " highlight BlinkCmpMenu guibg=#1e2030
  " highlight BlinkCmpScrollBarThumb guifg=#1e2030 guibg=#589ed7
  " highlight! link BlinkCmpCusorLineMenuHack CursorLine
  
  highlight BlinkCmpMenuBorder guifg=#589ed7 guibg=#1e2030
  highlight BlinkCmpMenuSelection guibg=#2f334d

  highlight BlinkCmpDoc guifg=#abb2bf guibg=#16161d
  highlight BlinkCmpDocBorder guifg=#5c6370 guibg=Normal
  highlight BlinkCmpDocSeparator guifg=#5c6370 guibg=Normal

  " Kind highlight groups set by `blink.cmp` | `mini.icons`, some overwritten here.
  highlight BlinkCmpKindVariable cterm=bold gui=bold guifg=#589ed7
  highlight BlinkCmpKindField cterm=bold gui=bold guifg=#589ed7
  highlight BlinkCmpKindConstructor cterm=bold gui=bold guifg=#c678dd
  highlight BlinkCmpKindFunction cterm=bold gui=bold guifg=#c678dd
  highlight BlinkCmpKindMethod cterm=bold gui=bold guifg=#c678dd

  highlight BlinkCmpLabelDeprecated cterm=strikethrough gui=strikethrough guifg=#7f848e
  highlight BlinkCmpLabelMatch guifg=#39D877
  highlight! link BlinkCmpLabelDescription Comment
  " highlight BlinkCmpLabelMatch guifg=#EA0FFA
  " highlight BlinkCmpLabelMatch guifg=#ff966c
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

-- `render-markdown.nvim`.
vim.cmd([[
  highlight @markup.list.markdown guifg=#ff966c
  highlight RenderMarkdownBullet guifg=#ff966c
  highlight RenderMarkdownDash guifg=#ff966c

  " highlight @markup.list.markdown guifg=#589ed7
  " highlight RenderMarkdownBullet guifg=#589ed7
  " highlight RenderMarkdownDash guifg=#589ed7
  " Good: #589ed7

  " highlight @markup.list.markdown guifg=#FFC777
  " highlight RenderMarkdownBullet guifg=#FFC777
  " highlight RenderMarkdownDash guifg=#FFC777

  highlight RenderMarkdownLink guifg=#65BCFF
  highlight @markup.link.label guifg=#65BCFF

  highlight RenderMarkdownTableRow guifg=#ff966c

  highlight RenderMarkdownCode guibg=None

  highlight RenderMarkdownSign guibg=#222436

  highlight RenderMarkdownCodeInline guifg=#82AAFF guibg=#1e2030
  highlight @markup.raw.markdown_inline guifg=#82AAFF guibg=#1e2030

  highlight RenderMarkdownCodeInline guifg=#82AAFF guibg=None
  highlight @markup.raw.markdown_inline guifg=#82AAFF guibg=None

  " highlight RenderMarkdownCodeInline guifg=#82AAFF guibg=#444A73
  " highlight @markup.raw.markdown_inline guifg=#82AAFF guibg=#444A73

  " LazyVim: guifg=#82AAFF guibg=#444A73
  " highlight RenderMarkdownCodeInline guifg=#7aa2f7 guibg=None
  " highlight @markup.raw.markdown_inline guifg=#7aa2f7 guibg=None
  " Good: #7aa2f7
  " OK  : #C099FF
  " Evernote: guifg=#F37E73 guibg=#262626
  " Green: #39D877 (OK) or #98c379 (OK)
  " vscode: #fc618d
  " vscode: #7bd88f

  highlight SpellBad cterm=underline gui=underline guisp=#C53B53 guifg=None
  highlight SpellCap cterm=underline gui=underline guisp=#FFC777 guifg=None
  highlight SpellRare cterm=underline gui=underline guisp=#4FD6BE guifg=None
  highlight SpellLocalRare cterm=underline gui=underline guisp=#0DB9D7 guifg=None

  highlight RenderMarkdownH1 cterm=bold gui=bold guifg=#82AAFF
  highlight RenderMarkdownH2 cterm=bold gui=bold guifg=#FFC777
  highlight RenderMarkdownH3 cterm=bold gui=bold guifg=#C3E88D
  highlight RenderMarkdownH4 cterm=bold gui=bold guifg=#4FD6BE
  highlight RenderMarkdownH5 cterm=bold gui=bold guifg=#C099FF
  highlight RenderMarkdownH6 cterm=bold gui=bold guifg=#FCA7EA
  highlight RenderMarkdownH7 cterm=bold gui=bold guifg=#FF966C
  highlight RenderMarkdownH8 cterm=bold gui=bold guifg=#FF757F

  highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=#82AAFF
  highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=#FFC777
  highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=#C3E88D
  highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=#4FD6BE
  highlight @markup.heading.5.markdown cterm=bold gui=bold guifg=#C099FF
  highlight @markup.heading.6.markdown cterm=bold gui=bold guifg=#FCA7EA
  highlight @markup.heading.7.markdown cterm=bold gui=bold guifg=#FF966C
  highlight @markup.heading.8.markdown cterm=bold gui=bold guifg=#FF757F

  highlight RenderMarkdownH1Bg guibg=#2C314A
  highlight RenderMarkdownH2Bg guibg=#38343D
  highlight RenderMarkdownH3Bg guibg=#32383F
  highlight RenderMarkdownH4Bg guibg=#273644
  highlight RenderMarkdownH5Bg guibg=#32304A
  highlight RenderMarkdownH6Bg guibg=#383148
  highlight RenderMarkdownH7Bg guibg=#382F3B
  highlight RenderMarkdownH8Bg guibg=#382C3D
]])

-- =====================================
-- Conditinal highlighting.
-- =====================================
-- Define highlight colors.
local highlights = {
  Normal = { fg = "#c8d3f5", bg = "#222436" },
  LineNr = { fg = "#ff966c", bg = "#222436" },
  LineNrAbove = { fg = "#3b4261", bg = "#222436" },
  LineNrBelow = { fg = "#3b4261", bg = "#222436" },
}

-- Set highlight groups.
for group, attrs in pairs(highlights) do
  vim.api.nvim_set_hl(0, "Markdown" .. group, attrs)
end

-- List of filetypes for custom highlighting.
local highlighted_filetypes = {
  ["markdown"] = true,
  -- ["avante"] = true,
  -- ["avanteinput"] = true,
  -- ["avanteselectedfiles"] = true,
  -- ["blink-cmp-menu"] = true,
  -- ["blink-cmp-documentation"] = true,
}

-- Update highlight groups for current window, if it contains buffer with
-- `markdown` filetype.
local function update_window_highlights()
  local win_id = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win_id)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })

  -- Convert filetype to lowercase for case-insensitive comparison
  ft = ft:lower()

  -- Get current winhighlight setting.
  local current_winhighlight = vim.api.nvim_get_option_value("winhighlight", { win = win_id })

  if highlighted_filetypes[ft] then
    -- Prepare highlight additions.
    local our_highlights = "Normal:MarkdownNormal,LineNr:MarkdownLineNr,"
      .. "LineNrAbove:MarkdownLineNrAbove,LineNrBelow:MarkdownLineNrBelow"

    -- Function to merge highlights without duplicates.
    local function merge_highlights(current, new)
      if current == "" then
        return new
      end

      -- Parse current highlight settings into table.
      local highlights_table = {}
      for part in current:gmatch("[^,]+") do
        local group, target = part:match("([^:]+):([^:]+)")
        if group then
          highlights_table[group] = target
        end
      end

      -- Add/override with new highlight settings.
      for part in new:gmatch("[^,]+") do
        local group, target = part:match("([^:]+):([^:]+)")
        if group then
          highlights_table[group] = target
        end
      end

      -- Convert back to string.
      local result = {}
      for group, target in pairs(highlights_table) do
        table.insert(result, group .. ":" .. target)
      end

      return table.concat(result, ",")
    end

    -- Merge our highlights with existing ones.
    local merged_highlights = merge_highlights(current_winhighlight, our_highlights)
    vim.api.nvim_set_option_value("winhighlight", merged_highlights, { win = win_id })
  else
    -- For non-target filetypes, remove only custom highlights.
    if current_winhighlight ~= "" then
      -- Parse current highlight settings.
      local result = {}
      local modified = false

      for part in current_winhighlight:gmatch("[^,]+") do
        local group, target = part:match("([^:]+):([^:]+)")
        if group and target then
          -- Skip custom highlights.
          if
            target ~= "MarkdownNormal"
            and target ~= "MarkdownLineNr"
            and target ~= "MarkdownLineNrAbove"
            and target ~= "MarkdownLineNrBelow"
          then
            table.insert(result, part)
          else
            modified = true
          end
        end
      end

      -- Update only if group was removed.
      if modified then
        vim.api.nvim_set_option_value("winhighlight", table.concat(result, ","), { win = win_id })
      end
    end
  end
end

-- Create autogroup for markdown highlights, cleared when reloaded.
local augroup = vim.api.nvim_create_augroup("MarkdownHighlights", { clear = true })

-- Update highlights when buffers/windows change.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "FileType" }, {
  group = augroup,
  callback = update_window_highlights,
})
