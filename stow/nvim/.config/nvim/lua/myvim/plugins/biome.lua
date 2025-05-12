local lsp_name = "biome"
-- Manually enable, since not installing executable with `mason-lspconfig`.
vim.lsp.config(lsp_name, {
  -- Use `pnpm` to run `biome` executable.
  cmd = { "pnpm", "biome", "lsp-proxy" },
  -- filetypes = {
  --   "astro",
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

-- =============================
-- User commands.
-- =============================
-- -----------------------------
-- Helper functions.
-- -----------------------------
local function get_biome_config_dir_for_file(file_path_for_context)
  -- file_path_for_context is expected to be an absolute path to a file
  local start_dir = vim.fn.fnamemodify(file_path_for_context, ":h")

  if start_dir == "" or start_dir == "." then
    -- Fallback if path modification results in empty or current dir,
    -- though callers should provide absolute paths making this unlikely.
    start_dir = vim.fn.getcwd()
  end

  local found_config_files = vim.fs.find({ "biome.json", "biome.jsonc" }, {
    path = start_dir, -- Directory to start searching from
    upward = true, -- Search upwards towards root
    type = "file", -- We are looking for files
    limit = 1, -- Stop after finding the first one
  })

  if found_config_files and #found_config_files > 0 then
    -- found_config_files[1] is the full path to the biome.json or biome.jsonc
    -- --config-path expects the directory containing this file.
    return vim.fn.fnamemodify(found_config_files[1], ":h")
  end

  return nil -- No config file found
end

-- -----------------------------
-- Actual user commands.
-- -----------------------------
vim.api.nvim_create_user_command("BiomeInfo", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("No file to process.", vim.log.levels.WARN)
    return
  end
  local command_base = "pnpm biome rage "
  local config_dir = get_biome_config_dir_for_file(file_path)
  local config_option = ""
  if config_dir then
    config_option = "--config-path " .. vim.fn.shellescape(config_dir)
  end
  local command_str = command_base .. config_option
  vim.cmd("!" .. command_str)
end, {
  desc = "Biome information.",
  nargs = 0,
})

-- - `conform.nvim` runs `biome format`, or if overwritten then `biome check`.
-- - Meaning, `conform.nvim` already handles formatting when running `Format` | on save.
-- - Thus, below autocommands mainly used for:
--   - Manual formatting with biome only, not really needed.
--   - Run `biome check --write --unsafe`, which also fixes lint issues that may break functionality.
vim.api.nvim_create_user_command("BiomeFix", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("No file to process.", vim.log.levels.WARN)
    return
  end
  local command_base = "pnpm biome check --write "
  local config_dir = get_biome_config_dir_for_file(file_path)
  local config_option = ""
  if config_dir then
    config_option = "--config-path " .. vim.fn.shellescape(config_dir) .. " "
  end
  local command_str = command_base .. config_option .. vim.fn.shellescape(file_path)
  vim.schedule(function()
    vim.cmd("silent !" .. command_str)
  end)
end, {
  desc = "Format, fix lint issues, fix import order (safe).",
  nargs = 0,
})

vim.api.nvim_create_user_command("BiomeFixUnsafe", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("No file to process.", vim.log.levels.WARN)
    return
  end
  local command_base = "pnpm biome check --write --unsafe "
  local config_dir = get_biome_config_dir_for_file(file_path)
  local config_option = ""
  if config_dir then
    config_option = "--config-path " .. vim.fn.shellescape(config_dir) .. " "
  end
  local command_str = command_base .. config_option .. vim.fn.shellescape(file_path)
  vim.schedule(function()
    vim.cmd("silent !" .. command_str)
  end)
end, {
  desc = "Format, fix lint issues, fix import order (unsafe).",
  nargs = 0,
})

return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  -- - NOTE: Skip, using project-local `biome` executable, installed with `pnpm`.
  -- {
  --   "mason-org/mason-lspconfig.nvim",
  --   -- Using `opts_extend`, see `plugins/mason.lua`.
  --   opts = { ensure_installed = { lsp_name } },
  -- },
}
