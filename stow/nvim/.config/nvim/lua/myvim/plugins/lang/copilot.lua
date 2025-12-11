local lsp_name = "copilot"

-- vim.lsp.config(lsp_name, {})

-- Configure Copilot LSP.
vim.lsp.config("copilot", {
  cmd = { "copilot-language-server", "--stdio" },
  root_markers = { ".git" },
})

-- Enable inline completion.
vim.lsp.inline_completion.enable()

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
