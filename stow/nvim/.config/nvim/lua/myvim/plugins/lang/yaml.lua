local lsp_name = "yamlls"

vim.lsp.config(lsp_name, {
  -- For yamlls line folding.
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = {
        enable = true,
      },
      validate = true,
      schemaStore = {
        -- Must disable built-in schemaStore support to use
        -- schemas from SchemaStore.nvim plugin.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length').
        url = "",
      },
    },
  },
})

-- Add schema support to `yamlls`, after `lazy.nvim` has loaded all plugins,
-- to ensure `SchemaStore.nvim` is available.
MyVim.on_very_lazy(function()
  vim.lsp.config[lsp_name].settings.yaml.schemas = require("schemastore").yaml.schemas()
end)

return {
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
