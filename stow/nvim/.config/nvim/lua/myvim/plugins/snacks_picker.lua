local explorer = require("snacks.explorer")
-- To use snacks.picker: `options.lua` > `vim.g.MyVim_picker = "snacks"`.

-- No need to register picker, using `fzf.lua`.
-- ---@type MyPicker
-- local picker = {
--   name = "snacks",
--   commands = {
--     files = "files",
--     live_grep = "grep",
--     oldfiles = "recent",
--   },
--
--   ---@param source string
--   ---@param opts? snacks.picker.Config
--   open = function(source, opts)
--     return Snacks.picker.pick(source, opts)
--   end,
-- }
-- if not MyVim.pick.register(picker) then
--   return {}
-- end

return {
  desc = "Fast and modern file picker",
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<a-c>"] = {
                "toggle_cwd",
                mode = { "n", "i" },
              },
            },
          },
        },
        actions = {
          ---@param p snacks.Picker
          toggle_cwd = function(p)
            local root = MyVim.root({ buf = p.input.filter.current_buf, normalize = true })
            local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
            local current = p:cwd()
            p:set_cwd(current == root and cwd or root)
            p:find()
          end,
        },
      },
    },
    -- stylua: ignore
    keys = {
      ----------------------------------------------------------------
      -- General.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      -- { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      -- { "<leader>/", MyVim.pick("grep"), desc = "Grep (Root Dir)" },
      -- { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      -- { "<leader><space>", MyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },

      ----------------------------------------------------------------
      -- Find.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      -- { "<leader>fc", MyVim.pick.config_files(), desc = "Find Config File" },
      -- { "<leader>ff", MyVim.pick("files"), desc = "Find Files (Root Dir)" },
      -- { "<leader>fF", MyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
      -- { "<leader>fr", MyVim.pick("oldfiles"), desc = "Recent" },
      -- { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },

      ----------------------------------------------------------------
      -- Git.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
      -- { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },

      ----------------------------------------------------------------
      -- Grep.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      -- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      -- { "<leader>sg", MyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      -- { "<leader>sG", MyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      -- { "<leader>sw", MyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
      -- { "<leader>sW", MyVim.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },

      ----------------------------------------------------------------
      -- Search.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      -- { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      -- { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      -- { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      -- { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      -- { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      -- { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      -- { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      -- { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      -- { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      -- { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      -- { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      -- { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      -- { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },

      ----------------------------------------------------------------
      -- UI.
      -- Commented keybindings already defined in `fzf.lua`.
      ----------------------------------------------------------------
      -- { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    },
  },

  -- Open `trouble.nvim` windows with `snacks.picker`.
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      if MyVim.has("trouble.nvim") then
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = {
              trouble_open = function(...)
                return require("trouble.sources.snacks").actions.trouble_open.action(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-t>"] = {
                    "trouble_open",
                    mode = { "n", "i" },
                  },
                },
              },
            },
            -- layout = {
            -- Each layout level can have properties:
            -- - `box` (string): Type of box to use, 'horizontal' | 'vertical' | 'flex' | 'grid'.
            -- - `id` (string): id of the box, used to identify the box in the layout.
            -- - `depth` (number): Depth of box window, used to identify box window in layout.
            -- - `win` (string): Window box window name, used to identify box window in layout.
            -- - All properties from `snacks.win.Config`, e.g. `border`, `title`, `width`, `height`, etc.
            -- - `height` | `width`: Height | width of window:
            --   - <1     : Relative height.
            --   - 0      : Full height.
            --   - 1      : 1 line.
            --   - Default: `0.9`.
            --  ---@type snacks.layout.Box
            --   layout = {
            --     box = "horizontal",
            --     width = 0.8,
            --     min_width = 120,
            --     height = 0.8,
            --     {
            --       box = "vertical",
            --       border = "rounded",
            --       title = "{title} {live} {flags}",
            --       -- on_win = function(win)
            --         -- win:add_padding()
            --         -- win:update()
            --         -- win:toggle_help()
            --       -- end,
            --       {
            --         win = "input",
            --         height = 1,
            --         border = "bottom",
            --         col = 0.1,
            --         width = 0.8,
            --       },
            --       {
            --         win = "list",
            --         border = "none",
            --         col = 0.1,
            --         width = 0.8,
            --       },
            --     },
            --     -- Preview window is half of full width, when shown.
            --     { win = "preview", title = "{preview}", border = "rounded", width = 0.5 },
            --   },
            -- },
            -- sources = {
            --   files = {
            --   },
            -- },
          },
        })
      end
    end,
  },

  -- LSP keymaps.
  -- Set in: `fzf.lua`.
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function()
  --     local Keys = require("myvim.plugins.lsp.keymaps").get()
  --     -- stylua: ignore
  --     vim.list_extend(Keys, {
  --       { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
  --       { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  --       { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  --       { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
  --       { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = MyVim.config.kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
  --       { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = MyVim.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
  --     })
  --   end,
  -- },

  -- Todo-commets list via `snacks.picker`.
  -- Set in: `editor.lua`.
  -- {
  --   "folke/todo-comments.nvim",
  --   optional = true,
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
  --     { "<leader>sT", function () Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
  --   },
  -- },

  -- Add projects to dashboard, via `snacks.picker.projects()`.
  -- Set in: `ui.lua`.
  -- {
  --   "folke/snacks.nvim",
  --   opts = function(_, opts)
  --     table.insert(opts.dashboard.preset.keys, 3, {
  --       icon = " ",
  --       key = "p",
  --       desc = "Projects",
  --       action = ":lua Snacks.picker.projects()",
  --     })
  --   end,
  -- },

  -- Not using flash.
  -- {
  --   "folke/flash.nvim",
  --   specs = {
  --     {
  --       "folke/snacks.nvim",
  --       opts = {
  --         picker = {
  --           win = {
  --             input = {
  --               keys = {
  --                 ["<a-s>"] = { "flash", mode = { "n", "i" } },
  --                 ["s"] = { "flash" },
  --               },
  --             },
  --           },
  --           actions = {
  --             flash = function(picker)
  --               require("flash").jump({
  --                 pattern = "^",
  --                 label = { after = { 0, 0 } },
  --                 search = {
  --                   mode = "search",
  --                   exclude = {
  --                     function(win)
  --                       return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
  --                     end,
  --                   },
  --                 },
  --                 action = function(match)
  --                   local idx = picker.list:row2idx(match.pos[1])
  --                   picker.list:_move(idx, true, true)
  --                 end,
  --               })
  --             end,
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
}
