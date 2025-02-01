---@class lazyvim.util.ui
local M = {}

function M.foldtext()
  local nl = vim.v.foldend - vim.v.foldstart + 1
  -- vim.print("nl " .. nl)
  -- vim.print("vim.cmd.getline(vim.v.foldstart) " .. vim.fn.getline(vim.v.foldstart))
  local comment = vim.fn.substitute(vim.fn.getline(vim.v.foldstart), "^ *", "", "")
  -- vim.print("comment " .. comment)
  local linetext = vim.fn.substitute(vim.fn.getline(vim.v.foldstart + 1), "^ *", "", "")
  -- vim.print("lientext " .. linetext)
  -- local sep = vim.fn.repeat('-', winwidth(0)-strlen(spaces . sub) - offset) . '('. lines .')'
  local txt1 = "+ " .. linetext .. ' : "' .. comment
  -- vim.print("winwidth: " .. vim.fn.winwidth(0))
  -- vim.print("len: " .. vim.fn.strlen(txt1))
  local sep = vim.fn["repeat"]("-", vim.fn.winwidth(0) - vim.fn.strlen(txt1) - 20)
  local txt2 = txt1 .. sep .. " length " .. nl
  -- vim.print(txt2)
  -- vim.print("dome")
  -- return txt2
  return "hello"
end

-- Optimized treesitter `foldexpr`.
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- If no filetype, do not check if treesitter is available,
    -- as it is not.
    if vim.bo[buf].filetype == "" then
      vim.print("here")
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

return M
