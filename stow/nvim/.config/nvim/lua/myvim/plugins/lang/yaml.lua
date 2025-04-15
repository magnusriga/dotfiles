return {
  -- Yaml schema support.
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- Last release is too old.
  },

  -- Correctly setup lspconfig.
  {
    "neovim/nvim-lspconfig",
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
          -- Lazy-load schemastore when needed.
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end,
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
