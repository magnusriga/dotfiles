---------------------------------------------
-- Mapleader.
---------------------------------------------
-- Set `<space>` as leader key.
-- See: `:help mapleader`.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- `statusline` on last window only, not one per window, i.e. global `statusline`.
-- Needed, as views can only be fully collapsed with global `statusline`.
vim.opt.laststatus = 3

vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

-- Show line numbers.
vim.opt.number = true

-- Show relative line numbers, needed for custom statuscolumn
-- to recalculate items on each cursor move.
vim.opt.relativenumber = true
