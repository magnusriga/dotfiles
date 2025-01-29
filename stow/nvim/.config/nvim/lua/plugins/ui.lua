return {

  -- Statusline.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: Do not need this lualine require madness 🤷.
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
            Snacks.profiler.status(),
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

      return opts
    end,
  },

  -- Icons.
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Enables UI-related sub-modules from `snacks.nvim`.
  --
  -- To enable sub-plugin, either:
  -- - Specify sub-plugin configuration: `terminal = { <config> }`.
  -- - Use sub-plugin default configuration: `notifier = { enabled = true }`.
  --
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

      -- Replaces `vim.fn.input` with prettier prompt.
      input = { enabled = true },

      -- Creates scopes based on indent and treesitter elements.
      -- Adds operators to target scopes:
      -- - `ii`: Inner scope.
      -- - `ai`: Full scope.
      -- Adds key bindings to target scopes:
      -- - `[i`: Top edge of scope.
      -- - `]i`: Bottom edge of scope.
      scope = { enabled = true },

      -- Smooth scrolling for Neovim, handles scrolloff and mouse scrolling.
      -- Unecessary overhead.
      -- scroll = { enabled = true },

      -- `statuscolumn` is set in `config/options.lua`.
      -- statuscolumn = { enabled = false },

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

      -- Replaces `vim.notify`.
      -- No need for `Snacks.notifier`, use built-in `vim.notify` instead,
      -- or `noice.nvim` for custom notifications.
      -- notifier = { enabled = true },

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
      --
      -- - Disabled by default, but enabled by passing config | `{ enabled = true }`.
      -- - Keep disabled, enable manually if needed: `Snacks.words.enable()`.
      -- words = { enabled = true },
    },

    -- No need for `Snacks.notifier`, use built-in `vim.notify` instead,
    -- or `noice.nvim` for custom notifications.
    -- stylua: ignore
    -- keys = {
    --   { "<leader>n", function()
    --     if Snacks.config.picker and Snacks.config.picker.enabled then
    --       Snacks.picker.notifications()
    --     else
    --       Snacks.notifier.show_history()
    --     end
    --   end, desc = "Notification History" },
    --   { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- },-
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
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
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
