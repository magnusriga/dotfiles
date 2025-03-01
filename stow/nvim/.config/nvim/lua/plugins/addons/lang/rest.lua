-- Make Neovim recognize files with `.http` extension as HTTP files.
vim.filetype.add({
  extension = {
    ["http"] = "http",
  },
})

vim.system({ "curl", "-X GET http://localhost:3000" })

-- POST http://localhost:3000
-- Content-Type: application/json
-- {"name": "John Doe"}
-- Run HTTP requests from within Neovim.

return {
  -- Ensure language parsers are installed.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "http", "graphql" },
    },
  },

  -- Setup Kulala plugin, enabling HTTP requests from within Neovim.
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      -- { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad", ft = "http" },

      -- Set in `lua/plugins/editor.lua > which-key.nvim`.
      -- { "<leader>R", "", desc = "+Rest" },

      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },

      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" },
      { "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request", ft = "http" },
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
    },
    opts = {},
  },

  -- Setup LS.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kulala_ls = {},
      },
    },
  },
}
