local M = setmetatable({}, {
  __call = function(m, ...)
    return m.format(...)
  end,
})

M.formatters = {}

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
function M.register(formatter)
  M.formatters[#M.formatters + 1] = formatter
  table.sort(M.formatters, function(a, b)
    return a.priority > b.priority
  end)
end

function M.formatexpr()
  if MyVim.has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

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

function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not ((opts and opts.force) or M.enabled(buf)) then
    return
  end

  local done = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if formatter.active then
      done = true
      MyVim.try(function()
        MyVim.info("Formatting now")
        return formatter.format(buf)
      end, { msg = "Formatter `" .. formatter.name .. "` failed" })
    end
  end

  if not done and opts and opts.force then
    MyVim.warn("No formatter available", { title = "Neovim" })
  end
end

function M.setup()
  -- Autoformat autocmd.
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("Format", {}),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })

  -- Manual format.
  vim.api.nvim_create_user_command("Format", function()
    M.format({ force = true })
  end, { desc = "Format selection or buffer." })

  -- Format info.
  vim.api.nvim_create_user_command("FormatInfo", function()
    M.info()
  end, { desc = "Show info about the formatters for the current buffer." })
end

return M
