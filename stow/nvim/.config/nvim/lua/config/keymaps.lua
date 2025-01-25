--[[
=============================================
Keymaps
=============================================

- Keymaps      : `:help vim.keymap.set()`.

=============================================
--]]

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
