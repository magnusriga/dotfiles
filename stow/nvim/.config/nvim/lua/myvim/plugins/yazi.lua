return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        -- Open yazi at current file.
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi (file)",
      },
      {
        -- Open yazi in current working directory.
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi (cwd)",
      },
      -- {
      --   -- Resume last yazi session.
      --   -- Conflicts with window resize.
      --   "<c-up>",
      --   "<cmd>Yazi toggle<cr>",
      --   desc = "Resume yazi",
      -- },
    },

    ---@type YaziConfig | {}
    opts = {
      -- Open yazi instead of netrw.
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
        -- Disabled to allow yazi's <C-o> for jump back.
        open_and_pick_window = false,
      },
    },
    init = function()
      -- Mark netrw as loaded so it's not loaded at all.
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
