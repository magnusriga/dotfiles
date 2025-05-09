return {
  -- `neovim/nvim-lspconfig`:
  -- - No longer needed for configuring and enabling LSP servers, now done with:
  --   - `vim.lsp.config("<name>", {..})`
  --   - `vim.lsp.enable("<name>")`
  -- - `nvim-lspconfig` included as it automatically calls `vim.lsp.config("<name>" {..})`
  --   with sane defaults, for various LSP servers.
  -- - `mason-lspconfig.nvim` automatically calls `vim.lsp.enable(..)`.
  -- - Thus, no need to call `vim.lsp.config(..)` | `vim.lsp.enable(..)`,
  --   unless to override default LSP client and server configuration.
  -- - `vim.lsp.config(..)` and `vim.lsp.enable(..)`, latter via `mason-lspconfig.nvim`,
  --   are called in `plugins/lang/<lang>.lua` files.
  {
    "neovim/nvim-lspconfig",
  },
}
