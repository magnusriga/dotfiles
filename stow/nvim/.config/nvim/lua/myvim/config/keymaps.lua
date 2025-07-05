--[[
=============================================
Keymaps
=============================================
- This file is automatically loaded by `myvim.config.init`.
- See: `:help vim.keymap.set()`.
- See: `:help key-notation`.
- See: `:help vim-diff`.
- `M-`: Alt-key or meta-key.
- `A-`: Same as `M-`.
- 'rhs' commands are vimscript, not Lua,
  thus use e.g. `.` instead of `..` for concatenation, etc.
- Neovim creates certain keymaps automatically at startup,
  e.g. `[b` and `[d`, which Vim did not. 
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
-- When navigating up|down, use `gj`|`gk`, as they move by display lines,
-- and not by actual lines, so wrapped lines are counted as separate lines.
-- `v:count`: Count given for last Normal mode command.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

---------------------------------
-- Window.
---------------------------------
-- Move to window using `c^hjkl`.
-- No need, use built-in w-bindings: `<C-W>hjkl`.
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Split window with leader.
-- No need, use built-in w-bindings: `<C-W>s|w|c`.
-- map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
-- map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
-- map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Resize window using <ctrl> arrow keys.
-- No need, not using arrow keys.
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

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
-- No need, use identical built-in bindings instead: `[|]b`.
-- map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
-- map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- No need, use built-in bindings instead: `[|]b`.
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
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

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

---------------------------------
-- Undo, redo.
---------------------------------
-- Add undo break-points.
-- No need, use built-in `c^g u`.
-- map("i", ",", ",<c-g>u")
-- map("i", ".", ".<c-g>u")
-- map("i", ";", ";<c-g>u")

---------------------------------
-- Files.
---------------------------------
-- Save file.
-- No need, use built-in `:w`.
-- map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- New file.
-- No need, use built-in `:enew`.
-- map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

---------------------------------
-- Location and quickfix lists.
---------------------------------
-- Open location list and quickfix list.
-- Could use built-in `:lopen` and `:copen`, below adds notification.
-- No need, use built-in `:lopen` and `:copen`.

-- Location list.
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- Quickfix list.
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

---------------------------------
-- Help.
---------------------------------
-- Show help for word under cursor, e.g. function signature, using `keywordprg`.
-- `norm[al][!] {commands}`: Execute Normal mode commands.
-- `!`: Bang command, i.e. ignore mappings.
-- No need, use built-in `K`.
-- map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

---------------------------------
-- Comments.
---------------------------------
-- Add comment above or below.
-- Not interfering with built-in keybindings, OK to keep.
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

---------------------------------
-- Indenting.
---------------------------------
-- Use `<` | `>` to indent, instead of built-in `<<` | `>>`,
-- and enter selection mode, with same selection as last time, after indenting.
-- No need, use built-in `<<` | `>>`.
-- map("v", "<", "<gv")
-- map("v", ">", ">gv")

---------------------------------
-- Trouble.
---------------------------------
-- `trouble.nvim` already provides keybindings `[q` | `q]`,
-- which jump to next|previous trouble item, using whichever trouble buffer is open,
-- i.e. diagnostics | symbols | todos | location list | quickfix list.
-- If `trouble` buffer is not open, `[q` | `q]` will go to next|previous quickfix item.
-- Note: Quickfix list does not contain diagnostics, only grep results,
-- making `[q` | `]q` useless unless `trouble` buffer is open,
-- which remains with below keybindings.
-- No need, to navigate diagnostics use built-in `[d` | `]d`.
-- map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
-- map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

---------------------------------
-- Diagnostics.
---------------------------------
-- Open diagnostics float.
-- Useful, might also use `<leader>e`, and `<leader>e` again to focus float window.
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Open Diagnostics Float." })

--- Jump to diagnostic, helper function.
---@param next boolean
---@param severity? vim.diagnostic.Severity
---@param opts? vim.diagnostic.JumpOpts
local function diagnostic_jump(next, severity, opts)
  local jump_opts = opts or {}
  jump_opts.count = next and 1 or -1
  jump_opts.severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump(jump_opts)
  end
end

-- Previous|Next diagnostic.
-- No need, use identical built-in Neovim bindings, see: `h: vim-diff`.
-- map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
-- map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })

