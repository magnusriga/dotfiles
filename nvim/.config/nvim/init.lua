--[[

=============================================
Useful commands
=============================================
- `:Tutor`
- `:checkhealth`

=============================================
Useful help pages
=============================================
- `:h init`: Neovim startup steps.
- `:h ins-completion`: Neovim auto-completion in Insert mode.
- `:h runtimepath`: Default directories searched for runtime file,
  e.g at initialization and when running `:ru[ntime][!] [where] {file}`.

=============================================
Useful environment variables
=============================================
- $MYVIMRC: Initialization file,
            set at Neovim initialization to first found initialization file.

=============================================
Neovim initialization (aka. startup)
=============================================
- `runtimepath`, excerpt of default directories (full list: `:h runtimepath`).
  - `$HOME/.config/nvim/.config/nvim`           : Personal initializations. 
  - `$HOME/.config/nvim/.local/share/nvim/site` : Own plugins.

- Initialization excerpt (full list: `:h initialization`).
  1. Load initialization file: `.config/nvim/init.lua`.
  2. Load plugins: All `.lua` and `.vim` files at any level within `plugin` directories,
                   directly within runtimepath folders,
		   and within runtimepath/pack/*/start/*.

- When looking up files in runtimepath, nvim looks in both:
  - runtimepath
    - `$HOME/.config/nvim`
    - `$HOME/.local/share/nvim/site`
- runtimepath/pack/*/start/*

- Examples:
  - `.lua` files in this directory are loaded automatically at Neovim start: `.local/share/nvim/site/pack/*/start/*/plugin`.

- Additional notes:
  - `<runtimepath>/pack/*/start/*/syntax/some.vim` will be found by (built-in) syntax highlighting when file opens,
    as pack/*/start/*/ is searched with runtimepath is searched.

=============================================
nvim CLI options
=============================================
- `—clean`: Run nvim without initialization file or `<runtimepath>/plugin` directories loading.
- `—noplugin`: Run nvim without `<runtimepath>/plugin` directories loading.

=============================================
require()
=============================================
- `require(‘foo’)` searches for `foo.lua` at top-level of `lua` directory,
  directly within runtimepath folders, and within `<runtimepath>/pack/*/start/*`.
- Deeper levels within `lua` directory can be specified with `/` or `.`:
  `require(‘foo/bar’)` | `require(‘foo.bar’)`.
- Subfolder containing `init.lua` can be required without specifying `init`, just as if it was in top-level `lua` folder.
- If required module is not found, script execution is aborted, avoided with pcall().
- Require caches modules on first run, unlike source, so `.lua` files are not run again on second+ require.

- Examples:
  - require(‘foo) searches for `foo.lua` in `<runtimepath>/lua` and `<runtimepath>/lua/foo/init.lua`.
  - require(‘foo.bar’) searches for `bar.lua` in `<runtimepath>/lua/foo` and `<runtimepath>/lua/foo/bar/init.lua`.

--]]

-- Set <space> as the leader key.
-- See: `:help mapleader`
-- NOTE: Must happen before plugins are loaded, otherwise wrong leader will be used.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nerd Font installed and selected in the terminal.
vim.g.have_nerd_font = true

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
