-- YAML schema support.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("schemastore_yaml", {
    clear = true,
  }),
  pattern = { "yaml", "yml" },
  callback = function()
    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemas = require("schemastore").yaml.schemas(),
        },
      },
    })
  end,
})

return {
  -- Correctly setup lspconfig, with schema store.
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "b0o/SchemaStore.nvim",
        version = false, -- Last release is too old.
      },
    },
    opts = {
      -- Make sure mason installs server.
      servers = {
        yamlls = {
          -- Have to add this for yamlls line folding.
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
        },
      },
    },
  },
}
