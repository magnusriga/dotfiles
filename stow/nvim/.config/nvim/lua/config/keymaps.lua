--[[
=============================================
Keymaps
=============================================
- This file is automatically loaded by `myvim.config.init`.
- See: `:help vim.keymap.set()`.
- See: `:help key-notation`.
- `M-`: Alt-key or meta-key.
- `A-`: Same as `M-`.
- 'rhs' commands are vimscript, not Lua,
  thus use e.g. `.` instead of `..` for concatenation, etc.
=============================================
--]]

---------------------------------
-- Setup.
---------------------------------
-- vim.keymap.set(modes, lhs, rhs, opts)
local map = vim.keymap.set

---------------------------------
-- Navigating.
---------------------------------
-- When navigating up|down, use `gj`|`gk`, as they move by display lines, i.e. not by actual lines.
-- i.e. wrapped lines are counted as separate lines.
-- `v:count`: Count given for last Normal mode command.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

---------------------------------
-- Move to window using `c^hjkl`.
---------------------------------
-- Use built-in w-navigation instead: `<C-w>hjkl`.
-- map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

---------------------------------
-- Resize window using <ctrl> arrow keys.
---------------------------------
-- Not using arrow keys.
-- map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
-- map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
-- map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
-- map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

---------------------------------
-- Move lines.
---------------------------------
-- See: `https://vim.fandom.com/wiki/Moving_lines_up_or_down`.
-- See: `https://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim`.
-- Cannot use alt-keys on macos, option key is used for Aerospace.
-- `v:count1`: Count given for last Normal mode command, defaulting to 1 if no count given.
-- `.+n`     : `n` count lines after current line.
-- `.-n`     : `n` count lines before current line.
-- `>+n`     : `n` count lines after last selected line, as `'>` is mark for end of selection.
-- `gi`      : Re-enter Insert mode at same position as last time.
-- `==`      : Re-indents line, using internal function `C-indenting`, OK in most languages.
-- `gv=`     : `gv` reselects last block, `=` re-indents line.
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

---------------------------------
-- Buffers.
---------------------------------
-- Already built-in Neovim bindings, with same functionality.
-- map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
-- map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- No need, use built-in bindings `[|]b` instead.
-- map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
-- map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- No need, use built-in `C^6|^` to toggle between alternate -and current file.
-- map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
-- map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Delete current buffer, without changing window.
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

-- Delete alternate buffer, without changing window.
-- map("n", "<leader>bo", function()
--   Snacks.bufdelete.other()
-- end, { desc = "Delete Other Buffers" })

-- Delete current buffer and window, i.e. `:bd`.
-- Use built-in `bd` instead.
-- map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

---------------------------------
-- Search.
---------------------------------
-- Clear search and stop snippet on Escape.
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  MyVim.cmp.actions.snippet_stop()
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Clear search, then diff update and redraw,
-- taken from `runtime/lua/_editor.lua`.
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Clear hlsearch / Diff Update / Redraw" }
)

-- Make `n` always search forward and `N` always backward.
-- No need, use built-in behavior of `N` being opposite of `n`,
-- which switches meaning between `/` and `?`.
-- map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
-- map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
-- map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
-- map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------
-----------------------------------------

-- Exit terminal mode in builtin terminal with shortcut that is easier to remember.
-- Will not work in all terminal emulators or in tmux.
-- Stick to vim default: <C-\><C-n>.
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode.
-- No need, not used anyways.
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
-- CTRL+<hjkl> to switch between windows.
-- Disabled, use default: <C-w><C-hljk>.
-- List of window commands: `:help wincmd`.
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Diagnostic keymaps and settings.
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float, twice to focus" })
-- vim.diagnostic.config({ virtual_text = false, severity_sort = true })

-- Clear highlights on search when pressing <Esc> in normal mode.
-- See `:help hlsearch`.
-- vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

---------------------------------------------
-- Modeline: `:h modeline`.
---------------------------------------------
-- vim: ts=2 sts=2 sw=2 et
