return {
  -- Mason.nvim.
  -- lazy.nvim installs plugins, i.e. clones from GitHub repo,
  -- before running `config(plugin)` | `require('<main>').setup()`.
  -- Thus, other files marking mason as dependency may use local directory in runtimepath,
  -- i.e. `mason.nvim`, instead of "williamboman/mason.nvim", as spec source.
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {},
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Trigger FileType event to possibly load this newly installed LSP server.
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      -- Install packages listed in `ensure_installed`, even though
      -- - `opts.ensure_installed`: Not valid option for `mason.nvim`,
      --   only for `mason-lspconfig.nvim`, but used for convenience.
      -- - Prefer `ensure_installed` from `mason-lspconfig.nvim`.
      -- - `refresh(cb)`: Asynchronous, due to callback passed in.
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- `mason-lspconfig.nvim`.
  -- - Ensures given LSP server programs are installed.
  -- - `ensure_installed`: Extendable by other specs, due to `opts_extend`.
  -- - Automatically runs `vim.lsp.enable(..)` on LSP servers installed with Mason,
  --   e.g. those listed in `ensure_installed`.
  {
    "mason-org/mason-lspconfig.nvim",
    opts_extend = { "ensure_installed" },
    opts = {},
  },
}
