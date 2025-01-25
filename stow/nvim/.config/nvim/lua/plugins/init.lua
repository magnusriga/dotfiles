-- This file runs during spec parsing, in `lazy.nvim` > `Loader.imports`.
-- Files in `plugins` folder run in alphabetical order.
--
-- Thus, OK for other files in `plugins` directory to run before this file,
-- as `lazy.nvim` only executes files in `plugins` directory to copy spec tables
-- into fragments, at this stage.
-- Later, plugins are installed, and `config` functions are run.
--
-- `config > init.lua > init()` executed here,
-- `config > init.lua > setup()` was previously executed from entrypoint, `init.lua`.
require("config").init()

return {
  -- ==================================================================
  -- `snacks.nvim`: Main spec.
  -- ==================================================================
  -- Not enabling any sub-plugins, but defining `config` function.
  --
  -- Other `snacks.nvim` specs, enabling sub-plugins,
  -- are defined piecemeal throughout project.
  --
  -- `priority = 1000`, thus executed before `config` functions of:
  -- - Other lower priority specs, e.g. other `snacks.nvim` specs'.
  -- - `noice.nvim`.
  --
  -- To enable sub-plugin, either:
  -- - Specify sub-plugin configuration: `terminal = { <config> }`.
  -- - Use sub-plugin default configuration: `notifier = { enabled = true }`.
  --
  -- ==================================================================
  -- Snacks sub-plugins enabled in:
  -- ==================================================================
  -- - `plugins/init.lua`:
  --   - No sub-plugins enabled.
  --   - Main `snacks.nvim` spec, defining `config` and re-replacing `vim.notify` if using `noice.nvim`.
  --
  -- - `plugins/util.lua`:
  --   - bigfile
  --   - quickfile
  --   - terminal
  --
  -- - `plugins/ui.lua`:
  --   - indent
  --   - input
  --   - notifier - Replaces `vim.notify`.
  --   - scope
  --   - scroll
  --   - statuscolumn
  --   - toggle
  --   - words
  --   - dashboard
  --
  -- ==================================================================
  -- Snacks used in:
  -- ==================================================================
  -- - `util/format.lua`:
  --   - `Snacks.toggle(..)` used in `M.snacks_toggle(buf)`, to turn auto format on save on|off for buffer.
  --   - `M.snacks_toggle(buf)` only used by `LazyNvim` in `keymaps.lua`.
  --   - Not implemented.
  --
  -- - `plugins/editor.lua`:
  --   - `Snacks.toggle(..)` used to setup keymap to toggle Gitsigns in margin on|off.
  --   - Implemented.
  --
  -- - `plugins/ui.lua`:
  --   - `Snacks.bufdelete(n)`, i.e. way to delete buffer without closing split window,
  --     is used to close buffer with keymaps or `BufferLineCloseRight|Left`, in `bufferline.nvim`.
  --     - Implemented.
  --
  --   - `Snacks.profiler.status()`, i.e. Neovim lua profiler,
  --     is used to show captured events when profiler is running, in `lualine.nvim`
  --     - NOT implemented, no need for lua profiling.
  --
  --   - `Snacks.util.color(<hlgroup>)`, i.e. utility function to get highlight group color,
  --     is used for colors, in `lualine.nvim`.
  --     - Implemented.
  --
  --   - `Snacks.notifier.show_history()` and `Snacks.notifier.hide()`, i.e. functions to show and hide notification history,
  --     is used in keybindings, in `snacks.nvim`.
  --     - Implemented.
  --
  --   - `Snacks.dashboard` is used for dashboard key commands, in `snacks.nvim`.
  --     - Implemented.
  --
  -- - `plugins/util.lua`:
  --   - `Snacks.scratch` is used in keybindings to open scratchpad, in `snacks.nvim`.
  --   - Implemented.
  --
  -- - `config/keymaps.lua`:
  --   - `Snacks.toggle.<various>` is used in keybindings to toggle options, and features of built-in and plugin functions.
  --   - Selectively implemented.
  --
  -- - `config/options.lua`:
  --   - `require('snacks.statuscolumn').get()` is used to set option `opt.statuscolumn`.
  --   - Implemented.
  --
  -- ==================================================================
  -- - Snacks sub-plugins enabled by default, without explicit enabling.
  -- ==================================================================
  --   - `Snacks.notify(..)      : Utility functions for built-in `vim.notify`.
  --   - `Snacks.toggle(..)`     : Toggle commands, i.e. turn features on|off, used with keymaps.
  --   - `Snacks.bufdelete(..)`  : Delete buffers without closing window splits.
  --   - `Snacks.profiler(..)`   : Profiler, for `.lua` files only.
  --   - `Snacks.util(..)`       : Utility functions, like `color` to get highlight group color.
  --   - `Snacks.win(..)`        : Create and manage floating windows.
  --   - `Snacks.zen(..)`        : Zen mode.
  --   - `Snacks.terminal(..)    : Create and toggle floating|split terminal windows.
  --   - `Snacks.scratch(..)     : Scratch buffers with persistent file.
  --   - `Snacks.rename(..)      : LSP-integrated file renaming, with support for `neo-tree.nvim` and `mini.files`. No need, using `yazi`, thus skip keymaps.
  --   - `Snacks.notifier(..)    : Pretty `vim.notify`, does NOT replace `vim.notify`, unlike `noice.nvim`. Must use own command, not `vim.notify`?
  --   - `Snacks.notify(..)      : Utility functions for built-in `vim.notify`.
  --   - `Snacks.lazygit(..)     : Open LazyGit in float, auto-configure colorscheme and integration with Neovim.
  --   - `Snacks.layout(..)      : Window layouts.
  --   - `Snacks.indent(..)      : Indent guides and scopes.
  --   - `Snacks.gitbrowse(..)   : Open current file, branch, commit, or repo in browser (e.g. GitHub, GitLab, Bitbucket).
  --   - `Snacks.git(..)         : `git` utilities.
  --   - `Snacks.dim(..)         : Focus on active scope by dimming rest.
  --   - `Snacks.debug(..)       : Pretty inspect and backtraces, for debugging.
  --   - `Snacks.animate(..)     : Efficient animations, including over 45 easing functions (library).
  --
  -- ==================================================================
  -- - Good sub-plugins, requiring setup:
  -- ==================================================================
  --   -
  --
  --
  -- ==================================================================
  -- - Unused sub-plugins:
  -- ==================================================================
  --   - `Snacks.profiler(..)`   : Profiler, for `.lua` files only.
  --   - `Snacks.rename(..)      : LSP-integrated file renaming, with support for `neo-tree.nvim` and `mini.files`. No need, using `yazi`, thus skip keymaps.
  --   - `Snacks.notifier(..)    : Pretty `vim.notify`, does NOT replace `vim.notify`, unlike `noice.nvim`. Must use own command, not `vim.notify`?
  --
  --
  -- ==================================================================
  -- - `Snacks.notifier`.
  -- ==================================================================
  --   - Replaces `vim.notify`:
  --       vim.notify = function(msg, level, o)
  --         vim.notify = Snacks.notifier.notify
  --         return Snacks.notifier.notify(msg, level, o)
  --       end
  --   - In: `require('snacks').setup(..)`.
  --   - Thus, disable `Snacks.notifier` if using `noice.nvim`.
  --
  --
  -- ==================================================================
  -- `lazy.nvim`: How it handles multiple specs with same source.
  -- ==================================================================
  -- - `plugin.meta.plugins[<name, e.g. short_url>] = { name = fragment.name, _ = frags = { <fragment.ids> } }`: One per plugin, i.e. one for all `snacks.nvim`.
  -- - `plugin.meta.plugins[<name>]._frags[<index>] = fragment.id`: One per spec for given plugin, i.e. all `snacks.nvim` specs, indexed by normal incrementing integer.
  -- - Config.plugins = Config.spec.plugins = plugin.meta.plugins. <-- `Loader.load()`.
  -- - Each spec is accessible via a chain of metatables:
  -- - - Config.plugin[<key>] <-- fragment.spec <-- fragment.spec <-- ...
  -- - - One metatable per `fragment.spec` from `plugin._.frags`, aka. spec spec.
  -- - When running `config` function from spec, `lazy.nvim` takes first `config` function it finds, when moving up metatable chain of specs.
  -- - Also takes first it finds of priority, and other fields inside spec, except `opts`.
  -- - Thus, only define *one* `config` function.
  -- - OK to define multiple `opts`, i.e. multiple specs with different `opts`, as those are
  --   merged right before passing in `opts` into `config` function, inside `Loader.config`,
  --   by calling `local opts = Plugin.values(plugin, "opts", false)`.
  -- - `Plugin.values(..)` recursively calls itself down to last metatable, i.e. last spec.
  -- - As recursion reverses back up metatable chain, `ret` equals `opts` from deeper spec,
  --   which is then merged with `opts` from current spec, all way to top spec, when
  --   `_values` returns tables of all spec's `opts`, for same plugin source, merged.
  -- - Important: If `opts` is function, it is passed currently merged `opts` up to
  --   this point, as well as root plugin table, i.e. `values(root, ret)`, and `opts` function
  --   can choose if it merges parent `ret` into new options and returns new options,
  --   whatever options it returns becomes new options, which in turn will be merged with
  --   `opts` higher up reecursion chain.
  --
  -- - `opts_extend`:
  --   - Used to add`opts_extends` fields to list, aka. tabled with integer index,
  --     and add parents
  --   - Thus, each field in `opts_extend` is added to list, aka. integer indexed table,
  --     to `lists[key].list`, where `lists[key].path` is key split on `.`, and key is
  --     name of field in `opts_extend`.
  --   - Thus, `opts_extend` can contain same fields in multiple specs, without them overwriting each other.
  --
  --   Thus, in summary:
  --   - If using `opts` as function, return merged `opts` with second argument,
  --     or loose arbitrary `opts` from table passed to `config` function.
  --   - Only `opts`, `cmd`, `event`, `ft`, and `keys`, are merged.
  --   - Thus, only define `config` function in ONE spec,
  --     if multiple same-source specs are defined.
  -- ==================================================================
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
    config = function(_, opts)
      -- Save built-in `vim.notify` function, for later re-instatement.
      local notify = vim.notify

      -- `opts`: Merged table of `opts` from all `snacks.nvim` specs.
      -- `require("snacks").setup(opts)`: Replaces `vim.notify` with Snacks' notifier, if enabled.
      require("snacks").setup(opts)

      -- Reminder: Delayed notifications from start of this project, until maximum 500ms,
      -- are replayed as soon as `snacks.nvim` replaces `vim.notify`,
      -- which is checked on every event loop iteration, in separate thread.
      --
      -- Thus, delayed notifications will be replayed in parallel when
      -- execution reaches this line, i.e. when done with `snacks.nvim` setup.
      --
      -- After delayed notifications are replayed with `snacks.nvim` notifier,
      -- `noice.nvim` takes over.

      -- HACK: Reset `vim.notify` to original function, in case replaced by `snacks.nvim`,
      -- so `noice.nvim` include early notifications in `noice` history.
      if MyVim.has("noice.nvim") then
        vim.notify = notify
      end
    end,
  },
}
