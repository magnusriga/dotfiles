vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("schemastore_json", {
    clear = true,
  }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.lsp.config("jsonls", {
      -- Enable JSON validation.
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          format = {
            enable = true,
          },
          validate = { enable = true },
        },
      },
    })
  end,
})

return {
  -- Add json to treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "json5" } },
  },

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
        jsonls = {
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
