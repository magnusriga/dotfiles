local auto_format = vim.g.myvim_eslint_auto_format == nil or vim.g.myvim_eslint_auto_format

return {
  {
    "neovim/nvim-lspconfig",
    -- Other settings removed for brevity.
    opts = {
      servers = {
        eslint = {
          settings = {
            -- Helps eslint find `eslintrc` when placed in subfolder instead of cwd root.
            workingDirectories = { mode = "auto" },
            format = auto_format,
            -- format = false,
          },
        },
      },
      setup = {
        eslint = function()
          if not auto_format then
            return
          end

          local formatter = MyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          -- Register formatter with MyVim.
          MyVim.format.register(formatter)
        end,
      },
    },
  },
}
