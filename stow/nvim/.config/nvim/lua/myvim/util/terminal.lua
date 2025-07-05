-- ====================================
-- Configure built-in Neovim terminal.
-- ====================================
-- - Sets:
--   - `vim.o.shell`: Name of shell to use for `!` and `:!`, defaults to `$SHELL`.
--   - `vim.o.shellcmdflag`.
--   - `vim.o.shellredir`.
--   - `vim.o.shellpipe`.
--   - `vim.o.shellquote`.
--   - `vim.o.shellxquote`.
--
-- - Below `setup` is called from `lua/config/options.lua`, to change shell used by
--   built-in Neovim terminal, from default `$SHELL` to e.g. `pwsh` (PowerShell).
--
-- - Not currently used, as defualt $SHELL is OK.
-- ====================================

---@class myvim.util.terminal
local M = {}

---@param shell? string
function M.setup(shell)
  vim.o.shell = shell or vim.o.shell

  -- Special handling for pwsh.
  if shell == "pwsh" or shell == "powershell" then
    -- Check if 'pwsh' is executable and set the shell accordingly.
    if vim.fn.executable("pwsh") == 1 then
      vim.o.shell = "pwsh"
    elseif vim.fn.executable("powershell") == 1 then
      vim.o.shell = "powershell"
    else
      return MyVim.error("No powershell executable found")
    end

    -- Setting shell command flags.
    vim.o.shellcmdflag =
      "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"

    -- Setting shell redirection.
    vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'

    -- Setting shell pipe.
    vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'

    -- Setting shell quote options.
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end
end

return M