map("n", "]e", diagnostic_jump(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_jump(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_jump(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_jump(false, "WARN"), { desc = "Prev Warning" })

---------------------------------
-- Formatting.
---------------------------------
-- Format buffer.
map({ "n", "v" }, "<leader>cf", function()
  MyVim.format({ force = true })
end, { desc = "Format" })

-- stylua: ignore start

---------------------------------
-- Toggle.
---------------------------------
-- Toggle automatic formatting on save on|off,
-- for buffer if `true` is passed in,
-- otherwise globally for all buffers.
MyVim.format.snacks_toggle():map("<leader>uf")
MyVim.format.snacks_toggle(true):map("<leader>uF")

-- `opt.spell`, for spell checking in English,
-- default only on for text files, e.g. `txt` | `markdown` | ...
-- See: `config/autocmd.lua` and `config/options.lua`.
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")

-- `opt.wrap`, for visual wrapping of lines, on by default.
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")

-- `opt.relativenumber`, for relative line numbers, on by default.
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")

-- `opt.conceallevel`, for hiding text with `conceal` syntax attribute,
-- unless text contains replacement character `*`.
-- `2` by default, `0` when off.
-- No need, never used.
-- Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")

-- `opt.showtabline`, for toggling tabline, `2` by default, i.e. on when more than one tab.
-- No need, always on when more than one tab, and generally use tmux for tabs instead.
-- Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")

-- `opt.background`, for toggling background color between `light` and `dark`, `dark` by default.
-- No need, not using `light` mode.
-- Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background" }):map("<leader>ub")

-- Diagnostics.
Snacks.toggle.diagnostics():map("<leader>ud")

-- Line numbers.
-- No need, always used.
-- Snacks.toggle.line_number():map("<leader>ul")

-- Treesitter, i.e. syntax highlightig.
-- No need, always on.
-- Snacks.toggle.treesitter():map("<leader>uT")

-- Dimming of code, i.e. `Snacks.dim`, e.g. in `Snacks.zen`.
Snacks.toggle.dim():map("<leader>uD")

-- Not using `snacks.nvim` animations.
-- Snacks.toggle.animate():map("<leader>ua")

-- `Snacks.indent`: Colored scope and indentation guides.
Snacks.toggle.indent():map("<leader>ug")

-- Smoothscroll with mouse wheel, not used.
-- Snacks.toggle.scroll():map("<leader>uS")

-- Profiler for Lua files only, not used.
-- Snacks.toggle.profiler():map("<leader>dpp")
-- Snacks.toggle.profiler_highlights():map("<leader>dph")

-- Inlay hints.
if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- Zen mode, zoom.
-- No need, not working.
-- Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")

-- Zen mode, normal.
-- No need, not used.
-- Snacks.toggle.zen():map("<leader>uz")

---------------------------------
-- Lazygit.
---------------------------------
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit( { cwd = MyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end

---------------------------------
-- Git.
---------------------------------
-- Git log: Current file.
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })

-- Git log: Root directory.
-- No need, already created in: `plugins/fzf.lua`.
-- map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = MyVim.root.git() }) end, { desc = "Git Log" })

-- Git log: Current working directory.
-- No need, already created in: `plugins/fzf.lua`.
-- map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })

-- Git blame.
-- No need, not using `Snacks.picker(..)`, and `fzf-lua` presentation not useful.
-- map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
-- map("n", "<leader>gb", "<cmd>FzfLua git_blame<CR>", { desc = "Git Blame" })

-- Open git remote url for current file, i.e. blob, with `vim.ui.open(path, opt)`,
-- which opens url with macOS `open` | Windows `explorer.exe` | Linux `xdg-open`.
-- Normally opens url in browser, but not over ssh / when no gui, thus disable.
-- map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })

-- Copy git remote url into X11 system clipboard, i.e. register `+`.
map({"n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

---------------------------------
-- Quit.
---------------------------------
-- Quit all windows, buffers, tabs, and Neovim.
-- No need, use built-in `:qa`.
-- map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

---------------------------------
-- Treesitter inspect.
---------------------------------
-- Show highlights for word under cursor.
-- No need, use built-in `:Inspect`.
-- map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Show treesitter tree for buffer.
-- Same as ":InspectTree", except sends "I" after opening tree,
-- i.e. shows language of each node.
map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })

---------------------------------
-- Terminal.
---------------------------------
-- Snacks terminal keybindings.
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = MyVim.root() }) end, { desc = "Terminal (Root Dir)" })
map("n", "<c-/>",      function() Snacks.terminal(nil, { cwd = MyVim.root() }) end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>",      function() Snacks.terminal(nil, { cwd = MyVim.root() }) end, { desc = "which_key_ignore" })

-- Close current window when in terminal mode.
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Exit terminal mode in builtin terminal with shortcut that is easier to remember.
-- Will not work in all terminal emulators or in tmux.
-- No need, use built-in: <C-\><C-n>.
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

---------------------------------
-- Tabs.
---------------------------------
-- Side note: <Tab>, by itself, jumps to newer entry in jump list, like `ctrl-o`.
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

---------------------------------
-- Send "gsah" keystrokes in markdown file selection.
-- Does not work.
---------------------------------
-- map("x", "<leader>h", "gsah", { desc = "Send gsah keystrokes to selected text" })
