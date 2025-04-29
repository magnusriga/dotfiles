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

-- =========================================================================================================
-- Neovim Setup.
-- =========================================================================================================

-------------------------------------------
-- Bootstrap lazy.nvim plugin manager.
-- 1. Clone repo `lazy.nvim.git` into `lazypath` directory: `$HOME/.local/share/nvim/lazy/lazy.nvim`.
-- 2. Add `lazypath` to runtimepath, so `require("lazy")` resolves to: `<lazypath>/lua/lazy`.
---------------------------------------------
require("myvim.util.lazy-bootstrap")

---------------------------------------------
-- Initialization.
-- Create autocommands to register keybindings
-- and additional autocommands, which will run
-- after lazy.nvim is done installing plugins
-- and running plugins' main `setup()`,
-- i.e. at VeryLazy event.
---------------------------------------------
require("myvim.config").setup()

---------------------------------------------
-- Load all plugins, including those imported
-- from `lua/plugins` directory.
-- VeryLazy event is called when done.
---------------------------------------------
require("myvim.util.lazy-plugins")

-- =============================================
-- Minimal repo.
-- - Comment in above, and comment out below.
-- - NOTE: Only run from $HOME, since it clones into `<cwd>/.repro`.
-- =============================================
-- vim.env.LAZY_STDPATH = ".repro"
-- load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
--
-- vim.fn.mkdir(".repro/vault", "p")
--
-- vim.o.conceallevel = 2
--
-- local plugins = {
--   {
--     "obsidian-nvim/obsidian.nvim",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     opts = {
--       completion = {
--         blink = true,
--         nvim_cmp = false,
--       },
--       workspaces = {
--         {
--           name = "test",
--           -- path = vim.fs.joinpath(vim.uv.cwd(), ".repro", "vault"),
--           path = "~/notes/vaults/personal",
--         },
--       },
--     },
--   },
--
--   -- **Choose your renderer**
--   { "MeanderingProgrammer/render-markdown.nvim", dependencies = { "echasnovski/mini.icons" }, opts = {} },
--   -- { "OXY2DEV/markview.nvim", lazy = false },
--
--   -- **Choose your picker**
--   "nvim-telescope/telescope.nvim",
--   -- "folke/snacks.nvim",
--   -- "ibhagwan/fzf-lua",
--   -- "echasnovski/mini.pick",
--
--   {
--     "saghen/blink.cmp",
--     opts = {
--       fuzzy = { implementation = "lua" }, -- no need to build binary
--       keymap = {
--         preset = "default",
--       },
--     },
--   },
-- }
--
-- require("lazy.minit").repro({ spec = plugins })
--
-- vim.cmd("checkhealth obsidian")

-- =============================================
-- Testing.
-- =============================================
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- local lazypath = "/tmp/lazy/lazy.nvim"
-- if not (vim.uv or vim.loop).fs_stat(lazypath) then
--   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
--   local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
--   if vim.v.shell_error ~= 0 then
--     vim.api.nvim_echo({
--       { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
--       { out, "WarningMsg" },
--       { "\nPress any key to exit..." },
--     }, true, {})
--     vim.fn.getchar()
--     os.exit(1)
--   end
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- require('config').setup()
--
-- vim.lsp.enable({'luals'})
--
-- require("lazy").setup({
--   spec = {
--     -- add LazyVim and import its plugins
--     -- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
--     -- import/override with your plugins
--     { import = "plugins" },
--     -- Import other plugins, from sub-folders.
--     { import = "myvim/plugins/util" },
--     { import = "myvim/plugins/dap" },
--     { import = "myvim/plugins/lang" },
--     { import = "myvim/plugins/ai" },
--   },
--   root = "/tmp/lazy", -- directory where plugins will be installed
--   defaults = {
--     -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
--     -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
--     lazy = false,
--     -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
--     -- have outdated releases, which may break your Neovim install.
--     version = false, -- always use the latest git commit
--     -- version = "*", -- try installing the latest stable version for plugins that support semver
--   },
--   install = { colorscheme = { "tokyonight", "habamax" } },
--   checker = {
--     enabled = true, -- check for plugin updates periodically
--     notify = false, -- notify on update
--   }, -- automatically check for plugin updates
--   performance = {
--     rtp = {
--       -- disable some rtp plugins
--       disabled_plugins = {
--         "gzip",
--         -- "matchit",
--         -- "matchparen",
--         -- "netrwPlugin",
--         "tarPlugin",
--         "tohtml",
--         "tutor",
--         "zipPlugin",
--       },
--     },
--   },
-- })
