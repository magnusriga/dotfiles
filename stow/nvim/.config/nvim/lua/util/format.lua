---@class myvim.util.format
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.format(...)
  end,
})

---@class MyFormatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number)
---@field sources fun(bufnr:number):string[]
---@field priority number

M.formatters = {} ---@type MyFormatter[]

-- Register new formatter, where formatters with higher `priority`
-- are invoked *before* formatters with lower `priority`.
--
-- When using registered LSP formatter, conform's `opt.formatters` is set to `nil`,
-- which makes conform fallback to `vim.lsp.buf.format`.
--
-- LSP formatter has default `priority = 1`, thus LSP formatter always runs last.
-- `eslint` formatter has `priority = 200`.
-- Conform formatter, when used with `formatter_by_ft`, has `priority = 100`.
--
-- When formatting `.lua` file,
-- normal conform formatter is first invoked,
-- i.e. formatter with `priority` 100, which uses `formatter_by_ft`,
-- which formats buffer using conform with `stylua` formatter,
-- then `lua_ls` LSP formatter is invoked, i.e. formatter with `priority = 1`,
-- which formats buffer using conform with fallback `lus_ls` LSP formatter.
--
-- When formatting `.tsx` file,
-- `eslint` LSP formatter is first invoked, i.e. formatter with `priority = 200`,
-- which formats buffer using conform with fallback `eslint` LSP formatter,
-- then normal conform formatter is invoked,
-- i.e. formatter with `priority = 100`, which uses `formatter_by_ft`,
-- which formats buffer using conform with `prettierd` formatter,
-- then `tsserver` LSP formatter is invoked, i.e. formatter with `priority = 1`,
-- which formats buffer using conform with fallback `tsserver` LSP formatter.
---@param formatter MyFormatter
function M.register(formatter)
  M.formatters[#M.formatters + 1] = formatter
  table.sort(M.formatters, function(a, b)
    return a.priority > b.priority
  end)
end

-- - `opt.formatexpr` uses this function, to format buffers when `gq` is called,
--   or when `textwidth` autoformats text, in latter case `mode()` is `i` or `R`.
-- - Return non-zero value to fallback to built-in `formatprg`,
--   which `conform.formatexpr()` does already, no need to call `mode()`.
function M.formatexpr()
  if MyVim.has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

-- Returns tables containing `{ active = <boolean>, resolved = <sources> }`,
-- and formatter as metatable `__index`, for all formatters.
--
-- `sources`, and thus `resolved`, has value if `conform`, or LSP formatter,
-- has formatter for buffer, which depends on e.g. `conform.nvim` configuration,
-- often set when registering formatter.
--
-- See: `plugins/formatting.lua`.
--
-- Conform formatter registered in `plugins/formatting.lua`, is primary formatter
-- with priority 100.
--
-- LSP formatter registered in `plugins/lsp/init.lua` via `util/lsp.lua`,
-- is also `primary` formatter, but has priority 1, thus it never runs,
-- as only one `primary` formatter is permitted, and one with highest priority is used.
--
-- Certain other LSPs, like `eslint`, register new non-`primary` formatters,
-- with even higher priority, e.g. 200, thus these run first,
-- following which conform using `formatter_by_ft` runs.
--
-- `eslint`'s formatter just does ESLintFixAll, before prettier runs via conform.
--
-- Thus, using all registered formatters where `conform.nvim` has filetype
-- mathcing buffer doing format, and any extra non-primary formatters like `eslint`.
---@param buf? number
---@return (MyFormatter|{active:boolean,resolved:string[]})[]
function M.resolve(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  -- There can only be one `primary` formatter.
  -- All other formatters cannot be marked `primary`,
  -- but will be active and thus used in formatting.
  -- To avoid using formatter, like LSP, then do not register it,
  -- i.e. do not add it to `formatters` table.
  -- Active formatters run in order they are registered,
  -- primary does not necessarily run first.
  local have_primary = false
  return vim.tbl_map(function(formatter)
    -- `sources` contain table of names of each conform formatter for current buffer,
    -- determined by conform using buffer's filetype.
    -- Example: If buffer `filetype` is `javascript`,
    -- then `sources` is `{ 'prettierd', 'prettier' }`.
    -- Only one of these are used by conform.
    local sources = formatter.sources(buf)
    -- If `primary` formatter exists, and another formatter tries to be `primary`,
    -- then do not use it (mark as not `active`).
    -- Otherwise, all registered formatters are active and used.
    local active = #sources > 0 and (not formatter.primary or not have_primary)
    have_primary = have_primary or (active and formatter.primary) or false
    return setmetatable({
      active = active,
      resolved = sources,
    }, { __index = formatter })
  end, M.formatters)
end

---@param buf? number
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = M.enabled(buf)
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      baf == nil and "inherit" or baf and "enabled" or "disabled"
    ),
  }
  local have = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if #formatter.resolved > 0 then
      have = true
      lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
      for _, line in ipairs(formatter.resolved) do
        lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
      end
    end
  end
  if not have then
    lines[#lines + 1] = "\n***No formatters available for this buffer.***"
  end
  MyVim[enabled and "info" or "warn"](
    table.concat(lines, "\n"),
    { title = "Format (" .. (enabled and "enabled" or "disabled") .. ")" }
  )
end

-- Check if automatic formatting on save is enabled,
-- either globally or for buffer being formatted,
-- via `vim.b|g.autoformat`.
---@param buf? number
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- If the buffer has a local value, use that.
  if baf ~= nil then
    return baf
  end

  -- Otherwise use the global value if set, or true by default.
  return gaf == nil or gaf
end

---@param buf? boolean
function M.toggle(buf)
  M.enable(not M.enabled(), buf)
end

-- Enable or disable automatic formatting on save,
-- either globally or for buffer being formatted,
-- by setting `vim.b|g.autoformat`.
--
-- Called via e.g. keymap running: `snacks.nvim` toggle > `MyVim.format.snacks_toggle()` > `MyVim.format.enable()`.
--
-- Note: Manual formatting with usercommand `Format` uses `opts.force = true`,
-- thus disabling formatting, either globally or for buffer being formatted,
-- only applies to automatic formatting on save.
-- Called by e.g. `snacks.nvim`'s toggle > `Myvim.format.enable()`,
-- to toggle formatting on|off.
---@param enable? boolean
---@param buf? boolean
function M.enable(enable, buf)
  if enable == nil then
    enable = true
  end
  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
  M.info()
end

-- Format using all registered formatters where `conform.nvim` has filetype
-- mathcing buffer doing format.
--
-- Conform formatter registered in `plugins/formatting.lua`, is primary formatter
-- with priority 100.
--
-- LSP formatter registered in `plugins/lsp/init.lua` via `util/lsp.lua`,
-- is also `primary` formatter, but has priority 1, thus it never runs,
-- as only one `primary` formatter is permitted, and one with highest priority is used.
--
-- Certain other LSPs, like `eslint`, register new non-`primary` formatters,
-- with even higher priority, e.g. 200, thus these run first,
-- following which conform using `formatter_by_ft` runs.
--
-- `eslint`'s formatter just does ESLintFixAll, before prettier runs via conform.
---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()

  -- If formatting is disabled, either globally or for buffer being formatted,
  -- checked via `vim.b|g.autoformat`, which is toggled
  -- e.g. with keymap running `snacks.nvim` toggle > `MyVim.format.snacks_toggle()` > `MyVim.format.enable()`,
  -- then do not format.
  -- Note: Manual formatting with usercommand `Format` uses `opts.force = true`,
  -- thus disabling formatting, either globally or for buffer being formatted,
  -- only applies to automatic formatting on save.
  if not ((opts and opts.force) or M.enabled(buf)) then
    return
  end

  local done = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if formatter.active then
      done = true
      MyVim.try(function()
        MyVim.info("Formatting now with " .. formatter.name)
        return formatter.format(buf)
      end, { msg = "Formatter `" .. formatter.name .. "` failed" })
    end
  end

  if not done and opts and opts.force then
    MyVim.warn("No formatter available", { title = "Neovim" })
  end
end

-- Create autocommand and usercommand to format buffer,
-- using registered formatter, i.e. conform by filetype,
-- and any other registered non-primary formatters, like `eslint`.
function M.setup()
  -- Autocmd to automatically format on save.
  -- Disable with `MyVim.format.enable()`,
  -- e.g. with keymap running `snacks.nvim` toggle > `MyVim.format.snacks_toggle()` > `MyVim.format.enable()`.
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("Format", {}),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })

  -- Manual format, using `force = true`, thus formats even if formatting disabled,
  -- e.g. with keymap running `snacks.nvim` toggle > `MyVim.format.snacks_toggle()` > `MyVim.format.enable()`.
  vim.api.nvim_create_user_command("Format", function()
    M.format({ force = true })
  end, { desc = "Format selection or buffer." })

  -- Format info.
  vim.api.nvim_create_user_command("FormatInfo", function()
    M.info()
  end, { desc = "Show info about the formatters for the current buffer." })
end

-- Toggle automatic formatting on save on|off,
-- for buffer if `true` is passed in,
-- otherwise globally for all buffers.
-- Bind to keymap, see: `config/keymaps.lua`.
---@param buf? boolean
function M.snacks_toggle(buf)
  return Snacks.toggle({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      if not buf then
        return vim.g.autoformat == nil or vim.g.autoformat
      end
      return MyVim.format.enabled()
    end,
    set = function(state)
      MyVim.format.enable(state, buf)
    end,
  })
end

return M
