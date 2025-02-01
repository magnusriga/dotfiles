--[[
=============================================
Setting options
=============================================

-- See `:help vim.opt`.
-- Option list: `:help option-list`.

=============================================
--]]

-- Enable mouse mode, for resizing splits.
-- vim.opt.mouse = 'a'

-- Don't show the mode, since it is already in the status line.
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
-- See `:help 'clipboard'`.
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent.
vim.opt.breakindent = true

-- Snacks `statuscolumn`, i.e. margin to left containing:
-- Gitsigns (or other signs), line numbers, fold icons, border line, padding, etc.
-- from left to right, i.e. multiple columns.
-- Works, but too high cost? Fold should be shown anyways.
-- vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
-- vim.opt.statuscolumn = "%s%l%C│"
-- vim.opt.statuscolumn = "%C"
vim.opt.statuscolumn = [[%!v:lua.require("util.statuscolumn").get()]]

-- Keep signcolumn on by default.
-- vim.opt.signcolumn = "yes"

-- Show line numbers.
-- Forces statuscolum to show when set,
-- but without "%l" in `opt.statuscolum` nothing is shown.
vim.opt.number = true

-- Relative line numbers, to help with jumping.
-- Forces statuscolum to show when set,
-- but without "%l" in `opt.statuscolum` nothing is shown.
vim.opt.relativenumber = true

-- Characters to fill statusline, statuscolumn, and other specia lines.
-- Omitted falls back to default.
vim.opt.fillchars = {
  -- Mark beginning of fold, in status column.
  foldopen = "",

  -- Show a closed fold.
  foldclose = "",

  -- Filling remaining empty part of `foldtext`.
  -- Default: '·' or '-'.
  fold = " ",

  -- Open fold middle character.
  -- Default: '│' or '|'.
  foldsep = " ",

  -- Fill characters in deleted lines of `diff` option.
  -- Default: '-'.
  diff = "╱",

  -- Fill characters of empty lines below end of buffer.
  eob = " ",
}

-- Allow indents to define folds automatically.
-- Start with all folds open.
-- foldlevelstart is ignored in diff mode, where all folds are closed by default.
-- vim.opt.foldlevelstart = 99
-- vim.opt.foldmethod = "indent"

vim.opt.foldlevel = 99

vim.opt.smoothscroll = true

vim.opt.foldexpr = "v:lua.require'util'.ui.foldexpr()"
vim.opt.foldmethod = "expr"
-- vim.opt.foldtext = ""
-- vim.opt.foldtext = "v:lua.require'util'.ui.foldtext()"

-- Save undo history.
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time.
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time.
-- Displays which-key popup sooner.
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim displays certain whitespace characters.
-- See `:help 'list'`.
-- See `.:help 'listchars'`.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, during typing.
vim.opt.inccommand = "split"

-- Show which line the cursor is on.
-- Highlights e.g. relative line number.
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- When jumping to quickfix items, e.g. after vimgrep, show buffer in new split window,
-- unless it is already open, in which case open window is used.
-- Do not open new splits, it is not efficient when rapidly going through list.
-- vim.opt.switchbuf:append { 'vsplit' }

-- Substitute all matches on each line, not just first, wihout having to specify /g.
-- `%/replaceMe/newText/c` will consider all matches in each line.
vim.opt.gdefault = true

-- When <tab> completion is used on wildcards, first show list, then autocomplete.
-- vim.opt.wildmode = 'list:full'

-- Wildcards, e.g. when used in {file}, should not expand into node_moduels.
-- **/node_modules/** works for all leves.
-- Dotfiles and folders are excluded from wildcard expansion list by default, but will be auto-completed if file starts with dot: .<tab>.
vim.opt.wildignore:append({ "**/node_modules/**" })

-- Ignore case when completing file names and directories.
-- Has no effect when 'fileignorecase' is set.
-- Does not apply when the shell is used to expand wildcards, which happens when there are special characters.
vim.opt.wildignorecase = true

-- :find will start its search from path.
-- Default path value is .,, which means folder of current file, and current working directory (cwd, print with: pwd).
-- vim.opt.path:append { '**' }
vim.opt.path = ".,,**"

-- Make vim diff windows vertical by default.
vim.opt.diffopt:append({ "vertical" })

-- Set absoute width of lines, similar to wrapmargin.
-- Wrapmargin is relative to screen width, whereas textwidth is absolute.
-- Wrapmargin is not used when textwidth is set.
-- textwidth only applies to newly inserted text, not existing text.
vim.opt.textwidth = 90

-- Use formatoptions to decide which type of code is broken with textwidth.
-- Use formatoptions to decide which lines textwidth and "gq" applies to.
-- Prefer wrap or linebreak, which do NOT insert EOL, but just visually drops text to next line.
-- Default formatoptions is supposedly tcqj, but ours is magically set to: cqjrol.
-- Good: textwidth=90, formatoptions=cqjrol.
-- formatoptions options (:h fo-table):
-- t: Text.
-- c: Comments.
-- q: Allow formatting of comments with gq.
-- j: Remove comment leader when joining lines.
-- r: Automatically insert comment leader when hitting Enter in Insert mode.
-- o: Automatically insert comment leader when hitting o or O in Normal mode.
-- l: Lines are not broken when cursor gets to end of textwidth,
--    when they are already longer than textwidth when starting insert mode.
-- n: When formatting text (also comments), lists are recognized using opt.formatlistpat,
--    so indent is applied to next list matching indent of text on first list line.
vim.opt.formatoptions = "cqjroln"

-- Use literal string to avoid having to escape all parts of string, and escape special
-- characters in formatlistpat.
vim.opt.formatlistpat = [[^\s*\(\d\|\*\|-\)\+[\]:.)}\t ]\s*]]

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

-- Increase ttimoutlen from 50ms to 100ms.
-- vim.opt.ttimeoutlen = 100
-- Winbar set automatically by plugins.
-- viv.opt.winbar = true

-- Make Vim auto-write buffer to file, whenever we are abandoning buffer.
-- With the less intrusive opt.autowrite, edit, quit, etc. will not cause auto-write.
-- Better than setting hidden to off, as Vim would then have to re-load file every time it is opened.
-- vim.opt.autowriteall = true

-- Add fzf to runtimepath.
-- When nvim starts, it automatically runs files in certain folders within paths in the
-- runtimepath list. See `:h startup`.
-- As an example, when nvim starts it finds all `plugin` folders within paths in `runtimepath`,
-- then executes all `.lua` and `.vim` files within those `plugin` folders.
-- Thus, when the `fzf` folder is added to runtime path, `fzf/plugins/fzf.vim` is executed,
-- which runs the fzf shell command inside vim, I think?
-- vim.opt.rtp:append("/home/linuxbrew/.linuxbrew/opt/fzf")

---------------------------------------------
-- Modeline: `:h modeline`.
---------------------------------------------
-- vim: ts=2 sts=2 sw=2 et
