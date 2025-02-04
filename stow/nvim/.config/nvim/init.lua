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

---------------------------------------------
-- Bootstrap lazy.nvim plugin manager.
-- 1. Clone repo `lazy.nvim.git` into `lazypath` directory: `$HOME/.local/share/nvim/lazy/lazy.nvim`.
-- 2. Add `lazypath` to runtimepath, so `require("lazy")` resolves to: `<lazypath>/lua/lazy`.
---------------------------------------------
require("util.lazy-bootstrap")

---------------------------------------------
-- Initialization.
-- Create autocommands to register keybindings
-- and additional autocommands, which will run
-- after lazy.nvim is done installing plugins
-- and running plugins' main `setup()`,
-- i.e. at VeryLazy event.
---------------------------------------------
require("config").setup()

---------------------------------------------
-- Load all plugins, including those imported
-- from `lua/plugins` directory.
-- VeryLazy event is called when done.
---------------------------------------------
require("util.lazy-plugins")
