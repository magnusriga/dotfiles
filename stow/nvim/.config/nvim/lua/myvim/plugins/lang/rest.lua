-- Kulala-ls is not available in Mason registry, installed manually.
-- Thus, cannot use `mason-lspconfig` to install it.
-- Thus, enable LSP manually, with `vim.lsp.enable(...)`.
local lsp_name = "kulala_ls"

vim.lsp.config(lsp_name, {
  root_dir = function(fname)
    -- Use cwd as root dir, since Kulala scratchpad does not belong to git directory.
    -- return vim.fs.dirname(vim.fs.find(".http", { path = fname, upward = true })[1])
    return vim.fs.dirname(".")
  end,
  capabilities = {
    workspace = {
      didChangeConfiguration = { dynamicRegistration = true },
      didChangeWorkspaceFolders = { dynamicRegistration = true },
    },
  },
})

-- Enable manually, since `kulala-ls` is not in Mason registry.
vim.lsp.enable(lsp_name)

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
      -- { "<leader>rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad", ft = "http" },

      -- Set in `lua/plugins/editor.lua > which-key.nvim`.
      -- { "<leader>r", "", desc = "+Rest" },

      -- Removed `ft = http`, to allow opening scratchpad from any file.
      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
      { "<leader>Ro", "<cmd>lua require('kulala').open()<cr>", desc = "Open kulala" },

      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = { "http", "rest" } },
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = { "http", "rest" } },

      {
        "<leader>Re",
        "<cmd>lua require('kulala').set_selected_env()<cr>",
        desc = "Find request",
        ft = { "http", "rest" },
      },
      { "<leader>Rf", "<cmd>lua require('kulala').search()<cr>", desc = "Find request", ft = { "http", "rest" } },
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = { "http", "rest" },
      },
      {
        "<leader>Ri",
        "<cmd>lua require('kulala').inspect()<cr>",
        desc = "Inspect current request",
        ft = { "http", "rest" },
      },
      {
        "<leader>Rn",
        "<cmd>lua require('kulala').jump_next()<cr>",
        desc = "Jump to next request",
        ft = { "http", "rest" },
      },
      {
        "<leader>Rp",
        "<cmd>lua require('kulala').jump_prev()<cr>",
        desc = "Jump to previous request",
        ft = { "http", "rest" },
      },
      { "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = { "http", "rest" } },

      -- Removed `ft = http`, to allow running request from comments,
      -- or `vim.system({ "curl", "-X GET ..."})`, in any file.
      { "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay last request" },
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send request" },
      { "<leader>Ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Send all requests" },

      { "<CR>", "<cmd>lua require('kulala').run()<cr>", desc = "Send request (<CR>)", ft = { "http", "rest" } },

      { "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = { "http", "rest" } },
      {
        "<leader>Rt",
        "<cmd>lua require('kulala').toggle_view()<cr>",
        desc = "Toggle headers/body",
        ft = { "http", "rest" },
      },

      {
        "<leader>Rx",
        "<cmd>lua require('kulala').scripts_clear_global()<cr>",
        desc = "Clear globals",
        ft = { "http", "rest" },
      },
      {
        "<leader>RX",
        "<cmd>lua require('kulala').clear_cached_files()<cr>",
        desc = "Clear cached files",
        ft = { "http", "rest" },
      },
    },
    opts = {},
  },
}
