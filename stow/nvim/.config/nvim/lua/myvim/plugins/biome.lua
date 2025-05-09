local lsp_name = "biome"

-- =============================
-- User commands.
-- =============================
-- - `conform.nvim` runs `biome format`, or if overwritten then `biome check --write`.
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
  local command_str = "biome check --write " .. vim.fn.shellescape(file_path)
  vim.cmd("silent !" .. command_str)
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
  local command_str = "biome check --write --unsafe " .. vim.fn.shellescape(file_path)
  vim.cmd("silent !" .. command_str)
end, {
  desc = "Format, fix lint issues, fix import order (unsafe).",
  nargs = 0,
})

-- ==========================================================
-- Fix lint issues and import order on `:Format` and save.
-- ==========================================================
-- - Register `biome` as formatter, using `formatter` from `MyVim.lsp.formatter`,
--   with `format` function replaced with command `silent biome check --write <file>`.
-- - Thus, formatting buffer with `Format` | save, results in:
--   1. `biome check --write`: Runs if `biome` is attached to buffer.
--   2. `conform.nvim`: Runs `biome` formatter, if applicable filetype.
--
-- - `primary = true`:
--   - Only allowed to have ONE primary formatter.
--   - Below formatter is primary.
--   - `conform` is `primary`, with `priority = 100`, see: `plugins/formatting.lua`.
--   - Below formatter has `priority = 200`.
--   - Thus, only below formatter is `active`.
--
-- NOTE: This custom formatter will not be `active` in buffers where `biome` in
-- not attached, which allows `conform.nvim` to be `active` `primary` formatter.
--
-- - `priority = 200`:
--   - Primary formatter with highest priority applies.
--   - Non-primary formatters run in order of priority, highest first.
--   - Thus, `biome` formatter runs instead of `conform.nvim`.
--
-- `biome check --write`:
-- - Formats document
-- - Fixes safe lint errors
-- - Fixes import statement order
--
-- NOTE:
-- - `biome check --write` also does formatting.
-- - Tried to use `biome check --write` as conform command, without success.
-- - Default `conform.nvim` command for `biome` is:
--   - `command = util.form_node_modules("biome")`
--   - `args = { "format", "--stdin-file-path", "$FILENAME" }`
--   - `cwd = util.root_file({
--       "biome.json",
--       "biome.jsonc",
--     }`
-- - Thus, stick to below custom formatter.
--
MyVim.on_very_lazy(function()
  MyVim.format.register({
    name = "biome-safe-fix",
    priority = 200,
    primary = true,
    format = function(buf)
      local file_path = vim.api.nvim_buf_get_name(buf)
      if file_path == "" then
        vim.notify("No file to process.", vim.log.levels.WARN)
        return
      end
      -- Run in `vim.schedule`, to avoid textlock.
      vim.schedule(function()
        local command_str = "biome check --write " .. vim.fn.shellescape(file_path)
        vim.cmd("silent !" .. command_str)
      end)
    end,
    sources = function(buf)
      local clients = vim.lsp.get_clients({ bufnr = buf })
      local ret = vim.tbl_filter(function(client)
        return client.name == lsp_name
      end, clients)
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  })
end)

return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
    init = function() end,
  },
}
