---@class myvim.util.pick
---@overload fun(command:string, opts?:myvim.util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    -- ====================================================================
    -- When `MyVim.pick(<command>)` is called.
    -- ====================================================================
    -- - `MyVim.pick(<command>, <opts>)` calls `picker.open(<command>, <opts>)`,
    --   which uses root of current buffer as `opts.cwd`, if `opts.cwd` is not passed in.
    -- - Root of current buffer found via: `MyVim.root({ buf = opts.buf })`.
    -- - Example:
    --   `MyVim.pick("files")` >
    --   `MyVim.pick.wrap("files")` >
    --   `MyVim.pick.open("files")` >
    --   `MyVim.pick.picker.open("files", { cwd = vim.fn.stdpath("config") })` >
    --   `MyVim.pick.picker === Table from `lua/plugins/fzf.lua`,
    --   including `open` | `name` | `commands` keys.
    return m.wrap(...)
  end,
})

---@class myvim.util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class MyPicker
---@field name string
---@field open fun(command:string, opts?:myvim.util.pick.Opts)
---@field commands table<string, string>

---@type MyPicker?
M.picker = nil

---@param picker MyPicker
function M.register(picker)
  if M.picker and M.picker.name ~= M.want() then
    M.picker = nil
  end

  if M.picker and M.picker.name ~= picker.name then
    MyVim.warn(
      "`MyVim.pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`."
    )
    return false
  end
  M.picker = picker
  return true
end

---@return "telescope" | "fzf"
function M.want()
  -- Default to `fzf`.
  vim.g.myvim_picker = vim.g.myvim_picker or "fzf"
  return vim.g.myvim_picker
end

---@param command? string
---@param opts? myvim.util.pick.Opts
function M.open(command, opts)
  if not M.picker then
    return MyVim.error("MyVim.pick: picker not set")
  end

  vim.print(" MyVim.pick: picker set to " .. M.picker.name)

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    MyVim.warn("MyVim.pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

  -- When `opts` not passed in to `MyVim.pick(<cmd>, <opts>)`, default to
  -- `MyVim.root({ buf = opts.buf })`, which is root of current buffer.
  if not opts.cwd and opts.root ~= false then
    opts.cwd = MyVim.root({ buf = opts.buf })
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

---@param command? string
---@param opts? myvim.util.pick.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    MyVim.pick.open(command, vim.deepcopy(opts))
  end
end

function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
