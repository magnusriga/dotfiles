-- ==================================================================
-- Execution order.
-- ==================================================================
-- This file runs during spec parsing, in `lazy.nvim` > `Loader.imports`.
-- Files in `plugins` folder run in alphabetical order.
--
-- Thus, OK for other files in `plugins` directory to run before this file,
-- as `lazy.nvim` only executes files in `plugins` directory to copy spec tables
-- into fragments, at this stage.
-- Later, plugins are installed, and `config` functions are run.
--
-- `config > init.lua > setup()` previously executed from entrypoint, `init.lua`.
-- `config > init.lua > init()` executed here.
require("config").init()

return {
  -- ==================================================================
  -- `snacks.nvim`: Main spec.
  -- ==================================================================
  -- This file is not enabling any sub-plugins, only defining `config` function.
  --
  -- Other `snacks.nvim` specs are enabling sub-plugins,
  -- defined piecemeal throughout project.
  --
  -- `priority = 1000`, thus executed before `config` functions of:
  -- - Other lower priority specs, e.g. other `snacks.nvim` specs'.
  -- - `noice.nvim`.
  --
  -- - Snacks sub-plugins load, i.e. `setup()` is called, wh
  --
  -- ==================================================================
  -- `opts`.
  -- ==================================================================
  -- - When `snacks.nvim` > `setup(opts)` runs, i.e. first plugin loaded by `lazy.nvim`,
  --   `Snacks.config` table is filled with user-provided `opts`,
  --   thus e.g. `Snacks.opts[indent]` holds sub-plugin configuration.
  -- - When sub-plugin loads, which happens either when `snacks.nvim` loads | on event |  manually,
  --   `Snacks.config[indent]` is merged with defaults from within sub-plugin.
  --
  -- ==================================================================
  -- Enabling sub-plugins.
  -- ==================================================================
  -- - Generally NOT necessary to enable sub-plugins.
  -- - Most `Snacks.<commands>` are available out of box, without setup.
  --
  --
  -- ------------------------------------------------------------------
  -- - `Snacks.<commands>` not requiring enabling.
  -- ------------------------------------------------------------------
  --   - scratch   : No setup function, opened automatically when called, regardless of `opts.scratch`,
  --                 using default options merged with `opts.scratch`, if any.
  --
  --   - bufdelete : No setup function, deletes buffer when `bufdelete(opts)` is called, where `opts` sets buffer to delete.
  --                 No `opts.bufdelete`, `opts` is passed directly into function, where no `opts` means current buffer.
  --
  --   - debug     : No setup function, enabled manually by calling `Snacks.debug(..)`, which calls `Snacks.debug.inspect(..)`.
  --
  --   - dim       : No setup function called, enabled manually by calling `Snacks.dim()`, which calls `Snacks.dim.enable(..)`.
  --
  --   - git       : No setup function, enabled manually by calling `Snacks.git.blame_line() | get_root()`.
  --
  --   - gitbrowse : No setup function, enabled manually by calling `Snacks.gitbrowse()`, which calls `Snacks.gitbrowse.open(..)`.
  --
  --   - health    : No setup function, enabled manually by calling `Snacks.health.check()`. If any other key is used, it calls `vim.health.<key>`.
  --
  --   - layout    : No setup function, just various helper functions to create windows.
  --
  --   - lazygit   : No setup function, opened manually by calling `Snacks.lazygit()`, regardless of `opts.lazygit`,
  --                 using default options merged with `opts.lazygit`, if any.
  --
  -- ------------------------------------------------------------------
  -- - `Snacks.<commands>` requiring manual enabling in config.
  -- ------------------------------------------------------------------
  --   - Load manually by calling Snacks.<sub-plugin>`:
  --
  --   - Load immediately when `snacks.nvim` loads, which is first plugin that loads after Neovim starts:
  --     - notifier.
  --     - statuscolumn    : `setup(..)` function called if `opts.statuscolumn.enabled = true`, or other `opts.statuscolumn` is passed,
  --                         which starts refreshing statuscolumn every 50ms, but possible to manually open by calling `Snacks.statuscolumn()`,
  --                         which also calls `setup()`. Note: `statusline` built-in option must be set for `statuscolumn` to work.
  --
  --   - Load on event `BufReadPre`, `BufReadPost`, `LspAttach`, `UIEnter`:
  --     - bigfile.      <-- `BufReadPre` : Before reading file into buffer.
  --     - quickfile.    <-- `BufReadPost`: After reading file into buffer.
  --     - indent.       <-- `BufReadPost`.
  --     - words.        <-- `LspAttach`  : When `opts.words.enabled = true`, or any other `opts.words` is passed,
  --                                        `Snacks.words.enable()` is called, which enables `words`.
  --     - dashboard.    <-- `UIEnter`    : When `opts.dashboard.enabled = true`, or any other `opts.dashboard` is passed,
  --                                        `setup()` is called when opening Neovim to determin if dashboard should be opened.
  --                                        Alternatively, dashboard can be opened manually by calling `Snacks.dashboard.open()`, closed with Escape.
  --     - scroll.       <-- `UIEnter`.
  --     - input.        <-- `UIEnter`.
  --     - scope.        <-- `UIEnter`.
  --     - picker.       <-- `UIEnter`.
  --
  -- - `Snacks.<commands>` requiring other manual enabling:
  --     - words: Does not need enabling in config, but without calling `Snacks.words.enable`, `words` will not work.
  --
  -- Enable sub-plugin, either:
  -- - Specify sub-plugin configuration: `terminal = { <config> }`.
  -- - Use sub-plugin default configuration: `notifier = { enabled = true }`.
  --
  -- ==================================================================
  -- Scratch.
  -- ==================================================================
  -- - Unique key for scratch file is based on:
  --   * name: File name.
  --   * ft: File type.
  --   * vim.v.count1: Count given in keymap, default to 1.
  --   * cwd: Current working directory.
  --   * branch: Current branch name.
  -- - Thus, new scratch file created when scratch is opened from another file.
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
  -- Snacks sub-plugins enabled by default, without explicit enabling.
  -- ==================================================================
  --   - `Snacks.notify(..)      : Utility functions for built-in `vim.notify`.
  --   - `Snacks.toggle(..)`     : Toggle commands, i.e. turn features on|off, used with keymaps.
  --   - `Snacks.bufdelete(..)`  : Delete buffers without closing window splits.
  --   - `Snacks.profiler(..)`   : Profiler, for `.lua` files only.
  --   - `Snacks.win(..)`        : Create and manage floating windows.
  --   - `Snacks.zen(..)`        : Zen mode.
  --   - `Snacks.terminal(..)    : Create and toggle floating|split terminal windows.
  --
  --   - `Snacks.scratch(..)     : Scratch buffers with persistent file.
  --
  --   - `Snacks.util(..)`       : Utility functions, like `color` to get highlight group color.
  --   - `Snacks.notify(..)      : Utility functions for built-in `vim.notify`.
  --   - `Snacks.picker(..)      : Only used for `git log` commands by default, e.g. `Snacks.picker.git_log_files()`.
  --   - `Snacks.words(..)       : Disabled by default, but if enabled then highlights, and allows jumping to,
  --                               symbols matching word under cursor, in same file only, more info below.
  --                               No need to enable this in `snacks.nvim` spec,
  --                               but must execute `Snacks.words` to enable.
  --
  --   - `Snacks.rename(..)      : LSP-integrated file renaming, with support for `neo-tree.nvim` and `mini.files`.
  --                               No need, using `yazi`, thus skip keymaps.
  --
  --   - `Snacks.lazygit(..)     : Open LazyGit in float, auto-configure colorscheme and integration with Neovim.
  --                               No need to enable, `Snacks.lazygit()` works regardless.
  --
  --   - `Snacks.layout(..)      : Window layouts.
  --   - `Snacks.indent(..)      : Indent guides and scopes.
  --   - `Snacks.gitbrowse(..)   : Open current file, branch, commit, or repo in browser (e.g. GitHub, GitLab, Bitbucket).
  --
  --   - `Snacks.git(..)         : Show git blame line and root of buffer | path, defualting to current buffer.
  --
  --   - `Snacks.dim(..)         : Focus on active scope by dimming rest.
  --
  --   - `Snacks.debug(..)`      : Helper functions for `lua` files, pretty printing objects and backtraces.
  --                               Always active, not used.
  --
  --   - `Snacks.animate(..)     : Efficient animations, including over 45 easing functions (library).
  --
  --   - input                   : Replaces `vim.fn.input` with prettier prompt.
  --
  --   - scope                   : Creates scopes based on indent and treesitter elements.
  --                               Adds operators to target scopes:
  --                               - `ii`: Inner scope.
  --                               - `ai`: Full scope.
  --                               Adds key bindings to target scopes:
  --                               - `[i`: Top edge of scope.
  --                               - `]i`: Bottom edge of scope.
  --
  --   - scroll                   : Smooth scrolling for Neovim, properly handles scrolloff and mouse scrolling.
  --
  --   statuscolumn = { enabled = false }, -- we set this in options.lua

  -- `toggle`:
  -- - Saves state of any function that can be toggled on|off, allowing easy toggling.
  -- - Manual usage: `Snacks.toggle.inlay_hints():toggle()`.
  -- - Keymap usage: `Snacks.toggle.inlay_hints():map("<leader>uh")`.
  -- - Works without config here, but set `config` to specify new `map` function.
  --
  -- ==================================================================
  -- Snacks sub-plugins requiring explicit enabling.
  -- ==================================================================
  --   - `Snacks.notifier(..)    : Pretty `vim.notify`, does NOT replace `vim.notify`, unlike `noice.nvim`. Must use own command, not `vim.notify`?
  --
  -- ==================================================================
  -- Good sub-plugins, requiring setup:
  -- ==================================================================
  --   -
  --
  --
  -- ==================================================================
  -- Unused sub-plugins:
  -- ==================================================================
  --   - `Snacks.profiler(..)`   : Profiler, for `.lua` files only.
  --   - `Snacks.rename(..)      : LSP-integrated file renaming, with support for `neo-tree.nvim` and `mini.files`. No need, using `yazi`, thus skip keymaps.
  --   - `Snacks.notifier(..)    : Pretty `vim.notify`, does NOT replace `vim.notify`, unlike `noice.nvim`. Must use own command, not `vim.notify`?
  --
  -- ==================================================================
  -- `Snacks.toggle.<..>`.
  -- ==================================================================
  -- - Modules, e.g. `Snacks.toggle.diagnostics()`, does not itself toggle.
  -- - Must call method `toggle`: `Snacks.toggle.diagnostics():toggle()`.
  -- - Which is what `Toggle:map` does: `Snacks.toggle.diagnostics():map(<lhs>, <opts>)`.
  -- - `Toggle:map` also adds to key binding to `which-key.nvim`.
  --
  -- ==================================================================
  -- `Snacks.notifier`.
  -- ==================================================================
  --   - Replaces `vim.notify`:
  --       vim.notify = function(msg, level, o)
  --         vim.notify = Snacks.notifier.notify
  --         return Snacks.notifier.notify(msg, level, o)
  --       end
  --   - In: `require('snacks').setup(..)`.
  --   - Thus, disable `Snacks.notifier` if using `noice.nvim`.
  --
  -- ==================================================================
  -- `Snacks.picker`.
  -- ==================================================================
  -- - Picker, e.g. `fzf.lua` | `telescope.lua` `snacks_picker.lua`,
  --   is registered when running spec file during import, i.e. before installing and loading plugins.
  -- - Spec files in `LazyNvim`: `plugins/extras/editor/fzf.lua | snacks_picker.lua | telescope.lua`.
  -- - Only one picker can be registered.
  -- - In MyVim, `plugins/fzf.lua` registers `fzf-lua` as only picker.
  -- - Picker, i.e. `fzf-lua`, is used in keybindings inside:
  --   - LazyVim: `plugins/extras/editor/fzf.lua | snacks_picker.lua | telescope.lua`
  --   - MyVim  : `plugins/fzf.lua`
  -- - Example: `{ "<leader>ff", MyVim.pick("files"), desc = "Find Files (Root Dir)" }`.
  -- - Calling `MyVim.pick("files")`, runs `MyVim/pick` > `open("files")`,
  --   which uses sole registered picker to open e.g. file list.
  -- - Thus, key bindings using `MyVim.pick` uses sole registered picker, regardless which it is.
  -- - `snacks_picker.lua` is not registered picker, in MyVim | LazyVim.
  -- - `Snacks.picker` still used by MyVim and LazyVim, but only for key bindings in `config/keymaps`, running `git log` commands:
  --   - `map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })`.
  --   - `map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, { desc = "Git Log" })`.
  --   - `map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })`.
  --
  -- ==========================
  -- `Snacks.words`.
  -- ==========================
  -- - `vim.lsp.buf.document_highlight()`: Adds extmarks AND highlights for all symbols matching word under cursor, in current file only.
  -- - Symbols are defined by language, so e.g. cursor on `then` will highlight `if` and `end`.
  -- - `vim.lsp.buf.clear_references()`: Removes BOTH extmarks AND highlights for all symbols matching word under cursor, in current file.
  -- - `Snacks.words.enable()`: Schedules `vim.lsp.buf.document_highlight()` to run on `CursorMoved` | `CursorMovedI` | `ModeChanged`,
  --   debounced to not run more often than every 200 ms, immediately followed by `vim.lsp.buf.clear_references()`.
  -- - Result: `Snacks.words` highlight references within same file automatically when cursor moves, via `vim.lsp.buf.document_highlight()`,
  --   and allows jumping to those references using key bindings mapping to `Snacks.words.jump(<count>, [<cycle>])`.
  -- - `config.notify_jump` is `false` by default, set to `true` to run `vim.notify` at jump.
  --
  -- - `Snacks.words` is disabled by default, enable with: `Snacks.words.enable()`.
  -- - All usage of `Snacks.words`:
  --   - { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
  --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
  --   - { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
  --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
  --   - { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
  --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
  --   - { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
  --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
  -- - If `Snacks.words` not enabled, keybindings above follow built-in behavior.
  -- - Thus, OK to leave keybindings as is.
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
  --
  --   Spec-adding order:
  --   - Specs are added in order they appear in top-level spec list.
  --   - Imported specs are added in alphabetical order of filenames they appear in, within e.g. `plugins` directory.
  --   - Thus, `opts` for given plugin are merged, and `opts` functions run, in order they
  --     appear in spec, and if imported then by alphabetical order of file|directory name they appear in.
  --
  -- - If `opts` is function:
  --   - Function is called AFTER plugins are installed, but right BEFORE current plugin is loaded, i.e. before calling `config` function.
  --   - Plugins with higher priority get their `opts` and `config` functions, which run right after each other,
  --     run before those with lower priority.
  --   - However, within one plugin, `opts`-functions from specs for that specific plugin run in order they appear from top-level spec,
  --     with each imported spec added in alphabetical order of file|directory name they appear in.
  --   - Example: `nvim-lspconfig` `opts`-function, since it returns table, overwrites `opts` specified by other `lspconfig` specs,
  --     if `nvim-lspconfig` spec with `opts`-function appear AFTER other `nvim-lspconfig` specs,
  --     either by being below another `nvim-lspconfig` spec within one file,
  --     or by being after another imported spec file in alphabetically sorted list of file|directory names from import directory.
  --   - Function is passed `plugin` as first parameter, and `opts` merged up to this point, as second paramter.
  --   - If function returns value, then this value will be new `opts` table, so remember merging with second passed-in argument.
  --   - If function does NOT return value, currently merged `opts` up to this point is
  --     used as basis for further `opts`-merging.
  --   - Thus, when `opts`-function does NOT return value, only effect is that function is called.
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
