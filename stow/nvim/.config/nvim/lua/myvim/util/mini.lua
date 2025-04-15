---@class myvim.util.mini
local M = {}

-- Taken from MiniExtra.gen_ai_spec.buffer.
function M.ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject.
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks.
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- Register all text objects with which-key.
---@param opts table
function M.ai_whichkey(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }

  ---@type wk.Spec[]
  local ret = { mode = { "o", "x" } }

  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})

  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end

  require("which-key").add(ret, { notify = false })
end

---@param opts {skip_next: string, skip_ts: string[], skip_unbalanced: boolean, markdown: boolean}
function M.pairs(opts)
  -- Keybinding to toggle on|off `mini.pairs`,
  -- whose state is stored in: `vim.g.miniparis_disable`.
  Snacks.toggle({
    name = "Mini Pairs",
    get = function()
      return not vim.g.minipairs_disable
    end,
    set = function(state)
      vim.g.minipairs_disable = not state
    end,
  }):map("<leader>up")

  -- - Execute `require("mini.pairs").setup(opts)`, which loads `mini.pairs` plugin.
  -- - This function, i.e. `M.pairs`, which loads `mini.pairs` plugin,
  --   is called from `mini.pairs` spec, in `plugins/coding.lua`,
  --   where `opts` for `mini.pairs` is defined.
  local pairs = require("mini.pairs")
  pairs.setup(opts)

  -- Store original `pairs.open`.
  local open = pairs.open

  -- Overwrite `pairs.open` with own implementation,
  -- to deal with edge cases defined in:
  -- `plugins/coding.lua` > `mini.pairs` spec.

  pairs.open = function(pair, neigh_pattern)
    -- If autopairs on command line, follow built-in behavior.
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end

    -- `o`: Opening bracket|quote.
    -- `c`: Closing bracket|quote.
    local o, c = pair:sub(1, 1), pair:sub(2, 2)

    -- Get current line, where closing bracket|quote is being inserted.
    local line = vim.api.nvim_get_current_line()

    -- Gets (1,0)-indexed, buffer-relative cursor position, for current window.
    -- Returns: `(row, col)` tuple.
    local cursor = vim.api.nvim_win_get_cursor(0)

    -- `next`: Single character after pair, on line pair is being inserted in.
    -- `before`: All characters before pair, on line pair is being inserted in.
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])

    -- Better deal with markdown code blocks.
    -- If opening pair is ` in markdown file,
    -- and pair is added at start of line, not counting whitespace,
    -- and `` already appears right before pair,
    -- then add newline before pair, and move cursor back up one line.
    -- `%s`: All space characters.
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end

    -- Skip autopair when single next character is one of characters defined in
    -- `plugins/coding.lua` > `mini.pairs` spec `opts`.
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
      return o
    end

    -- Skip autopair when cursor is inside `string` treesitter nodes.
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end

    -- Skip autopair when next character is closing pair
    -- and there are more closing pairs than opening pairs.
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then
        return o
      end
    end
    return open(pair, neigh_pattern)
  end
end

return M
