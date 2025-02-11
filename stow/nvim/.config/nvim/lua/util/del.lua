vim.print("running del.lua")

vim.api.nvim_buf_attach(0, false, {
  on_lines = function(...)
    vim.print("foo")
  end,
})

local events = {}
local count = 0
vim.print("count" .. count)

vim.schedule(function()
vim.api.nvim_buf_attach(0, false, {
  on_lines = function(...)
    vim.print(count)
    count = count + 1
    table.insert(events, { ... })
  end
})
end
)
