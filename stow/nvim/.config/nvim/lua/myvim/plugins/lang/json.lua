local lsp_name = "jsonls"

vim.lsp.config(lsp_name, {
  settings = {
    json = {
      format = {
        -- enable = true,
        -- Using: `biome`.
        enable = false,
      },
      validate = { enable = true },
    },
  },
})

-- Add schema support to `yamlls`, after `lazy.nvim` has loaded all plugins,
-- to ensure `SchemaStore.nvim` is available.
MyVim.on_very_lazy(function()
  vim.lsp.config[lsp_name].settings.json.schemas = require("schemastore").json.schemas()
end)

return {
  -- Add json to treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "json5" } },
  },

  -- YAML and JSON schema support.
  {
    "b0o/SchemaStore.nvim",
    version = false, -- Last release too old.
  },

  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },
}
