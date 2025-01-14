--[[
=============================================
Autocommands
=============================================

-- See `:help lua-guide-autocommands`.

=============================================
--]]

-- Save session, and reopen when Vim starts.
-- vim.api.nvim_create_autocmd('VimLeave', {
--   desc = 'Save session when Vim closes.',
--   group = vim.api.nvim_create_augroup('save-session', { clear = true }),
--   callback = function()
--     vim.cmd 'mksession! ~/.vim/sessions/shutdown_session.vim'
--   end,
-- })

-- Keymap to load previously saved session.
-- vim.keymap.set('n', '<F7>', ':source ~/.vim/shutdown_session.vim', { desc = 'Load previous session...' })

-- TODO: Replace above with persistance.

---------------------------------------------
-- Autocommand groups
---------------------------------------------
-- Autocommand group for lsp formatting, to prevent multiple formatters on same file.
-- Cannot have clear = true, because attaching to new buffer, i.e. opening new
-- file, will cause the autocommand for a previously opened buffer to be deleted.
local augroup_lsp_format = vim.api.nvim_create_augroup('lsp-format', { clear = false })

---------------------------------------------
-- Autocommands
---------------------------------------------
-- Highlight when yanking (copying) text.
-- Try it with `yap`.
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
