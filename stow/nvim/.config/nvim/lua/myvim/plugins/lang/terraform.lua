local lsp_names = { "terraformls" }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "terraform", "hcl" } },
  },

  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = lsp_names },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Uses custom `ensure_installed`, see: `plugins/mason.lua`.
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "tflint" })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft["hcl"] = { "packer_fmt" }
      opts.formatters_by_ft["terraform"] = { "terraform_fmt" }
      opts.formatters_by_ft["tf"] = { "terraform_fmt" }
      opts.formatters_by_ft["terraform-vars"] = { "terraform_fmt" }
    end,
  },
}
