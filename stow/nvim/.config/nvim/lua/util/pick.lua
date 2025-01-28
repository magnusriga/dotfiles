---@class myvim.util.pick
---@overload fun(command:string, opts?:myvim.util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
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
      "`MyVim.pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`"
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

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    MyVim.warn("MyVim.pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

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
