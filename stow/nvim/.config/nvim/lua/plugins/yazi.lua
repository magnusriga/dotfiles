return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume yazi",
      },
      {
        "<leader>c-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi (file)",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi (cwd)",
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
