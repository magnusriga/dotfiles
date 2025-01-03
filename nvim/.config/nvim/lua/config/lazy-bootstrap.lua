--[[
=============================================
Bootstrap lazy.nvim plugin manager. 
=============================================
-- 1. Clone repo `lazy.nvim.git` into `lazypath` directory: `$HOME/.local/share/nvim/lazy/lazy.nvim`.
-- 2. Add `lazypath` to runtimepath, so `require("lazy")` resolves to: `<lazypath>/lua/lazy`.

- Information:
  - `:help lazy.nvim.txt`.
  - https://github.com/folke/lazy.nvim.
=============================================
--]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.print('Bootstrapped lazy.nvim, adding lazypath to opt.rtp', lazypath)
vim.opt.rtp:prepend(lazypath)
vim.print('runtimepath is now: ', vim.o.rtp)

---------------------------------------------
-- Modeline: `:h modeline`.
---------------------------------------------
-- vim: ts=2 sts=2 sw=2 et
