--[[
=============================================
Neovim User Configuration File
=============================================

---------------------------------------------
Useful commands
---------------------------------------------
- `:Tutor`
- `:checkhealth`

---------------------------------------------
Useful help pages
---------------------------------------------
- `:h init`           : Neovim startup steps.
- `:h ins-completion` : Neovim auto-completion in Insert mode.
- `:h runtimepath`    : Default directories searched for runtime file,

---------------------------------------------
Useful environment variables
---------------------------------------------
- $MYVIMRC: Set on Neovim startup to first initialization file found.

---------------------------------------------
Neovim initialization (aka. startup)
---------------------------------------------
- `runtimepath` directories:
  - Default: `:h runtimepath`.
  - Excerpt:
    - `$HOME/.config/nvim/.config/nvim`           : Personal initializations. 
    - `$HOME/.config/nvim/.local/share/nvim/site` : Own plugins.

- Initialization steps:
  - All steps: `:h initialization`.
  - Excerpt:
    1. Load initialization file: `.config/nvim/init.lua`.
    2. Load plugins: All `.lua` and `.vim` files at any level within `plugin` directories,
       directly within runtimepath folders, and within `runtimepath/pack/*/start/*`.

- When looking up files in runtimepath, nvim looks in both:
  - runtimepath
    - `$HOME/.config/nvim`
    - `$HOME/.local/share/nvim/site`
  - `<runtimepath>/pack/*/start/*`

- Examples:
  - `.lua` files in this directory are loaded automatically at Neovim start:
    `.local/share/nvim/site/pack/*/start/*/plugin`.

- Additional notes:
  - `<runtimepath>/pack/*/start/*/syntax/some.vim` will be found by (built-in)
    syntax highlighting when file opens, since `pack/*/start/*/` is searched when
    runtimepath is searched.

---------------------------------------------
nvim CLI options
---------------------------------------------
- `—clean`    : Run nvim without executing initialization file or `<runtimepath>/plugin` directories.
- `—noplugin` : Run nvim without executing `<runtimepath>/plugin` directories.

---------------------------------------------
`require(module)`
---------------------------------------------
- `require(‘foo’)` searches for `foo.lua` at top-level of `lua` directory,
  directly within runtimepath folders, and within `<runtimepath>/pack/*/start/*`.
- Deeper levels within `lua` directory can be specified with `/` or `.`:
  `require(‘foo/bar’)` | `require(‘foo.bar’)`.
- Subfolder containing `init.lua` can be required without specifying `init`,
  just as if it was in top-level `lua` folder.
- If required module is not found, script execution is aborted, avoided with pcall().
- Require caches modules on first run, unlike source,
  so `.lua` files are not run again on second+ require.

- Examples:
  - `require(‘foo')` searches for `foo.lua` in `<runtimepath>/lua` and `<runtimepath>/lua/foo/init.lua`.
  - `require(‘foo.bar’)` searches for `bar.lua` in `<runtimepath>/lua/foo` and
    `<runtimepath>/lua/foo/bar/init.lua`.

=============================================
--]]

---------------------------------------------
-- Filetype.
---------------------------------------------
-- Set custom filetypes for specific files, by extension, filename, or pattern.
vim.filetype.add {
  filename = {
    ['.shrc'] = 'sh',
  }
}

-- Never request typescript-language-server for formatting
-- vim.lsp.buf.format {
--   filter = function(client)
--     return client.name ~= 'tsserver'
--   end,
-- }

-- vim.lsp.set_log_level 'debug'

-- local eslint = {
--   lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
--   lintStdin = true,
--   lintFormats = { '%f:%l:%c: %m' },
--   lintIgnoreExitCode = true,
--   -- formatCommand = 'eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}',
--   -- formatStdin = true,
-- }

---------------------------------------------
-- Helper functions.
---------------------------------------------
-- Filter for `vim.lsp.format()`, ensuring only null_ls is used for formatting
-- buffers where typescript-tool is attached, as the other LSPs used for TS/JS
-- files do not have capabilities: formattingProvider | rangeFormattingProvider.
-- To check LSP clients attached to a buffer: `lua =vim.lsp.get_clients()`
-- To check capabilities of their respective LSP servers, look at filed:
-- `server_capabilities`.
-- Check attacked LSPs: `:checkhealth lsp` | `:LspInfo`.
local null_ls_filter = function(client)
  -- vim.print('in format filter, client.name is: ' .. client.name)
  return client.name ~= 'typescript-tools'
end

-- Function for formatting buffer, using all attached LSPs that supports
-- formatting, except `typescript-tools`, because `null_ls` should be used
-- instead for TS/JS formatting.
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format {
    bufnr = bufnr,
    -- Restrict formatting to client with this id.
    -- Do not include `id = client_by_id.id`, because order LSPs attach is
    -- non-deterministic, `clear` in `nvim_create_autogroup` means autocommand
    -- is only added for the last attached LSPs, and `format()` should not
    -- simply use the last attached LSP.
    -- Thus, used filter instead, which picks the right LSP by name, i.e.
    -- null_lsp.
    -- id = client_by_id.id,
    -- async = false means format is done before buffer write is allowed to proceed,
    -- not in parallel. false is dafault, so setting to false is redundant.
    async = false,
    -- vim.lsp.buf.format normally runs formatting by all attached LSPs
    -- with formatting capabilities. Instead, add filter so vim.lsp.format()
    -- only runs formatting by null_ls, which is set up to use prettierd.
    filter = null_ls_filter,
  }
end

-- Helper function that allows applying code action fix,
-- if there is only one code action with the specified title.
local apply_code_action_fix = function()
  vim.lsp.buf.code_action {
    filter = function(code_action)
      if vim.startswith(code_action.title, 'Apply suggested fix') then
        return true
      end
      return false
    end,
    apply = true,
  }
end


---------------------------------------------
-- Mapleader.
---------------------------------------------
--- NOTE: Move to options, see lazyvim.
-- Set <space> as leader key.
-- See: `:help mapleader`.
-- Must happen before plugins are loaded, otherwise wrong leader will be used.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

---------------------------------------------
-- Fonts variable for lazy.nvim config and specs.
---------------------------------------------
-- Nerd Font installed and selected in the terminal.
vim.g.have_nerd_font = true

---------------------------------------------
-- Bootstrap lazy.nvim, plugins, and other modules, in
-- $HOME/.config/nvim/config/init.lua.
---------------------------------------------
require("config") 

---------------------------------------------
-- Modeline: `:h modeline`.
---------------------------------------------
-- vim: ts=2 sts=2 sw=2 et
