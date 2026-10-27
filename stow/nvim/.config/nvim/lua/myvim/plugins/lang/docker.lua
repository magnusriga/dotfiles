local lsp_names = { "dockerls", "docker_compose_language_service" }

-- Compose files get `yaml.docker-compose` filetype, which `docker_compose_language_service`
-- and `yamlls` attach to, in addition to regular `yaml` plugins.
vim.filetype.add({
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    -- Variants like `docker-compose.override.yml` | `compose.dev.yaml`.
    [".*/docker%-compose%.[%w%-_]+%.ya?ml"] = "yaml.docker-compose",
    [".*/compose%.[%w%-_]+%.ya?ml"] = "yaml.docker-compose",
  },
})
-- vim.lsp.config("dockerls", {
--   settings = {
--     docker = {
--       validate = true,
--       completion = true,
--       format = { enable = true },
--     },
--   },
-- })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },

  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = lsp_names },
  },
}
