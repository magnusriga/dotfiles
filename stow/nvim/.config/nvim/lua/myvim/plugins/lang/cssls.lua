local lsp_name = "cssls"

vim.lsp.config(lsp_name, {
  root_dir = MyVim.root(),
  -- Ignore at-rules, to avoid clashes with `tailwind`.
  settings = {
    css = {
      -- Using biome for formatting and linting.
      validate = false,
      -- validate = true,
      -- lint = {
      --   unknownAtRules = "ignore",
      -- },
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
})

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
