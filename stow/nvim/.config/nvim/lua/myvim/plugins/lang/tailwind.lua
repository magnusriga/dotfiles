local lsp_name = "tailwindcss"

vim.lsp.config(lsp_name, {
  settings = {
    tailwindCSS = {
      -- For autocompletee inside Class Variance Authority (CVA) functions.
      classFunctions = { "cva", "cx" },
      includeLanguages = { ["markdown.mdx"] = "mdx" },
    },
  },
  -- Filetypes copied from tailwindcss-intellisense, limited to filetypes Neovim detects.
  -- VSCode language identifiers without Neovim filetype, e.g. `ejs` | `hbs` | `postcss`,
  -- are excluded, Neovim equivalents, e.g. `eruby` | `handlebars`, are included.
  filetypes = {
    -- html
    "astro",
    "blade",
    "clojure",
    "htmldjango",
    "eelixir",
    "elixir",
    "eruby",
    "haml",
    "handlebars",
    "html",
    "htmlangular",
    "heex",
    "liquid",
    -- 'markdown', -- Exclude.
    "markdown.mdx",
    "mustache",
    "php",
    "razor",
    "twig",
    -- css
    "css",
    "less",
    "sass",
    "scss",
    "stylus",
    -- js
    "javascript",
    "javascriptreact",
    "rescript",
    "typescript",
    "typescriptreact",
    -- mixed
    "vue",
    "svelte",
    "templ",
  },
})

return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },
}
