return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- {
      --   -- Open yazi at current file.
      --   -- Using `snacks.explorer` instead.
      --   "<leader>e",
      --   "<cmd>Yazi<cr>",
      --   desc = "Open yazi (file)",
      -- },
      {
        -- Open yazi in current working directory.
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi (cwd)",
      },
      {
        -- Resume last yazi session.
        "<leader>c-",
        mode = { "n", "v" },
        "<cmd>Yazi toggle<cr>",
        desc = "Resume yazi",
      },
    },

    ---@type YaziConfig
    opts = {
      -- Open yazi instead of netrw.
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
}
