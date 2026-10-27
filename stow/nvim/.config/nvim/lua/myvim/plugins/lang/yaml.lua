local lsp_name = "yamlls"

-- GitLab CI files get `yaml.gitlab` filetype, which `yamlls` attaches to with GitLab CI schema.
vim.filetype.add({
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
  },
})

vim.lsp.config(lsp_name, {
  -- Filetypes registered by Neovim and `plugins/lang/docker.lua`.
  -- Helm values use ordinary `yaml` here; no Helm-specific filetype is registered.
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
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
