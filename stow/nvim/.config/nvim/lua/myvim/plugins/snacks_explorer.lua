-- `snacks.nvim` file explorer.
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    -- `snacks.nvim` file explorer options.
    -- Empty means default configuration.
    explorer = {},
    -- `snacks.nvim` picker options, for explorer source.
    -- Empty means default configuration.
    picker = {
      sources = {
        explorer = {},
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = MyVim.root() })
      end,
      desc = "Explorer Snacks (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer (Root Dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer (cwd)", remap = true },
  },
}
