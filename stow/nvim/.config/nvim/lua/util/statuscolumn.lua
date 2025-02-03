-- ==================================
-- NOTES
-- ==================================
-- - Do not `vim.print` anything in these functions, it will end up in statuscolumn, indent, etc.
-- - Must set `opt.number` for statuscolumn to show line number,
--   regardless if `opt.statuscolumn` contains `%l`.
--   Without `opt.relativenumber`, statuscolumn shows wrong relative number,
--   even if `opt.statuscolumn` contains `vim.v.relnum`.
--   even if `o`
-- - When using `vim.v.relnum`, cursor movement by itself will not cause 'statuscolumn'
--   to update unless `opt.relativenumber` is set, see: `h: statuscolumn`.
-- - `opt.statuscolumn` is evaluated once for every line, on every cursor movement when
--   `opt.relativenumber` is set, thus expensive calculations will hurt performance.
--
-- ----------------------------------
-- Folds.
-- ----------------------------------
-- - `[l|r]num`: Evaluated for every line, when used in e.g. `foldexpr`.
--
-- - `vim.v.lnum`:
--   - Read-only number of current line.
--   - Numbeer while `foldexpr`, `statuscolumn`, etc., are sandbox evaluated, otherwise zero.
--
-- - `vim.v.relnum`:
--   - Same as `lnum`, but for relative number to current cursor line.
-- - `%l`: Evaluates to line number inside `opt.statuscolumn`.
-- - `%r`: Same as `%l`, but for relative line number.
--
-- - `foldclosed({lnum})`.
--   - Line number of first line in closed fold, if line `lnum` is part of closed fold.
--   - `foldclosedend({lnum})`: Line number of last line in closed fold.
--   - If line `lnum` is not part of closed fold, -1 is returned.
--
-- - `foldlevel({lnum})`.
--   - Returns foldlevel of line `lnum`, in current buffer.
--   - If nested fold at line `lnum`, deepest level is returned.
--   - If no folds at line `lnum`, `0` is returned.
--   - Irrelevant if fold is open or closed.
--   - If used in `foldexpr`, `1` returned for lines where folds are still to be updated.
--   - `lnum` is first line of fold when `foldlevel` of current mismatches previous line.
--
-- - `%=`: Right-align what comes after, within column, see: `:h statuscolumn`.
--
-- ----------------------------------
-- Extmarks and signs.
-- ----------------------------------
-- - Namespaces for extmarks:
--   - Normal: `gitsigns_signs_`.
--   - Staged: `gitsigns_signs_staged`.
--   - Deleted: `gitsigns_removed`.
-- - Deleted:
--   - Uses `virt_lines`: Virtual line to add above|below mark.
--   - Sets `virt_lines_above`: Virtual line should be above `virt_line`.
-- - `gitsigns.manager` > `Signs.new(cfg, name)`:
--   - Creates two new Signs, one for normal changes and one for stages changes.
--   - `signs.namespace` of extmarks for lines with normal changes: `gitsigns_signs_`.
--   - `signs.namespace` of extmarks for lines with stages changes: `gitsigns_signs_staged`.
-- - New `signs` table for normal and staged changes also has fields:
--   - `hls` normal | staged: `{ add = { hl = GitSigns[Staged]Add, text = '|', .. }, change = {..}, ..}`.
--   - `name`.
--   - `group`.
--   - `config`.
--   - `ns`: `gitsigns_signs_` | `gitsigns_signs_staged` | ...
-- - These two `signs` tables are created and stored in `manager`:
--   - `signs_normal`.
--   - `signs_staged`.
-- - When toggling signs in signcolumn off: `manager.reset` > `signs_[normal and staged].reset()`.
--   - Clears all namespaced objects, i.e. highlights, extmarks, and virtual text, from current file,
--     with: `vim.api.nvim_buf_clear_namespace(bufnr, self.ns, 0, -1)`,
--   - Done once for each buffer, found with: `vim.api.nvim_list_bufs`, which includes
--     unloaded/deleted buffers, like calling `ls!`.
--   - Goes through all hunks in file, and if signs toggle is ON then creates extmarks for all hunks in buffers,
--     both normal and staged.
--   - When extmark is created, `opt.sign_text` and `opt.sign_hl_group` specify if/how
--     extmark is added to `signcolumn`, i.e. `%s`.
-- - Get extmark:
--   - `vim.api.nvim_buf_get_extmarks(0, <namespace>, 0, -1, { details = true })`
--   - Returns: List of `[ extmarkid, row, col, details ]` tuples, in traversal order.
--
-- ==================================
local M = {}

