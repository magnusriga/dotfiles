return {
  -- Search/replace in multiple files, using `rg` (default) and `ast-grep`,
  -- via interface launched with `GrugFar`.
  -- `<leader>sr`: Execute `GrugFar`.
  -- Inside `GrugFar`:
  -- - `<leader>j|k`: Apply next|previous repeat.
  -- - `$1`: Search string, usable in Replace section.
  -- - `<leader>i`: Show preview of line.
  -- - `<leader>t`: Show searches from history, for easy repeat.
  -- - `<leader>c`: Close, prefer over `bd` as former asks to confirm Abort if needed.
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },

  -- Adds jump labels:
  -- - `/`      : Optional, default off, toggle with `require("flash").toggle(boolean?)`.
  --              Keep disabled, regular search is good enough.
  -- - `f|F|t|T`: Optional, default off.
  --
  -- Adds shortcuts:
  -- - `s`  : Standalone jump with jump labels, like standard search with jump labels.
  --          Disable, as regular search without labels is good enough.
  -- - `S`  : Incremental Treesitter selection.
  -- - `r|R`: Motions with jump labels.
  --
  -- Upgrades `f|F|t|T`:
  -- - Go past current line, i.e. multi-line.
  -- - Repeat with same character, but `;` | `,` already repeats forward | backward.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      highlight = {
        -- Show backdrop with `hl FlashBackdrop`, e.g. making
        -- font gray from cursor forward, `true` by default.
        backdrop = false,
        -- Highlight search matches, `true` by default.
        -- Same as `Search` and `IncSearch` highlight groups,
        -- i.e. gray bacground and orang font.
        -- Bring pink box is lables, not matches.
        matches = true,
        -- Extmark priority.
        priority = 5000,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
      modes = {
        search = {
          -- `true`: `flash` activate by default for regular search.
          -- Toggle on/off: `require("flash").toggle()`.
          enabled = false,
        },
        -- `char`: Options when `flash` is activated through
        -- `f`, `F`, `t`, `T`, `;`, `,` motions.
        char = {
          -- enabled = false,
          jump_labels = true,
          highlight = {
            backdrop = false,
            groups = {
              -- Pink highlight too disturbing in this mode.
              label = "IncSearch",
            },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- Search forward|backwards, like regular search with jump labels.
      -- Disable, clashes with built-in substitute binding `s`.
      -- { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },

      -- Visually select forward|backward with labels.
      -- Expand|contract selection with `;`|`,`.
      -- Prefer increment|decrement with: `^Space`|`Backspace`, see `treesitter.lua`.
      -- { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

      -- `r` in operator pending mode (`o`) to use jump labels as operator for motion.
      -- Labels use same character for start and end of selection.
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },

      -- `R` in operator pending mode (`o`) and visual mode (`x`) to use jump labels as operator for motion.
      -- Type full search after `R`.
      -- Thus, possible to yank|delete|select upwards|downwards, not just next match.
      -- Example: `yRa` then choose jump target to yank text inside label.
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },

      -- `C-s` in command mode (`c`), to toggle flash search on/off for regular (`/`) search.
      -- Disbaled, interferes with `tmux`.
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- - Helps remember key bindings by showing popup
  --   with active keybindings of command you started typing.
  -- - Adds mappings to its menu automatically, based on all keymaps.
  -- - Icons can be provided as attribute below, as string or as table.
  -- - If `icon` attribute is table, with `name` and `cat`, `mini.icons > get()` is used.
  --
  -- - If no `icon` in `spec` below, or added via `wk.add` later, use in order:
  --   1. Icon from user config `rules > plugin`, if keymap defined in `lazy.nvim > keys`.
  --   2. Icon from user config `rules > pattern`, checking for pattern anywhere in
  --      which-key `desc`.
  --   3. Icon from built-in `rules > plugin`, if keymap defined in `lazy.nvim > keys`.
  --   4. Icon from built-in `cat = filetype, name = ft`, for `filetype` from Neovim,
  --      using `mini.icons > get()`.
  --   5. Icon from built-in `rules > pattern`, checking for pattern anywhere in
  --      which-key `desc`.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      defaults = {},
      icons = {
        -- Symbol used in command line area that shows active key combo.
        breadcrumb = "»",

        -- Symbol used between key and its label.
        separator = "➜",

        -- Symbol prepended to group.
        group = "+",

        ellipsis = "…",

        -- Set to false to disable all mapping icons,
        -- both those explicitly added in mapping and those from rules.
        mappings = true,

        --- - Set to `false` to disable keymap icons from rules.
        --- - See: `lua/which-key/icons.lua`.
        --- - `icon` can be string, or table:
        ---    `{
        ---      icon  = String icon to use.
        ---      hl    = Highlight group to use.
        ---      color = Color to use: azure | blue | cyan | green | magenta | orange | red | violet | yellow.
        ---      cat   = String category of icon: `file` | `filetype` | `extension`.
        ---      name  = Name of icon in specified category.
        ---    }`.
        --- - `icon.cat` and `icon.name` is used to get icon from `mini.icons`:
        ---   `local Icons = require("mini.icons")`.
        ---   `local ico = Icons.get(icon.cat, icon.name)`.
        ---@type wk.IconRule[]|false
        rules = {
          -- - Copy of built-in pattern rules, known used at top.
          -- - Needed to overwrite icon based on filetype, e.g. in `rest` mappings.
          { pattern = "toggle", icon = " ", color = "yellow" },
          { pattern = "window", icon = " ", color = "blue" },

          { pattern = "%f[%a]git", cat = "filetype", name = "git" },
          { pattern = "terminal", icon = " ", color = "red" },
          { pattern = "find", icon = " ", color = "green" },
          { pattern = "search", icon = " ", color = "green" },
          { pattern = "test", cat = "filetype", name = "neotest-summary" },
          { pattern = "lazy", cat = "filetype", name = "lazy" },
          { pattern = "buffer", icon = "󰈔", color = "cyan" },
          { pattern = "file", icon = "󰈔", color = "cyan" },
          { pattern = "diagnostic", icon = "󱖫 ", color = "green" },
          { pattern = "format", icon = " ", color = "cyan" },
          { pattern = "debug", icon = "󰃤 ", color = "red" },
          { pattern = "code", icon = " ", color = "orange" },
          { pattern = "notif", icon = "󰵅 ", color = "blue" },
          { pattern = "session", icon = " ", color = "azure" },
          { pattern = "exit", icon = "󰈆 ", color = "red" },
          { pattern = "quit", icon = "󰈆 ", color = "red" },
          { pattern = "tab", icon = "󰓩 ", color = "purple" },
          { pattern = "%f[%a]ai", icon = " ", color = "green" },
          { pattern = "ui", icon = "󰙵 ", color = "cyan" },

          -- Own rules, higher priority than above copy of built-in.
          { plugin = "yazi.nvim", cat = "filetype", name = "neo-tree" },

          { pattern = "inspect", icon = " ", color = "green" },
          { pattern = "download", icon = " ", color = "azure" },
          { pattern = "scratch", icon = "󰭸 ", color = "orange" },
        },

        -- Use highlights from `mini.icons`.
        -- When `false`, use `WhichKeyIcon` instead.
        colors = true,
      },
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>a", group = "avante ai" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>R", group = "Rest", icon = { cat = "filetype", name = "http" } },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },

          -- { "<leader>S", group = "Scratch", icon = { icon = " ", color = "orange" } },
          { "<leader>S", group = "Scratch", icon = { icon = "󰭸 ", color = "orange" } },

          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          -- Use built-in `^w`.
          -- {
          --   "<leader>w",
          --   group = "windows",
          --   proxy = "<c-w>",
          --   expand = function()
          --     return require("which-key.extras").expand.win()
          --   end,
          -- },
          -- Better descriptions.
          { "gx", desc = "Open with system app" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },

  -- Adds per-hunk abilities:
  -- - In-margin git status: Unstaged: Dark line | Staged: Dimmed line | Commited: No sign.
  -- - Goto, stage, unstage, reset.
  -- - Status bar integration.
  --
  -- Preview:
  -- - File diff from Index|HEAD, using Neovim's `diff` mode: `Gitsigns diffthis`.
  -- - File diff from HEAD, inline|popup: `Gitsigns preview_hunk[_inline]`.
  -- - Blame lines.
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      -- Dimmed version of above signs.
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        ---@class packagelib
        local package

        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigate to next hunk:
        -- - Normal mode: `]h`.
        -- - Diff mode: `]c`.
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        -- Navigate to previous hunk:
        -- - Normal mode: `[h`.
        -- - Diff mode: `[c`.
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        -- Navigate to last hunk.
        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")

        -- Navigate to first hunk.
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")

        -- Stage hunk and undo.
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")

        -- Stage full buffer.
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")

        -- Reset hunk from working tree to HEAD.
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")

        -- Preview hunk diff inline.
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")

        -- Show single-line blame.
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        -- Show blame for all lines in buffer.
        map("n", "<leader>ghB", function()
          gs.blame()
        end, "Blame Buffer")

        -- Show diff from from Index to working tree, in Neovim diff mode.
        map("n", "<leader>ghd", gs.diffthis, "Diff This")

        -- Show diff from from HEAD to working tree, in Neovim diff mode.
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")

        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- NOTE:
  -- When adding same plugin source multiple times, spec `opts` are merged into one.
  -- Directory name can be used as source, since `gitsigns.nvim` was installed,
  -- added to runtimepath, and loaded, above.

  {
    -- Adds keymap to toggle Gitsigns sign column, i.e. signs in margin, via `snacks.nvim`.
    -- `plugins/init.lua`: List of all `snacks.nvim` specs and usages.
    "gitsigns.nvim",
    opts = function()
      Snacks.toggle({
        name = "Git Signs",
        get = function()
          return require("gitsigns.config").config.signcolumn
        end,
        set = function(state)
          require("gitsigns").toggle_signs(state)
        end,
      }):map("<leader>uG")
    end,
  },

  -- Better diagnostics list and others.
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
        diagnostics = {
          focus = true,
          -- win = { position = "right" },
        },
      },
    },
    keys = {
      -- View diagnostics accross all open buffers.
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },

      -- View diagnostics for current buffer.
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },

      -- View symbols in current buffer, from Treesitter.
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },

      -- View references and definitions for word under cursor, using LSP.
      -- Use built-in `gr` and `gd` instead?
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },

      -- Toggle location list.
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },

      -- Toggle quickfix list.
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },

      -- Make `[q` | `q]` jump to next|previous trouble item, using whichever trouble buffer is open,
      -- i.e. diagnostics | symbols | todos | location list | quickfix list.
      -- If `trouble` buffer is not open, `[q` | `q]` will go to next|previous quickfix item.
      -- Note: Quickfix list does not contain diagnostics, only grep results,
      -- making `[q` | `]q` useless unless `trouble` buffer is open.
      -- Use built-in `[d` | `]d` instead, to navigate diagnostics.
      {
        "[q",
        function()
          if require("trouble").is_open() then
            -- The anotation here is wrong, `prev` acction is not called directly, but via internal proxy,
            -- which passes `self`, i.e. `trouble.View` as first parameter, and `opts` below as second.
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },

      -- Previous trouble | quickfix entry in buffer.
      -- See notes above.
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },

  -- Finds and lists all TODO, HACK, BUG, etc. comments
  -- in project and loads them into browsable list.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "LazyFile",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        -- TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󱡮 ", color = "performance", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "󰙏 ", color = "hint", alt = { "INFO" } },
        -- NOTE = { icon = "󰍨 ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },

      gui_style = {
        fg = "BOLD", -- The gui style to use for the fg highlight group.
        bg = "BOLD", -- The gui style to use for the bg highlight group.
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error = { "#e06c75" },
        performance = { "Keyword" },
        -- warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
        -- info = { 'Structure', 'Question', 'Special', '#2563EB' },
        info = { "#61afef", "Special", "#2563EB" },
        hint = { "#98c379", "Title", "#98c379" },
        -- default = { 'Identifier', '#7C3AED' },
        -- test = { 'Identifier', '#FF00FF' },
      },
    }, -- stylua: ignore
    keys = {
      -- `[|]t`: Built-in previous|next tag matching word under cursro, thus do not overwrite here, see: `:h vim-diff`.
      -- {
      --   "]t",
      --   function()
      --     require("todo-comments").jump_next()
      --   end,
      --   desc = "Next Todo Comment",
      -- },
      -- {
      --   "[t",
      --   function()
      --     require("todo-comments").jump_prev()
      --   end,
      --   desc = "Previous Todo Comment",
      -- },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      {
        "<leader>xT",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "Todo/Fix/Fixme (Trouble)",
      },

      -- Overwritten by `fzf.lua`.
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
}
