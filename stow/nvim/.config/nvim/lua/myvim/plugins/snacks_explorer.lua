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
        -- ---@type snacks.picker.explorer.Config: snacks.picker.files.Config|{}
        explorer = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = MyVim.root() })
        vim.cmd("normal! zz")
      end,
      desc = "Explorer (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer (cwd)",
    },
    -- {
    --   "<leader>f-",
    --   function()
    --     Snacks.explorer.reveal()
    --   end,
    --   desc = "Explorer (Reveal, cwd)",
    -- },
    { "<leader>e", "<leader>fe", desc = "Explorer (Root Dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer (cwd)", remap = true },
    -- { "<leader>-", "<leader>f-", desc = "Explorer (Reveal, cwd)", remap = true },
  },
}