local colors =
  { "#caa6f7", "#c1a6f1", "#b9a5ea", "#b1a4e4", "#aba3dc", "#a5a2d4", "#9fa0cc", "#9b9ec4", "#979cbc", "#949ab3" }

function M.set_hl()
  -- Thick line, i.e. background filled.
  vim.api.nvim_set_hl(0, "StatusColumnBorder", { fg = "#ff9e64", bg = "#ff9e64" })

  for i, color in ipairs(colors) do
    vim.api.nvim_set_hl(0, "Gradient_" .. i, { fg = color })
  end
end

function M.number(user_config)
  local text = ""

  -- Merge default options with user options.
  local config = vim.tbl_extend("keep", user_config or {}, {
    -- Pass in `user_config.colors` if needed.
    colors = nil,
    mode = "normal",
  })

  if config.colors ~= nil and vim.islist(config.colors) == true then
    for rel_num, _ in ipairs(config.colors) do
      -- Avoid all lines using undefined highlight group, i.e. large number.
      -- Relative lines further out than 10 still has undefined.
      if (vim.v.relnum + 1) == rel_num then
        text = "%#" .. "Gradient_" .. (vim.v.relnum + 1) .. "#"
        break
      end
    end

    -- If string is still empty, i.e. when `relnum` was higher than `#config.colors`,
    -- use last color, thus yielding gradient effect.
    if text == "" then
      text = "%#" .. "Gradient_" .. #config.colors .. "#"
    end
  end

  if config.mode == "normal" then
    text = text .. "%=" .. vim.v.lnum
  elseif config.mode == "relative" then
    text = text .. "%=" .. vim.v.relnum
  elseif config.mode == "hybrid" then
    -- return vim.v.relnum == 0 and text .. "%=" .. vim.v.lnum or text .. "%=" .. vim.v.relnum
    -- Use new `statuscolumn` item instead of composing with `[l|r]num` and `"%="`, to avoid layout shift.
    return text .. "%l"
  end
end

function M.border(user_config)
  local text = ""

  -- Merge default options with user options.
  local config = vim.tbl_extend("keep", user_config or {}, {
    colors = nil,
    mode = "normal",
  })

  -- For line close to current line, use gradient up to final color,
  -- then for lines further out use last color, for gradient appearance.
  if config.colors ~= nil then
    if vim.v.relnum <= 9 then
      -- NOTE: Lua tables start at 1, but relnum starts at 0, so add 1 to get highlight group.
      text = "%#Gradient_" .. (vim.v.relnum + 1) .. "#"
    else
      text = "%#Gradient_10#"
    end
  end

  return text .. "│"
end

M.folds = function()
  -- Foldlevel of fold, if any, at current line, deepest level if nested.
  -- `0` if no fold at current line.
  local foldlevel = vim.fn.foldlevel(vim.v.lnum)

  -- Foldlevel of fold, if any, at line directly above current line.
  -- If smaller than current line's foldlevel, current line is first line of fold, potentially nested.
  local foldlevel_before = vim.fn.foldlevel((vim.v.lnum - 1) >= 1 and vim.v.lnum - 1 or 1)

  -- Foldlevel of fold, if any, at line directly below current line.
  -- If smaller than current line's foldlevel, current line is last line of fold, potentially nested.
  local foldlevel_after =
    vim.fn.foldlevel((vim.v.lnum + 1) <= vim.fn.line("$") and (vim.v.lnum + 1) or vim.fn.line("$"))

  -- Line number of first line of closed fold if line is part of fold, otherwise `-1`.
  local foldclosed = vim.fn.foldclosed(vim.v.lnum)

  -- Line not in fold, thus skip return whitespace to put in statuscolumn.
  if foldlevel == 0 then
    return "     "
  end

  -- Line is on closed fold, second condition might be unnecessary.
  if foldclosed ~= -1 and foldclosed == vim.v.lnum then
    -- return "▶"
    return "%#LazygitActiveBorderColor#   %#StatusColumnBorder#│"
  end

  -- Not using `~=`, as nested fold would not be able to have lower level than parent fold.
  if foldlevel > foldlevel_before then
    -- return "▽"
    return "    "
    -- return " "
  end

  -- Line is last line of fold, potentially nested.
  if foldlevel > foldlevel_after then
    -- return "╰"
    return "     "
  end

  -- Line is in middle of open fold.
  -- return "╎"
  return "     "
