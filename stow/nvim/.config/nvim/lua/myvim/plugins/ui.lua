return {
  -- Statusline.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- Set empty statusline until `lualine` loads.
        vim.o.statusline = " "
      else
        -- Hide statusline on starter page.
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: Skip this lualine require madness 🤷.
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      local icons = MyVim.config.icons

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_c = {
            MyVim.lualine.root_dir(),
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { MyVim.lualine.pretty_path() },
          },
          lualine_x = {
            -- Not needed, profiler for Lua files only.
            -- Snacks.profiler.status(),
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("Statement") } end,
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color("Constant") } end,
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function() return { fg = Snacks.util.color("Special") } end,
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }

      -- Do not add trouble symbols if aerial is enabled,
      -- and allow it to be overriden for some buffer types (see autocmds).
      if vim.g.trouble_lualine and MyVim.has("trouble.nvim") then
        local trouble = require("trouble")
        local symbols = trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })
        table.insert(opts.sections.lualine_c, {
          symbols and symbols.get,
          cond = function()
            return vim.b.trouble_lualine ~= false and symbols.has()
          end,
        })
      end

      -- These `opts` are returned and thus used as basis for merging
      -- with other `lualine.nvim` spec `opts`.
      return opts
    end,
  },

  -- Icons.
  -- --------------------------------------------------
  -- General
  -- --------------------------------------------------
  -- - Get icon: `MiniIcons.get(<category>, <name>)`.
  -- - Returns three values: glyph hl is_default.
  -- - Usage: `local icon, hl, is_default = require(`mini.icons`).get("file", "foo.js")`.
  -- - Categories: `default` | `directory` | `extension` | `file` | `filetype` | `lsp` | `os`.
  -- - NOTE: Mainly use `file` category, which uses other categories as fallback:
  --         - `MiniIcons.get("file", "~/foo/bar.js")`.
  --         - Resolution:
  --           1. User-defined | `mini.icons` built-in file names.
  --              - Based on input file basename: `bar.js`.
  --              - List: `MiniIcons.list('file')`.
  --           2. Extension.
  --              - Based on input file basename: `bar.js`.
  --              - `MiniIcons.get('extension', 'foo.js')`.
  --           3. Filetype.
  --              - Based on full input file: `~/foo/bar.js`.
  --              - `MiniIcons.get('filetype', vim.filetype.match({filename='foo.js'})`.
  --           - Most icons are found in `filetype` category, since `extensions`
  --             category contains icons for files with extensions without
  --             `filetype` in nvim, except some edge cases where `filetype` to suboptimal,
  --             and `file` contains icons for file names that do NOT belong to language
  --             or software, plus some special files like `README.md`.
  --
  -- --------------------------------------------------
  -- `vim.filetype.match({arg})`
  -- --------------------------------------------------
  -- - Built-in nvim function to get filetype from:
  --   - Buffer number
  --   - File name
  --   - File contents, i.e. array of lines.
  -- - Only filename is passed in:
  --   - `vim.filetype.match({ filename = "foo.js" })`.
  --   - File name, including extension, checked against nvim internal list,
  --     to determine filetype.
  --
  -- --------------------------------------------------
  -- Categories
  -- --------------------------------------------------
  -- - `default`:
  --   - Default icon and highlight, for each category.
  --   - Example:
  --     - `MiniIcons.get("default", "file")`.
  --     - Default icon for `file` category.
  --
  -- - `directory`:
  --   - Icon and highlight for `directory` category.
  --   - Can be any path | just directory name.
  --   - Only last segment, aka. basename, is used.
  --   - Example:
  --     - `MiniIcons.get("directory", "~/foo/bar/.config")`.
  --     - Icon for `.config` directory.
  --
  -- - `extension`:
  --   - Icon and highlight for file EXTENSION.
  --   - User defined extensions: `opts.extension`.
  --   - Built-in extensions:
  --     - Those nvim does NOT have built-in `filetype` for.
  --     - Full list: `MiniIcons.list('extension')`.
  --     - Examples: `doc` | `jpg` | `zip`.
  --   - Example:
  --     - `MiniIcons.get("extension", "foo.bar")`.
  --     - Icon for file with extension `foo.bar`.
  --   - Icon resulution:
  --     1. User + built-in extensions.
  --     2. `MiniIcons.get('filetype', vim.filtype.match('random.foo.bar'))`.
  --
  -- - `file`:
  --   - Icon and highlight for file PATH.
  --   - Can be any path.
  --   - ONLY basename of file input used in first resolution step.
  --   - FULL file input used in last resolution step.
  --   - User defined extensions: `opts.file`.
  --   - Built-in file paths:
  --     - Popular file names NOT tied to language|software, with some exceptions.
  --     - Extensions recognized by `mini.icon`, but with special nvim filetype.
  --     - Full list: `MiniIcons.list('file')`.
  --     - Examples: `README` | `README.md` | `.git` | `init.lua`.
  --   - Example:
  --     - `MiniIcons.get("file", '~/foo/bar/init.lua')`.
  --     - Icon for file with name `init.lua`.
  --   - Icon resulution:
  --     1. User + built-in file names.
  --       - Uses only basename of file input.
  --     2. Basename extension: `MiniIcons.get('extension', lua)`.
  --        - Only if `opt.use_file_extension` returned `true`.
  --        - Only extensions recognized by `mini.icons`.
  --     3. `MiniIcons.get('filetype', vim.filtype.match('~/foo/bar/init.lua'))`.
  --        - Uses FULL file input, not just basename.
  --
  -- - `filetype`:
  --   - Icon and highlight for nvim `filetype` strings.
  --   - User defined extensions: `opts.filetype`.
  --   - Built-in file paths:
  --     - ANY file reasonably used in Neovim ecosystem.
  --     - Widest category.
  --     - Fallback for other categories' icon resolution.
  --     - Full list: `MiniIcons.list('filetype')`.
  --     - Examples: `javascript` | `typescript` | `json` | `man` | `lua` | `help`.
  --   - Example:
  --     - `MiniIcons.get("filetype", 'typescript')`.
  --     - Icon for file with nvim resolved `filetype`: `typescript`.
  --
  -- - `lsp`:
  --   - Icon and highlight for "LSP kind" strings.
  --   - Built-in strings:
  --     - `CompletionItemKind` string:
  --       - Returned by LSP server, on `textDocument/completion` request.
  --       - 25 possible strings.
  --       - `Propterty` | `Function` | ...
  --     - `SymbolKind` string:
  --       - Returned by LSP server, on `textDocument/documentSymbol` request.
  --       - 26 possible strings.
  --       - `Propterty` | `Function` | ...
  --     - Full list: `MiniIcons.list('lsp')`.
  --     - Examples: `array` | `class` | `color` | `variable` | `function` | `property`.
  --   - Example:
  --     - `MiniIcons.get("lsp", 'array')`.
  --     - Icon for LSP kind string: `array`.
  --
  -- - `os`:
  --   - Icon and highlight for operating systems.
  --   - Built-in strings:
  --     - Operating systems which have `nf-md-*` class icon.
  --     - Full list: `MiniIcons.list('os')`.
  --     - Examples: `arch` | `linux` | `windows` | `ios`.
  --   - Example:
  --     - `MiniIcons.get("os", 'arch')`.
  --     - Icon for os: `arch`.
  {
    "echasnovski/mini.icons",
    -- With `lazy=true`, icons won't show in `fzf.lua` on dashboard,
    -- until e.g. `which-key` has run (menu opened).
    opts = {
      -- Icon style: 'glyph' or 'ascii'.
      -- Default: 'glyph'.
      -- style = "ascii",

      -- Control which extensions will be considered,
      -- if/when "file" category icon resolution reaches extension step.
      -- Return `false` to skip using extension to resolve filetype,
      -- instead falling back to using `vim.filetype.match({filename=<name>})`.
      -- By default, all extensions are considered.
      -- Purpose:
      -- - If file extension is ignored here, then `mini.icons` will resolve icon
      --   in last resolution step, i.e. `filetype` category resolution:
      --   `MiniIcons.get('filetype', vim.filetype.match({filename=<name>}))`.
      -- - Useful if icon from `extension` category is undesired,
      --   instead preferring icon from `filetype` category.
      -- - Normally, icons from `extension` category equals icon from `filetype` category,
      --   because `vim.filetype.match({filename=<name>})` returns `filetype` identical to
      --   file extension, e.g. `lua` for `init.lua`.
      -- - However, `vim.filetype.match({filename=<name>})` takes FULL file path into
      --   consideration, meaning sometimes `filetype` from nvim,
      --   i.e. `vim.filetype.match({filename=<name>})`, differs from extension.
      -- - Example:
      --   - `vim.filetype.match({filename='queries/.foo.scm'})` === `query`.
      --   - `MiniIcons.get('file', 'queries/.foo.scm')` would have missed on first resolution
      --     step, where it looks for specific match on user-defined or built-in matches on
      --     `.foo.scm`, then moved to next resolution step,
      --     i.e. `MiniIcons.get('extension', 'scm')`, where it would have found generic
      --     `scm` icon, instead of more specific one from next resolution step,
      --     i.e. `MiniIcons.get('filetype', vim.filetype.match({filename='queries/.foo.scm'}))`.
      -- Usage:
      -- - `scm`, since `vim.filetype.match({filename='queries/.foo.scm'})` === `query`
      -- - `json`, since `filetype` may be more specific.
      -- - `yml`, since `filetype` may be more specific.
      -- - `txt`, since `filetype` may be more specific.
      -- Input:
      -- - `ext`: Extension found by splitting filename on `.`, e.g. `html`.
      -- - `file`: Input file <name>, passed into `MiniIcons.get('file', <name>)`.
      use_file_extension = function(ext, file)
        return ext:sub(-3) ~= "scm" and ext:sub(-3) ~= "yml" and ext:sub(-4) ~= "json" and ext:sub(-3) ~= "txt"
      end,

      -- ------------------------------------------------
      -- Customize icon per category.
      -- See: `:h MiniIcons.config` for details.
      -- Format: `{ glyph = '󰻲', hl = 'MiniIconsRed' }`.
      -- ------------------------------------------------
      -- `default`:
      -- - Override default icons for given category.
      -- default = { file = {...} }

      -- `extension`:
      -- - Set icon and highlight, when getting icon with `extension` category.
      -- - Also used when getting icon with `file` category.
      -- extension = {}

      -- `file`:
      -- - Set icon and highlight, when getting icon with `file` category.
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },

      -- `filetye`:
      -- - Set icon and highlight, when getting icon with `filetype` category.
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      -- Should not be needed, as not using `nvim-web-devicons` anywhere.
      -- For some reason, `use_file_extension` is not called unless below is included.
      -- package.preload["nvim-web-devicons"] = function()
      --   require("mini.icons").mock_nvim_web_devicons()
      --   return package.loaded["nvim-web-devicons"]
      -- end
    end,
  },

  -- Icons.
  -- {
  --   "echasnovski/mini.icons",
  --   lazy = true,
  --   opts = {
  --     file = {
  --       [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
  --       ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  --     },
  --     filetype = {
  --       dotenv = { glyph = "", hl = "MiniIconsYellow" },
  --     },
  --   },
  --   init = function()
  --     -- - `package.preload['<modname>']`:
  --     --   - Contains module loaders.
  --     --   - Loader runs when module is required.
  --     --   - Thus: `require('<modname>')` -> `package.preload['<modname>']('modname')`.
  --     -- - Below works as follows:
  --     --   1. `require('nvim-web-devicons')`.
  --     --   2. Lua checks for table in `package.loaded['nvim-web-devicons']`.
  --     --   3. If found: Returns that table.
  --     --   4. If not found: Runs `package.preload['nvim-web-devicons']`.
  --     --      - Meaning, if below `package.preload['nvim-web-devicons']` runs,
  --     --        then `require('nvim-web-devicons`) has not been called yet,
  --     --        since that would have set `package.loaded['nvim-web-devicons']`.
  --     --   5. `package.preload['nvim-web-devicons']`:
  --     --      - `require('nvim-web-devicons')` not called before.
  --     --      - `package.loaded['nvim-web-devicons']`: Somehow previously set to a large negative value.
  --     --      - `package.loaded['nvim-web-devicons']`: Overwritten by `mock_nvim_web_devicons()`,
  --     --        with table from `mini.icons`, identical to table returned by `require('nvim-web-devicons')`.
  --     package.preload["nvim-web-devicons"] = function(modname)
  --       -- Sets `package.loaded['nvim-web-devicons']` to function returning table
  --       -- identical to what `require('nvim-web-devicons')` would return.
  --       require("mini.icons").mock_nvim_web_devicons()
  --       -- Returned value assigned in functin above, mimicing what
  --       -- `require('nvim-web-devicons')` would return.
  --       return package.loaded["nvim-web-devicons"]
  --     end
  --   end,
  -- },

  -- Enables UI-related sub-modules from `snacks.nvim`.
  -- Main `snacks.nvim` spec, with more information: `plugins/init.lua`:
  {
    "snacks.nvim",
    opts = {
      -- Show indent guides and scopes, based on treesitter.
      indent = {
        indent = {},
        animate = {
          enabled = false,
        },
        scope = {
          -- Enable (default) or disable highlight of line indicating scope.
          -- enabled = false,

          -- Add different colors for different scopes.
          hl = {
            "SnacksIndent1",
            "SnacksIndent2",
            "SnacksIndent3",
            "SnacksIndent4",
            "SnacksIndent5",
            "SnacksIndent6",
            "SnacksIndent7",
            "SnacksIndent8",
          },
        },
      },

      -- Replaces `vim.ui.input` with prettier prompt.
      input = { enabled = true },

      -- Old alternative to `noice.nvim`, avoid.
      -- notifier = { enabled = true },

      -- Creates scopes based on indent and treesitter elements,
      -- and adds operators to navigate scopes.
      -- Adds operators to target scopes:
      -- - `ii`: Inner scope.
      -- - `ai`: Full scope.
      -- Adds key bindings to target scopes:
      -- - `[i`: Top edge of scope.
      -- - `]i`: Bottom edge of scope.
      scope = {
        -- These keymaps will only be set if the `scope` plugin is enabled.
        -- Alternatively, you can set them manually in your config,
        -- using the `Snacks.scope.textobject` and `Snacks.scope.jump` functions.
        keys = {
          ---@type table<string, snacks.scope.Jump|{desc?:string}>
          jump = {
            ["[i"] = {
              -- Allow single line scopes.
              min_size = 1,
              bottom = false,
              cursor = false,
              edge = true,
              treesitter = { blocks = { enabled = false } },
              desc = "Jump to top edge of scope",
            },
            ["]i"] = {
              -- Allow single line scopes.
              min_size = 1,
              bottom = true,
              cursor = false,
              edge = true,
              treesitter = { blocks = { enabled = false } },
              desc = "Jump to bottom edge of scope",
            },
          },
        },
      },

      -- Smoooth scrolling, e.g. when navigating up/down with `c-u|d`.
      -- scroll = { enabled = true },

      -- `statuscolumn` is enabled in `config/options.lua`.
      statuscolumn = { enabled = false },

      -- `toggle`:
      -- - Saves state of any function that can be toggled on|off, allowing easy toggling.
      -- - Manual usage: `Snacks.toggle.inlay_hints():toggle()`.
      -- - Keymap usage: `Snacks.toggle.inlay_hints():map("<leader>uh")`.
      -- - Works without config here, but set `config` to specify new `map` function.
      toggle = {
        -- `safe_keymap_set`: Creates keymap,
        -- but only if `lhs` and `modes` not already defined as keymap in `lazy.nvim`.
        map = MyVim.safe_keymap_set,
      },

      -- Highlight matching words to word under cursor, in current buffer,
      -- using LSP references.
      -- words = { enabled = true },
    },
  },

  -- Show context of current function.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return {
        mode = "cursor",
        max_lines = 3,
        -- Prefer separator over highlight, see `config/hlgroups.lua`.
        separator = "—",
      }
    end,
  },

  -- `snacks.nvim` dashboard.
  -- - `persistance.nvim` running under hood to save state, load with `s`.
  -- - Dashboard loaded automatically on startup due to below,
  --   otherwise it could be loaded `Snacks.dashboard()`.
  -- - `Snacks.dashboard.pick(..)`: Uses `fzf-lua`, since `Snacks.picker` is not enabled.
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return MyVim.pick(cmd, opts)()
          end,
          header = [[
          ███╗   ███╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          M
          ████╗ ████║╚██╗ ██╔╝██║   ██║██║████╗ ████║      M    
          ██╔████╔██║ ╚████╔╝ ██║   ██║██║██╔████╔██║   m       
          ██║╚██╔╝██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ m         
          ██║ ╚═╝ ██║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
          ╚═╝     ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
   ]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "e", desc = "New Buffer", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            -- { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },

          },
        },
      },
    },
  },
}
