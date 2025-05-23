return {
  -- Disable `<leader>cs` in `trouble.nvim`, to avoid conflict with `outline.nvim`.
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>cs", false },
    },
  },

  {
    "hedyhli/outline.nvim",
    keys = {
      { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" },
      { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" },
    },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = {
          icons = {},
          filter = vim.deepcopy(MyVim.config.kind_filter),
        },
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        opts.symbols.icons[kind] = {
          icon = MyVim.config.icons.kinds[kind] or symbol.icon,
          hl = symbol.hl,
        }
      end
      return opts
    end,
  },

  -- Edgy integration.
  -- {
  --   "folke/edgy.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     local edgy_idx = MyVim.plugin.extra_idx("ui.edgy")
  --     local symbols_idx = MyVim.plugin.extra_idx("editor.outline")
  --
  --     if edgy_idx and edgy_idx > symbols_idx then
  --       MyVim.warn(
  --         "The `edgy.nvim` extra must be **imported** before the `outline.nvim` extra to work properly.",
  --         { title = "LazyVim" }
  --       )
  --     end
  --
  --     opts.right = opts.right or {}
  --     table.insert(opts.right, {
  --       title = "Outline",
  --       ft = "Outline",
  --       pinned = true,
  --       open = "Outline",
  --     })
  --   end,
  -- },
}