end

function M.gitsigns()
  local text = "  "
  local namespaces = vim.api.nvim_get_namespaces()
  local gitsigns_signs_ = namespaces["gitsigns_signs_"]
  local gitsigns_signs_staged = namespaces["gitsigns_signs_staged"]
  local gitsigns_removed = namespaces["gitsigns_removed"]

  local extmarks_normal = vim.api.nvim_buf_get_extmarks(0, gitsigns_signs_, 0, -1, { details = true })
  local extmarks_staged = vim.api.nvim_buf_get_extmarks(0, gitsigns_signs_staged, 0, -1, { details = true })
  local extmarks_removed = vim.api.nvim_buf_get_extmarks(0, gitsigns_removed, 0, -1, { details = true })

  -- Normal, i.e. unstaged changes, including: Add, change, delete.
  for _, extmark in ipairs(extmarks_normal) do
    -- Lua tables are 1-indexed.
    -- `extmark[2]` holds row number, but 0-indexed, so add `1`.
    if extmark[2] + 1 == vim.v.lnum then
      text = "%#" .. extmark[4].sign_hl_group .. "#" .. extmark[4].sign_text .. "%*"
    end
  end

  -- Normal, i.e. staged changes, including: Add, change, delete.
  for _, extmark in ipairs(extmarks_staged) do
    if extmark[2] + 1 == vim.v.lnum then
      text = "%#" .. extmark[4].sign_hl_group .. "#" .. extmark[4].sign_text .. "%*"
    end
  end

  -- Removals, whatever that is.
  for _, extmark in ipairs(extmarks_removed) do
    if extmark[2] + 1 == vim.v.lnum then
      text = "%#" .. extmark[4].sign_hl_group .. "#" .. extmark[4].sign_text .. "%*"
    end
  end

  return text
end

-- Diagnostic -and todo signs.
function M.customsigns()
  local text = "    "
  local namespaces = vim.api.nvim_get_namespaces()
  local diagnostic_signs = nil
  for ns_name, ns_number in pairs(namespaces) do
    if ns_name:match("diagnostic%.signs$") then
      diagnostic_signs = ns_number
    end
  end

  local todo_signs = namespaces["todo-signs"]

  if todo_signs ~= nil then
    local extmarks_todo_signs = vim.api.nvim_buf_get_extmarks(0, todo_signs, 0, -1, { details = true })

    for _, extmark in ipairs(extmarks_todo_signs) do
      if extmark[2] + 1 == vim.v.lnum then
        text = " %#" .. extmark[4].sign_hl_group .. "#" .. extmark[4].sign_text .. "%* "
      end
    end
  end

  -- Diagnostic signs overwrite todo signs.
  if diagnostic_signs ~= nil then
    local extmarks_diagnostic_signs = vim.api.nvim_buf_get_extmarks(0, diagnostic_signs, 0, -1, { details = true })

    -- Sort diagnostic extmarks by priority, so e.g. error is sorted after warning.
    table.sort(extmarks_diagnostic_signs, function(ta, tb)
      return ta[4].priority < tb[4].priority
    end)

    for _, extmark in ipairs(extmarks_diagnostic_signs) do
      local extmark_lnum = extmark[2] + 1
      if extmark_lnum == vim.v.lnum then
        text = " %#" .. extmark[4].sign_hl_group .. "#" .. extmark[4].sign_text .. "%* "
      end
    end
  end

  return text
end

function M.get()
  -- Setup highlight groups.
  M.set_hl()

  local text = ""

  -- 0 is namespace, which is default namespace.
  vim.api.nvim_set_hl(0, "MyStatusColumn", {
    fg = "#FFFFFF",
    bg = "#1E1E2E",
  })

  vim.api.nvim_set_hl(0, "MyStatusColumnBorder", {
    -- When `link` is present, other keys are ignored.
    link = "LineNr",
  })

  text = table.concat({
    M.gitsigns(),
    M.customsigns(),
    M.number({ mode = "hybrid" }),
    M.border(),
    M.folds(),
  })

  -- To compare with built-in signcolumn, include `%s`.
  -- return "%C%s%l│" .. text
  return text
end

return M
