local lsp_name = "biome"
-- Manually enable, since not installing executable with `mason-lspconfig`.
vim.lsp.config(lsp_name, {
  -- Use globally installed biome.
  -- NOTE: biome logs "Loading configuration from..." to stderr, which Neovim
  -- shows as [ERROR] in lsp.log - this is informational, not an actual error.
  cmd = { "biome", "lsp-proxy" },
  -- filetypes = {
	--   "astro",
	--   -- Both `cssls` and `biome` reports errors on certain tailwind syntax,
	--   -- e.g. `@import 'tailwindcss' prefix(tw)`, thus might as well keep both for `css`.
	--   "css",
	--   "graphql",
	--   "javascript",
	--   "javascriptreact",
	--   "json",
	--   "jsonc",
	--   "svelte",
	--   "typescript",
	--   "typescript.tsx",
	--   "typescriptreact",
	--   "vue",
	-- },
})
vim.lsp.enable(lsp_name)

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
