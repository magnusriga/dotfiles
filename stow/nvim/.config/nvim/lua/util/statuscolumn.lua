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
-- Folds:
-- - `lnum`.
--   - Represents current line.
--   - `vim.v.lnum`: Line number of current line, when used in `opt.statuscolum` | `opt.foldexpr`
--     and others, see: `:h v:lnum`, empty when not in one of those expressions.
--   - `vim.fn.getline()`: Generally get line number when not in one of above expressions.
--     - `.`: Current line.
--     - `m`: Mark "m".
--
-- - `foldclosed({lnum})`.
--   - Line number of first line in closed fold, if line `lnum` is part of closed fold.
--   - `foldclosed({lnum})`: Line number of last line in closed fold.
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
-- ==================================
local M = {}

local colors =
  { "#caa6f7", "#c1a6f1", "#b9a5ea", "#b1a4e4", "#aba3dc", "#a5a2d4", "#9fa0cc", "#9b9ec4", "#979cbc", "#949ab3" }

M.set_hl = function()
  for i, color in ipairs(colors) do
    vim.api.nvim_set_hl(0, "Gradient_" .. i, { fg = color })
  end
end

-- On current line, border is pushed to right,
-- as relative number is larger than relative number.
M.border = function()
  -- For line close to current line, use gradient up to final color,
  -- then for lines further out use last color,
  -- which gives gradient appearance across entire border.
  if vim.v.relnum <= 9 then
    -- NOTE: Lua tables start at 1, but relnum starts at 0, so add 1 to get highlight group.
    local hl = "%#Gradient_" .. (vim.v.relnum + 1) .. "#│"
    return hl
    -- return "%#LazygitActiveBorderColor#│"
  else
    return "%#Gradient_10#│"
  end
  -- return "%#MyStatusColumnBorder#│"
end

function M.number(user_config)
  -- - `[l|r]num`: Evaluated for every line, when used in e.g. `foldexpr`.
  -- - `vim.v.lnum`:
  --   - Read-only line number.
  --   - Available while `foldexpr`, and some other functions, are evaluated, i.e. in sandbox.
  -- - `vim.v.relnum`:
  --   - Same as `lnum`, but for relative number to current cursor line.
  -- - `%l`: Evaluates to line number inside `opt.statuscolumn`.
  -- - `%r`: Same as `%l`, but for relative line number.

  local text = ""

  -- Merge default options with user options.
  local config = vim.tbl_extend("keep", user_config or {}, {
    colors = colors,
    mode = "normal",
  })

  if config.colors ~= nil and vim.islist(config.colors) == true then
    for rel_num, hl in ipairs(config.colors) do
      -- Assign one highlight group to each line,
      -- avoiding all using an undefined highlight group, i.e. large number.
      -- Relative lines further out than 10 still has undefined.
      if (vim.v.relnum + 1) == rel_num then
        text = "%#" .. "Gradient_" .. (vim.v.relnum + 1) .. "#"
        break
      end
    end

    -- if vim.v.relnum <= 9 then
    --   -- NOTE: Lua tables start at 1, but relnum starts at 0, so add 1 to get highlight group.
    --   -- return "%#LazygitActiveBorderColor#│"
    -- else
    --       text = "%#" .. "Gradient_10" .. "#"
    -- end

    -- If string is still empty, i.e. when `relnum` was higher than `#config.colors`,
    -- use last color, thus yielding gradient effect.
    if text == "" then
      text = "%#" .. "Gradient_" .. #config.colors .. "#"
    end
  end

  if config.mode == "normal" then
    text = text .. vim.v.lnum
  elseif config.mode == "relative" then
    text = text .. vim.v.relnum
  elseif config.mode == "hybrid" then
    -- If relative number for line is 0, cursor is on that line,
    -- thus show line number instead of relative line number.
    return vim.v.relnum == 0 and text .. vim.v.lnum or text .. vim.v.relnum
  end
end

function M.get()
  -- Setup highlight groups.
  M.set_hl()

  local text = ""

  -- 0 is namespace, which is default namespace.
  vim.api.nvim_set_hl(0, "MyStatusColumn", {
    -- When `link` is present, other keys are ignored.
    link = "Comment",
    --fg = "#FFFFFF",
    --bg = "#1E1E2E",
  })

  vim.api.nvim_set_hl(0, "MyStatusColumnBorder", {
    -- When `link` is present, other keys are ignored.
    link = "LineNr",
    -- fg = "#CBA6F7",
  })

  -- Alternative: `text = text .. M.brorder`.
  text = table.concat({
    M.number({ mode = "hybrid" }),
    M.border(),
  })

  return text
end

M.folds = function()
  local foldlevel = vim.fn.foldlevel(vim.v.lnum)
  local foldlevel_before = vim.fn.foldlevel((vim.v.lnum - 1) >= 1 and vim.v.lnum - 1 or 1)
  local foldlevel_after =
    vim.fn.foldlevel((vim.v.lnum + 1) <= vim.fn.line("$") and (vim.v.lnum + 1) or vim.fn.line("$"))

  local foldclosed = vim.fn.foldclosed(vim.v.lnum)

  -- Line has nothing to do with folds so we will skip it
  if foldlevel == 0 then
    return " "
  end

  -- Line is a closed fold(I know second condition feels unnecessary but I will still add it)
  if foldclosed ~= -1 and foldclosed == vim.v.lnum then
    return "▶"
  end

  -- I didn't use ~= because it couldn't make a nested fold have a lower level than it's parent fold and it's not something I would use
  if foldlevel > foldlevel_before then
    return "▽"
  end

  -- The line is the last line in the fold
  if foldlevel > foldlevel_after then
    return "╰"
  end

  -- Line is in the middle of an open fold
  return "╎"
end

return M
