local LazyUtil = require("lazy.core.util")

-- ---@field ui lazyvim.util.ui
-- ---@field terminal lazyvim.util.terminal
-- ---@field extras lazyvim.util.extras
-- ---@field inject lazyvim.util.inject
-- ---@field news lazyvim.util.news
-- ---@field json lazyvim.util.json

---@class myvim.util: LazyUtilCore
---@field cmp myvim.util.cmp
---@field config MyVimConfig
---@field format myvim.util.format
---@field lualine myvim.util.lualine
---@field lsp myvim.util.lsp
---@field mini myvim.util.mini
---@field pick myvim.util.pick
---@field plugin myvim.util.plugin
---@field root myvim.util.root
---@field terminal myvim.util.terminal
local M = {}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("myvim.util." .. k)
    -- M.deprecated.decorate(k, t[k])
    return t[k]
  end,
})

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

-- Pause all notifications until `vim.notify` has been replaced,
-- by continously checking in separate thread, every turn of event loop,
-- if `vim.notify` is different from original.
--
-- Once replacement has happened, or 500ms has passed, run all delayed notifications,
-- either using new `vim.notify`, or original `vim.notify` if replacement did not happen.
--
-- This function takes all normal notifications and adds them to list, `notifs`,
-- then once `vim.notify` has been replaced with own notification function,
-- re-run all previous notifications with that new `vim.notify` function.
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = assert(vim.uv.new_timer(), "Failed to create timer.")
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- Put back the original notify if needed.
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- Callback passed to `start` runs once on every iteration of event loop,
  -- which constantly checks for IO opterations,
  -- right after polling for IO opteration.
  -- Once `vim.notify` has been replaced, done by `snacks.nvim` | `notice.nvim`,
  -- re-run all previous notifications with new `vim.notify`.
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)

  -- If replacement has not happened in 500ms, something went wrong,
  -- thus call replay, which will use original `vim.notify` function.
  timer:start(500, 0, replay)
end

function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- Wrapper around `vim.keymap.set` that will create keymap,
-- unless `lazy.nvim` key handler for same binding already exists.
-- Also sets `silent = true`.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys

  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  -- Filter out modes, e.g. `n`, for which `lazy.nvim` key handler already exists.
  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- If length of `modes` table > 0, then `lazy.nvim` did not have
  -- key handler for given keys, i.e. `lhs`, and `modes`, e.g. `n`.
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

-- Adds undo breakpoint at cursor, if in Insert mode when called.
M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
  pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
    M.warn(
      ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(pkg, path)
    )
  end
  return ret
end

-- Certain functions are expensive to run,
-- like `has_config` which runs `prettier --find-config-path <filename>`.
-- Thus, cache result, with key equal to arguments passed to function when first called.
local cache = {} ---@type table<(fun()), table<string, any>>

---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then
      cache[fn][key] = fn(...)
    end
    return cache[fn][key]
  end
end

-- Use "blink.cmp" as default completion engine.
-- To change to `nvim.cmp`: Set `vim.g.lazyvim_cmp` to `nvim-cmp`, in `config/options.lua`.
---@return "nvim-cmp" | "blink.cmp"
function M.cmp_engine()
  return vim.g.lazyvim_cmp or "blink-cmp"
end

return M
