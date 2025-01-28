--[[
=============================================
Configure lazy.nvim Plugin Manager and Load Plugins.
=============================================

---------------------------------------------
Plugin install location
---------------------------------------------
- When lazy.nvim installs plugins, it copies entire plugin directory,
  either Github repo or local directory, into
  `Config.options.root/<plugin.name>`, e.g.
  `vim.fn.stdpath("data") .. "/lazy”/<repo>`, e.g.
  `$HOME/.local/share/nvim/lazy/<repo>`,
  saved internally in lazy.nvim's `Config.plugins[<repo>].dir`,
  where `<repo>` is the name of the GitHub repository: <user>/<repo>.

---------------------------------------------
Execution order
---------------------------------------------
- lazy.nvim first collects all spec tables, for each plugin,
  including each table inside `spec` field of lazy.nvim configuration table,
  and each table returned from top-level modules inside directories specified
  in imports: `{ import = "<directory>" }`.
- After all spec tables have been added to `Config.plugins`,
  lazy.nvim proceeds to install, e.g. clone, each plugin.
- Finally, for every plugin in `Config.plugins` table,
  lazy.nvim executes either user-defined `Config.plugins[name].config(plugins, opts)`,
  or if that is not defined then it executes `require("<name>").setup(opts)`,
  where `<name>` is either `spec.name`, which is needed for local plugins,
  i.e. when source is defined with `dir` instead of spec[1] or `url`,
  or name of GitHub repository, e.g. `<repo>` in `<user>/<repo>` within spec[1].

---------------------------------------------
Priorities
---------------------------------------------
- When lazy.nvim loads plugins,
  i.e. executes either user-defined `Config.plugins[name].config(plugins, opts)`,
  or if it does not exist then `require("<name>").setup(opts)`,
  lazy.nvim prioritizes the "start" plugins by `spec.priority` field.
- Default priority is `50`.
- When priority is not set, i.e. `priority` is 50,
  then lazy.nvim loads plugins by order of which they appear in spec.
- Thus, imported specs, i.e. `{ import = <directory> }` can be prioritied,
  by ordering those specs inside the lazy.nvim configuration's `spec` field.
- See: `plugins/priorities`, which adds all modules inside `plugins/ordered`
  to lazy.nvim configuration's `spec` field in specific order,
  thus ensures some plugins are loaded before others.

---------------------------------------------
Adding each plugin directory to runtimepath
---------------------------------------------
- After installing plugins, e.g. cloning the GitHub repo into `plugin.dir`,
  lazy.nvim adds each `plugin.dir` to runtimepath, so it is possible to require modules
  from within each plugin directory's `/lua` folder.
- Commonly, each plugin directory contain a `/lua/<repo>` directory,
  so it is possible to call `require('<repo>')`.
- `require('<repo>')` will search all runtimepath's top-level `/lua` folders and return first match,
  so ensure `<repo>` is a unique directory or module name across all plugin directories' `/lua` folders.

---------------------------------------------
`{ import = <directory> }`
---------------------------------------------
- As noted above, lazy.nvim adds all plugins specs to `Config.plugins` before installing and loading them,
  i.e. before cloning GitHub repo and executing either user-defined
  `Config.plugins[name].config(plugins, opts)`, or `require("<name>").setup(opts)`.
- When adding specs to `Config.plugins`, lazy.nvim adds all specs defined in `spec` field of
  configuration passed to `require("lazy").setup(<configuration>)`,\
  within which import specs, such as `{ import = <directory> }`, may occur.
- For each such import spec, lazy.nvim will immediately executes all top-level modules
  inside imported `<directory>`, i.e. those defined in `lua/<directory>`,
  to get spec table each of these modules return.
- Thus, error when imported module does not return table.
- Since these modules are executed before installing and loading modules,
  i.e. before cloning GitHub repo and executing either user-defined
  `Config.plugins[name].config(plugins, opts)`, or `require("<name>").setup(opts)`,
  then any direct code inside these modules, will be executed before plugins are installed and loaded.

- Only top-level modules inside import-directory are executed,
  e.g. only modules dirctly within `lua/plugins`.
- Imported modules are executed in alphabetical order,
  i.e. `init.lua` does not get executed first.

- Execution happens in lazy.nvim > plugin.lua: `normalize > import`.

- Thus, place code inside `lua/plugins/init.lua` (name `init.lua` is arbitrary here),
  before returning spec table, in order to execute that code prior to installing and loading plugins.

- Example: `lazyvim/lua/plugins/init.lua`.

---------------------------------------------
Calling `config(plugin, opts)`
---------------------------------------------
- Finally, lazy.nvim calls `Config.plugins[name].config(plugin, opts)` for all plugins,
  including those from { import=“<name>” }, i.e. those in `<runtimepath>/lua/<name>`,
  starting with dependencies.
- When `config(plugin, opts)` is called, it calls `require("<name>").setup(opts)`,
  which will look for `<name>` inside all `<runtimepath>/lua` directories.
- All plugin directories are previously added to runtimepath, i.e.
  `$HOME/.local/share/nvim/lazy/<repo>`,
  where `<repo>` is name of plugin directory taken from GitHub url: `<user>/<repo>`.
- Thus, `require(“<name>”) will resolve to:
  `$HOME/.local/share/nvim/lazy/<repo>/lua/<name>.lua | /<name>/init.lua`.
- For ease of reference, `<name>` is usually equal to `<repo>`.

Notes:
- `config()` function has default definition, which calls `require(<repo>).setup({ options })`.
- `require(<name>)` searches in `<runtimepath>/lua` for `<name>`,
  i.e. plugin’s <repo> name, and since all plugin directories are added to runtimepath,
  each plugin directory must contain top-level `/lua/<repo>`,
  in order for `require(<name>)` to work.

---------------------------------------------
Source plugins from original runtimepath
---------------------------------------------
- For every runtimepath prior to adding plugin directories, run `source <runtimepath>/plugin`.
- Thus, all modules inside `$HOME/.config/nvim/plugin`, at any level, are sourced.
- Finally, same for after-plugins: `source <runtimepath>/after/plugin`.

---------------------------------------------
Lazy loading
---------------------------------------------
- By default, lazy.nvim loads plugins when nvim starts.
- Lazy loading means delaying loading to some later time.

- `config.defaults.lazy = true` changes default to only
  load plugins when required, as if all plugin specs had `lazy=true`.

- These enable lazy loading (i.e. not automatically loading plugin at nvim startup):
  - Dependency                  : When plugin only listed as another plugin's `dependency`,
                                  it is automatically lazy loaded, i.e. only loaded when `require`'d.
  - `config.defaults.lazy=true` : Makes all plugins lazy-loaded by default.
  - `lazy=true`                 : Only load plugin when `require`'d, not when nvim starts.
  - `event=<SomeEvent>`         : Load plugin when event `<SomeEvent>` fires.
  - `cmd=<command>`             : Load plugin when nvim ex-command `<command>` is executed.
  - `ft=<file_type>`            : Load plugin when file with file type `<file_type>` is opened.
  - `keys=<keymap>`             : Load plugin when keymap <keymap> is first executed.

- Main colorscheme plugin should be loaded before other plugins at start,
  i.e. `lazy=false` and `prioirity=1000`, so other plugins that set highlight groups
  are not overwritten.
- Additional colorscheme plugins can be loaded when required, with `lazy=true`.

---------------------------------------------
LazyNvim starter sequence
---------------------------------------------
1. LazyVim starter's `require("lazy").setup(...)` adds plugins for:
   - "LazyVim/LazyVim".
   - `{ import="lazyvim.plugins" }`.
   - `{ import="plugins" }`.
2. Install LazyVim plugin and all plugins defined in other specs above, and their dependencies.
   - Including specs added via `{ import=“lazyvim.plugins” }`,
     i.e. specs in all moudles inside `<runtimepath>/lua/lazyvim/plugins/*`,
     which it only finds in: `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/plugins/*`,
     and specs added via `{ import=“plugins” }`,
     i.e. specs in all modules inside `<runtimepath>/lua/plugins/*`,
     which it only finds in: `$HOME/.config/nvim/lua/plugins/*`.

For each plugin:
- Run init() function.
- Defined in plugin spec.

For each start plugin:
(do below steps for plugin's dependencies, then for plugin itself)
1. Add plugin directory to runtimepath.
2. Source each `.lua` module in each plugin’s top-level `/plugin` and `/after/plugin` directories.
   - lazyvim does not contain top-level `/plugin` or `/after/plugin` directory.
   - Other plugin directories might.
3. Run `config(plugin, opts)`,
   which calls `require("<name>").setup( opts )`,
   where `require("<name>") resolves to `<runtimepath>/lua/<name>/config/init.lua`,
   meaning `<name>` should be unique across all plugin directories,
   since they are all added to runtimepath,

   - `require("lazyvim").setup( opts )`.
     - `require("lazyvim")` resolves to `<runtimepath>/lua/lazyvim/config/init.lua`,
       which it only finds in: `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/config/init.lua`.
     - Runs:
       - `require(‘lazyvim.config.autocmd’)`
       - `require(‘lazyvim.config.keymap’)`
       - `require(‘lazyvim.config.options’)`
     - These modules are found in `/lua` directory of lazyvim plugin directory,
       which was added to runtimepath by lazy.nvim,
       e.g. `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/config/options`.
     - `require("lazyvim").setup( opts )` then follows the same process for user's own config:  same for
       - `require(‘config.autocmd’)`
       - `require(‘config.keymap’)`
       - `require(‘config.options’)`
     - These modules are found in `/lua` directory of user's own config directory,
       which is always in runtimepath,
       e.g. `$HOME/.config/nvim/lua/config/options`.
     - That way, user config for ‘options’, ‘autocmds’, and ‘keymaps’,
       overwrite lazyvim’s files with same name.
     - Note: Since we do not use LazyVim, skip their options.

   - `{ import="lazyvim.plugins" }`
     - Runs `config(plugin, opts)` for every plugin spec,
       in all modules, at any level, within `$HOME/.local/share/nvim/lazy/lazynvim/lua/plugins`.
     - Which calls `require("<name>").setup( opts )` for each plugin,
       where `require("<name>")` resolves to
       `<runtimepath>/lua/<name>.lua | /<name>/init.lua`,
       where name should be unique across all plugin directories (added to runtimepath),
       so it resolves to `$HOME/.local/share/nvim/lazy/<repo>/lua/<name>.lua | /<name>/init.lua`.

   - `{ import="plugins" }`
     - Runs `config(plugin, opts)` for every plugin spec,
       in all modules, at any level, within `$HOME/.config/nvim/lua/plugins`.
     - See steps above.

---------------------------------------------
VeryLazy
---------------------------------------------
- LazyDone fires after lazy.nvim’s setup is done, i.e. all plugins installed and config(plugin, opts) functions have run, i.e. after calling require(<repo>).setup({ … })
- VeryLazy autcomd is called when LazyDone autocmd fires, earliest directly after UIEnter, i.e. when all windows and buffers have been created, and nvim startup sequence is done.
- UIEnter fires after vim UI is ready, directly after VimEnter.
- VimEnter fires after vim startup is done.
- VeryLazy autocmd is defined in Util.very_lazy(), called at beginning of lazy.vim’s setup, i.e. at end of Config.setup().

---------------------------------------------
`spec` (https://lazy.folke.io/spec)
---------------------------------------------
- Each `spec` table entry can be either:
  1. String: Plugin source as short url (see below),
  2. Table: Plugin source is first entry (no field) as short url (see below), or set as `url` | `dir` field.

- Github short url: `<user>/<repo>`, expanded with `config.git.url_format` into `https://github.com/%s.git`.

- If plugin source is not first entry (no field), in `spec` table, it can be set with either of these fields:
  1. `url`: `https://github.com/<user>/<repo>.git`, short form is not possible here.
  2. `dir`: Local directory.

- `spec` fields list (excerpt below): `https://lazy.folke.io/spec`.

- `config=<function>`:
  - Function executed when plugin loads.
  - Default implementation automatically runs `require(MAIN).setup(opts)`
    when `opts` field is set or `config` is `true`.
  - Can be overwritten, if so remember to manually call `require(MAIN).setup(opts)`.

- `opt=<table>`:
  - If specified, default `config` function runs when plugin loads,
    which calls `require(MAIN).setup(opts)` passing in `opt` table.

- `init=<function>`:
  - Executed during nvim startup.
  - Useful for setting Vim plugin configurations, e.g. `vim.g.*`.

- `import=<import>`:
  - Syntax: `{ '<user>/<repo>', `import: 'plugin' }`.
  - If `<import>` is directory:
    - Executes `require(<module>.<file>)` for every top-level `<file>.lua` in `runtimepath/lua/<module>`.
    - `$HOME/.config/nvim/lua/<module>.lua`.
    - `$HOME/.local/share/nvim/lazy/lazy.vim/lua/<module>.lua`.
  - If `<import>` is `.lua` file, aka. module:
    - Executes `require(<module>)`, which executes `runtimepath/lua/<module>.lua` | `runtimepath/lua/<module>/init.lua`.
    - `$HOME/.config/nvim/lua/<module>/init.lua`.
    - `$HOME/.local/share/nvim/lazy/lazy.vim/<module>/init.lua`.
  - `import="plugin"` is similar to placing files in `runtimepath/plugin`,
    as in both cases `.lua` files, aka. modules, inside  `plugin` folder are automatically executed,
    except `import` calls `require` on every `.lua` file in `runtimepath/lua/plugin`,
    instead of nvim default which calls `require` on on every `.lua` file in `runtimepath/plugin`.
  - Only searches for `<import>` directory, or file, in `/lua` folder inside directory of plugin specified as first argument,
    i.e. $`$HOME/.local/share/nvim/lazy/lazy.vim/lua/<import>/*.lua`
  - If first argument is omitted, searches for `<import>` directory, or file, in user's config directory,
    i.e. `$HOME/.config/nvim/lua/<import>/*.lua`.
  - Avoids having to write multiple `require` inside `spec`.

---------------------------------------------
`spec` precedence and merging
---------------------------------------------
- Plugin `spec` fields `opts`, `dependencies`, `cmd`, `event`, `ft`, `keys`
  are merged with previously executed specs for same plugin, aka. "parent specs".
- Other plugin `spec` fields override parent specs,
  i.e. spec fields are not merged.

---------------------------------------------
Plugin loading events (set in `spec`)
---------------------------------------------
- InsertEnter : Plugin loads when entering Insert mode.
- VeryLazy    : Plugin loads later, not immediately at startup.

---------------------------------------------
`spec` examples
---------------------------------------------
-- To clone plugin repo from Github, use Github short url,
-- which is expanded with `config.git.url_format` into `https://github.com/%s.git`.
-- `opt` ensures `require("neorg").setup(opt)` is automatically executed by `config` funtction, at nvim startup.
-- `ft` ensures plugin is loaded when given filetype is opened, i.e. lazily loaded.
{ "nvim-neorg/neorg", ft = "norg",  opts = {...} }

-- Dependencies are only loaded when dependent plugin loads.
-- Thus, unlike regular plugins, dependency plugins are lazy-loaded by default.
{ "hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = { "hrsh7th/cmp-nvim-lsp", ... } }

-- Local plugins need to be explicitly configured with `dir`.
{ dir = "~/projects/secret.nvim" }

-- Use custom `url` to fetch a plugin.
{ url = "git@github.com:folke/noice.nvim.git" }

-- `lazy=false` ensures plugin is automatically loaded at nvim startup.
-- `priority=1000` ensures plugin is loaded before other plugins start.
{ "folke/tokyonight.nvim", lazy = false, priority = 1000 }

-- `lazy=true` ensures plugin is only loaded when required.
-- Thus, plugin is not loaded by lazy.nvim at nvim startup.
-- For API plugins like devicons, always set `lazy=true`.
{ "nvim-tree/nvim-web-devicons", lazy = true }

-- Load plugin when ex-command is executed.
-- `init` function is called by lazy.nvim at nvim startup.
-- Configuration for vim plugins should typically be set in `init` function.
{ "dstein64/vim-startuptime", cmd = "StartupTime", init = function() vim.g.startuptime_tries = 10 end }

-- Use `VeryLazy` event to load plugins later.
-- Useful when plugin is not important for initial UI.
{ "stevearc/dressing.nvim", event = "VeryLazy" },

-- Load plugin when specific keymap is executed.
{ "monaqa/dial.nvim", keys = { "<C-a>", { "<C-x>", mode = "n" } } }

-- Local plugins can be configured with the `dev` option.
-- Will use `{config.dev.path}/noice.nvim/` instead of fetching it from GitHub.
-- With the `dev` option, easily switch between local and installed version of a plugin.
{ "folke/noice.nvim", dev = true }

---------------------------------------------
Useful commands
---------------------------------------------
- `:Lazy`       : List status of plugins.
  - `?`         : Help.
  - `:q`        : Close Lazy window.

- `:Lazy update`: Update plugins.

=============================================
--]]

require("lazy").setup({
  spec = {
    -- Runs `require` on all modules, i.e. `.lua` files,
    -- in `$HOME/.config/nvim/lua/plugins`.
    { import = "plugins" },
    -- Import other plugins, from sub-folders.
    -- Order matters.
    { import = "plugins/dap" },
    { import = "plugins/lang" },
  },
  -- Directory where plugins will be installed,
  -- i.e. GitHub repository, `<user>/<repo>`, is cloned into `<repo>` in
  -- `$HOME/.local/share/nvim/lazy`, then entire path is added to runtimepath:
  -- `$HOME/.local/share/nvim/lazy/<repo>`.
  root = vim.fn.stdpath("data") .. "/lazy",
  defaults = {
    -- Keep `lazy=false` and set inidividual options to lazy-load if appropriate.
    lazy = false,
    -- Keep `version=false`, since several plugins that support versioning have outdated releases,
    -- which may break Neovim install.
    version = false, -- always use the latest git commit.
    -- Could instead install latest stable version, for plugins that support semver.
    -- version = "*"
  },
  -- Try to load one of these colorschemes when starting a plugin installation during nvim startup.
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    size = { width = 0.8, height = 0.8 },
    wrap = true, -- wrap the lines in the ui
    -- Border to use for UI window. Accepts same border values as nvim_open_win().
    border = "none",
    -- Backdrop opacity. 0 is fully opaque, 100 is fully transparent.
    backdrop = 60,
    title = nil, ---@type string only works when border is not "none".
    title_pos = "center", ---@type "center" | "left" | "right".
    -- Show pills on top of the Lazy window.
    pills = true, ---@type boolean.
    -- If using a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table.
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      favorite = " ",
      ft = "📂",
      init = "⚙",
      import = " ",
      keys = "🗝",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
    -- Default:
    -- icons = {
    --   cmd = " ",
    --   config = "",
    --   event = " ",
    --   favorite = " ",
    --   ft = " ",
    --   init = " ",
    --   import = " ",
    --   keys = " ",
    --   lazy = "󰒲 ",
    --   loaded = "●",
    --   not_loaded = "○",
    --   plugin = " ",
    --   runtime = " ",
    --   require = "󰢱 ",
    --   source = " ",
    --   start = " ",
    --   task = "✔ ",
    --   list = {
    --     "●",
    --     "➜",
    --     "★",
    --     "‒",
    --   },
    -- },
    -- leave nil, to automatically select a browser depending on your OS.
    -- If you want to use a specific browser, you can define it here
    browser = nil, ---@type string?
    throttle = 1000 / 30, -- how frequently should the ui process render events
    custom_keys = {
      -- Define custom key maps here.
      -- If present, description will be shown in help menu.
      -- To disable one of the defaults, set it to false.
      ["<localleader>l"] = {
        function(plugin)
          require("lazy.util").float_term({ "lazygit", "log" }, {
            cwd = plugin.dir,
          })
        end,
        desc = "Open lazygit log",
      },

      ["<localleader>i"] = {
        function(plugin)
          Util.notify(vim.inspect(plugin), {
            title = "Inspect " .. plugin.name,
            lang = "lua",
          })
        end,
        desc = "Inspect Plugin",
      },

      ["<localleader>t"] = {
        function(plugin)
          require("lazy.util").float_term(nil, {
            cwd = plugin.dir,
          })
        end,
        desc = "Open terminal in plugin dir",
      },
    },
  },
  diff = {
    -- diff command <d> can be one of:
    -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
    --   so you can have a different command for diff <d>
    -- * git: will run git diff and open a buffer with filetype git
    -- * terminal_git: will open a pseudo terminal with git diff
    -- * diffview.nvim: will open Diffview to show the diff
    cmd = "git",
  },
  -- Automatically check for plugin updates.
  checker = {
    enabled = true, -- Check for plugin updates periodically.
    notify = false, -- Notify on update.
  },
  -- Automatically check for config file changes and reload the ui.
  change_detection = {
    enabled = true,
    notify = true, -- get a notification when changes are found
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

---------------------------------------------
-- Modeline: `:h modeline`.
---------------------------------------------
-- vim: ts=2 sts=2 sw=2 et
