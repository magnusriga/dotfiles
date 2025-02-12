return {
  -- Add json to treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "json5" } },
  },

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
        jsonls = {
          -- Lazy-load schemastore when needed.
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
      },
    },
  },
}
