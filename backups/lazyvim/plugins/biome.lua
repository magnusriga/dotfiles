local lsp_name = "biome"

-- vim.lsp.config(lsp_name, {
--   cmd = { "biome", "lsp-proxy" },
-- })

return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },
}
