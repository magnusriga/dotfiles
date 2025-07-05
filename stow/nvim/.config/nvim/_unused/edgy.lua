return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>ue",
        function()
          require("edgy").toggle()
        end,
        desc = "Edgy Toggle",
      },
      -- stylua: ignore
      { "<leader>uE", function() require("edgy").select() end, desc = "Edgy Select Window" },
    },
    opts = function()
      -- Window matching `ft` and|or `filter`, is placed as defined below.
      -- Set default window position, by adding table to `bottom` | `left` | `right` | `top`.
      -- Set default window size, by changing `size = { width = ... }` | `size = { height = .. }`.
      local opts = {
        bottom = {
          -- Not using `toggleterm.nvim`.
          -- {
          --   ft = "toggleterm",
          --   size = { height = 0.4 },
          --   filter = function(buf, win)
          --     return vim.api.nvim_win_get_config(win).relative == ""
          --   end,
          -- },

          -- `noice.nvim` message list: Bottom.
          {
            ft = "noice",
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },

          -- `trouble.nvim` window: Bottom.
          -- Includes quickfix, diagnostics, etc.
          "Trouble",

          -- QuickFix window: Bottom.
          { ft = "qf", title = "QuickFix" },

          -- Help window: Bottom.
          {
            ft = "help",
            size = { height = 30 },
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },

          -- Not sure what this is.
          { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },

          -- `neotest` output window: Bottom.
          { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
        },

        left = {
          -- `neotest` summary window: Left.
          { title = "Neotest Summary", ft = "neotest-summary" },
        },

        right = {
          -- `grug-far.nvim` window: Left.
          { title = "Grug Far", ft = "grug-far", size = { width = 0.4 } },
        },

        -- ---@type table<Edgy.Pos, {size:integer | fun():integer, wo?:vim.wo}>
        -- options = {
        --   --Default positions.
        --   left = { size = 30 },
        --   bottom = { size = 10 },
        --   right = { size = 30 },
        --   top = { size = 10 },
        -- },

        -- Edgebar animations, turned off.
        animate = {
          enabled = false,
          -- fps = 100, -- frames per second
          -- cps = 120, -- cells per second
          -- on_begin = function()
          --   vim.g.minianimate_disable = true
          -- end,
          -- on_end = function()
          --   vim.g.minianimate_disable = false
          -- end,
          -- -- Spinner for pinned views that are loading.
          -- -- if you have noice.nvim installed, you can use any spinner from it, like:
          -- -- spinner = require("noice.util.spinners").spinners.circleFull,
          -- spinner = {
          --   frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          --   interval = 80,
          -- },
        },

        -- Enable to exit Neovim when only Edgy windows are left.
        -- Default: `false`.
        exit_when_last = true,

        -- Close Edgy when all windows are hidden, instead of opening one of them.
        -- Disable to always keep at least one edgy split visible in each open section.
        -- Default: `true`.
        -- close_when_all_hidden = true,

        -- Global window options for edgebar windows.
        -- Default:
        -- wo = {
        --   -- Setting to `true`, will add an edgy winbar.
        --   -- Setting to `false`, won't set any winbar.
        --   -- Setting to a string, will set the winbar to that string.
        --   winbar = true,
        --   winfixwidth = true,
        --   winfixheight = false,
        --   winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
        --   spell = false,
        --   signcolumn = "no",
        -- },

        keys = {
          -- Increase width.
          ["<c-Right>"] = function(win)
            win:resize("width", 2)
          end,
          -- Decrease width.
          ["<c-Left>"] = function(win)
            win:resize("width", -2)
          end,
          -- Increase height.
          ["<c-Up>"] = function(win)
            win:resize("height", 2)
          end,
          -- Decrease height.
          ["<c-Down>"] = function(win)
            win:resize("height", -2)
          end,
        },
      }

      -- Not using `nvim-neo-tree/neo-tree.nvim`.
      -- if MyVim.has("neo-tree.nvim") then
      --   local pos = {
      --     filesystem = "left",
      --     buffers = "top",
      --     git_status = "right",
      --     document_symbols = "bottom",
      --     diagnostics = "bottom",
      --   }
      --   local sources = MyVim.opts("neo-tree.nvim").sources or {}
      --   for i, v in ipairs(sources) do
      --     table.insert(opts.left, i, {
      --       title = "Neo-Tree " .. v:gsub("_", " "):gsub("^%l", string.upper),
      --       ft = "neo-tree",
      --       filter = function(buf)
      --         return vim.b[buf].neo_tree_source == v
      --       end,
      --       pinned = true,
      --       open = function()
      --         vim.cmd(("Neotree show position=%s %s dir=%s"):format(pos[v] or "bottom", v, MyVim.root()))
      --       end,
      --     })
      --   end
      -- end

      -- ==================================
      -- NOTE
      -- ==================================
      -- - Add edgy config for `trouble` and `snacks_terminal` filetypes to all
      --   positions, and filter so it applies only to position it is defined for
      --   via `vim.w[win].trouble` and `vim.w[win].snacks_win`.

      -- Trouble.
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "trouble",
          filter = function(_buf, win)
            -- vim.print(vim.w[win].snacks_win)
            return vim.w[win].trouble
              and vim.w[win].trouble.position == pos
              and vim.w[win].trouble.type == "split"
              and vim.w[win].trouble.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end

      -- Snacks terminal.
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          -- size = { height = 0.4 },
          size = { width = 0.4 },
          title = "%{b:snacks_terminal.id}: %{b:term_title}",
          filter = function(_buf, win)
            -- vim.print(vim.w[win].snacks_win)
            -- vim.print(win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end

      return opts
    end,
  },

  -- Use edgy's selection window.
  -- not using `nvim-telescope/telescope.nvim`.
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   optional = true,
  --   opts = {
  --     defaults = {
  --       get_selection_window = function()
  --         require("edgy").goto_main()
  --         return 0
  --       end,
  --     },
  --   },
  -- },

  -- Prevent neo-tree from opening files in edgy windows.
  -- Not using `neo-tree.nvim`.
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types
  --       or { "terminal", "Trouble", "qf", "Outline", "trouble" }
  --     table.insert(opts.open_files_do_not_replace_types, "edgy")
  --   end,
  -- },

  -- Fix bufferline offsets when edgy is loaded.
  -- Not using `akinsho/bufferline.nvim`.
  -- {
  --   "akinsho/bufferline.nvim",
  --   optional = true,
  --   opts = function()
  --     local Offset = require("bufferline.offset")
  --     if not Offset.edgy then
  --       local get = Offset.get
  --       Offset.get = function()
  --         if package.loaded.edgy then
  --           local old_offset = get()
  --           local layout = require("edgy.config").layout
  --           local ret = { left = "", left_size = 0, right = "", right_size = 0 }
  --           for _, pos in ipairs({ "left", "right" }) do
  --             local sb = layout[pos]
  --             local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)
  --             if sb and #sb.wins > 0 then
  --               ret[pos] = old_offset[pos .. "_size"] > 0 and old_offset[pos]
  --                 or pos == "left" and ("%#Bold#" .. title .. "%*" .. "%#BufferLineOffsetSeparator#│%*")
  --                 or pos == "right" and ("%#BufferLineOffsetSeparator#│%*" .. "%#Bold#" .. title .. "%*")
  --               ret[pos .. "_size"] = old_offset[pos .. "_size"] > 0 and old_offset[pos .. "_size"] or sb.bounds.width
  --             end
  --           end
  --           ret.total_size = ret.left_size + ret.right_size
  --           if ret.total_size > 0 then
  --             return ret
  --           end
  --         end
  --         return get()
  --       end
  --       Offset.edgy = true
  --     end
  --   end,
  -- },
}
