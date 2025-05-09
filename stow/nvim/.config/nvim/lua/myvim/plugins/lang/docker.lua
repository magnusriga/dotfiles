local lsp_names = { "dockerls", "docker_compose_language_service" }
-- vim.lsp.config("dockerls", {
--   settings = {
--     docker = {
--       validate = true,
--       completion = true,
--       format = { enable = true },
--     },
--   },
-- })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },

  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = lsp_names },
  },
}
