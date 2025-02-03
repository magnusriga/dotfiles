-- ==================================
-- NOTES
-- ==================================
-- ----------------------------------
-- `foldtext`.
-- ----------------------------------
-- - `foldtext` can be set to string, in which case highlight group `Folded` is used.
-- - `foldtext` can be set to list-style table, mapping words to highlight groups,
--   but cannot have keys, with following format:
--   `{
--      { "function", "LazygitActiveBorderColor" },
--      { " ", "Folded" },
--      { "foo", "@variable" },
--      ..
--    }`.
-- - Thus, `foldtext` function should return table with highlight groups from treesitter.
-- - Remember: Include spaces in final table, which can be set to random highlight group, e.g. `Folded`.
-- - Do not `vim.print` anything in these functions, it will end up in statuscolumn, indent, etc.
--
-- ----------------------------------
-- Lua API.
-- ----------------------------------
-- - `nvim_buf_get_lines(<buf>, <start>, <end>, <strict_indexing>)`:
--   - Returns array of lines.
--   - `start` | `end`: Zero-indexed, end-exclusive.
--   - `0` means first line, `-1` means index after last line.
--   - `strict_indexing`: Whether out-of-bounds should be error.
--
-- ----------------------------------
-- Treesitter: `TSTree`, `TSNode`.
-- ----------------------------------
-- - TSTree.
--   - Syntax tree of an entire source code file.
--   - Contains `TSNode` instances indicating structure of source code.
-- - TSNode.
--   - Single node in syntax tree.
--   - Tracks start and end position in source code, and relation to parent and child TSNodes.
--
-- - `TSTree`, and its containing `TSNode`s, are userdata objects stored in memory,
--   there is no direct Lua table representation of these, thus they are not printable.
--
-- - Enable treesitter highlighting for current file: `vim.treesitter.start()`.
--
-- ----------------------------------
-- Treesitter: `LanguageTree`.
-- ----------------------------------
-- `LanguageTree` contains tree of parsers:
-- - Root treesitter parser for `lang`
-- - Any "injected" language parsers, which themselves may inject other languages, recursively.
-- - TSTree, like TSNode, is only represented in memory, not printable in Lua.
--
-- - `LanguageTree:parse(range, ..)`:
--   - Always parses root of language tree, as well as lines given by passed in range,
--     thus returned TSTree contains root TSNode of buffer, and TSNodes of parsed lines.
--   - Returns table of TSTree objects, because multiple languages could have created sub-trees.
--
-- ----------------------------------
-- Treesitter: `Query`.
-- ----------------------------------
-- - Queries are files in runtimepath.
-- - Example: `~/.local/share/nvim/lazy/nvim-treesitter/queries/lua/highlights.scm`.
-- - First query file found in runtimepath for given language is used,
-- - Additional query files in other runtimepaths, with `;extends` query modeline
--   on top of query file, will extend first found query file.
-- - `highlights.scm` often found in both:
--   - `lazy/nvim-treesitter/queries/...`.
--   - `lazy/<colorscheme>/queries/lua/...`.
-- - Query file maps patterns of TSNodes, from TSTree, to "captures",
--   i.e. mapping TSNode `for`, inside TSNode `for_statement`, to capture `@keyword.repeat`.
-- - Queries are used for e.g. highlights, where each capture is a highlight group in Neovim,
--   thus each queery maps one or more TSNode to one highlight group.
-- - Example: `queries/lua/highlights.scm`.
--   ; Keywords
--   "return" @keyword.return
--
--   [
--     "goto"
--     "in"
--     "local"
--   ] @keyword
--
--   (for_statement
--     [
--       "for"
--       "do"
--       "end"
--     ] @keyword.repeat)
--
-- ----------------------------------
-- Captures and highlights.
-- ----------------------------------
-- - Capture names are prefixed with `@`, and are directly usable as highlight groups,
--   defined by Nvim's standard highlight-groups, and colorschemes,
-- - Example: `@comment` links to highlight group `Comment` in Nvim's standard highlight-groups.
-- - Capture falls back to first part of capture, if highlight group does not exits,
--   e.g. `@comment.documentation` falls back to `@comment`, thus making it possible to
--   use built in highlight groups, but add more specific ones if needed.
-- - To separate highlight groups per language, so one capture can map to different
--   highlight groups depending on language, highlight groups are suffixed with `.<lang>`,
--   e.g. capture `@comment` first maps to highlight group `@comment.lua` in Lua files,
--   and then to `@comment` if `@comment.lua` not found.
--
-- - Treesitter uses `nvim_buf_set_extmark()` to set highlights, with default priority 100,
--   which enables plugins to set highlighting priority lower or higher than treesitter.
-- - Change priority of query pattern by setting its `priority` metadata attribute:
--   `((super_important_node) @superimportant (#set! priority 105))`.
--
-- - Standard "captures": `:h treesitter-highlight-groups`.
-- - Captures, and thus highlight groups, prefixed with `@odp`, e.g. `@odp.class`, come from:
--   `~/.local/share/nvim/lazy/onedarkpro.nvim/after/queries/lua/highlights.scm`.
--
-- ----------------------------------
-- `Query:iter_captures`.
-- ----------------------------------
-- - `TSTree:root()`: Root TSNode of TSTree, latter which always includes root node from buffer.
-- - Start | stop: Limit matches
-- - Loop through all captures from all matches in given TSNode,
--   where "match" means when pattern of query matches node.
-- - Each node, e.g. `local`, could match several query patterns.
-- - Each "match" maps node to captures, thus there are as many captures per node as there
--   are pattern-matches for that node.
-- - TSNode may have child TSNode(s).
-- - Queries can also use quantifiers to map multiple nodes to capture,
--   often used with predicates where predicate filters down matched nodes.
-- - Thus, one match could map multiple nodes to same capture,
--   and one node could have multiple matches, i.e. map to multiple captures.
-- - Thus, must loop through all matches, i.e. all captures from match, then for each match,
--   i.e. each capture, loop through all nodes which that "match" covers,
--   in one match uses quantifier and thus includes several nodes.
-- - Thus, in `Query:iter_matches`, three loop levels:
--   - Loop through match in matches > loop through set of nodes in each match >
--     loop through node in nodes.
--   - Thus, three nested loops.
-- - Alternatively, iterate over each node-capture pair, for all nodes,
--   directly with `Query:iter_captures`, skipping nested loops.
--   - Each node may occur multiple times in list, mapping same node to different captures,
--     i.e. when node has several query matches,
--     and each capture name may occur multiple times in list, mapping multiple nodes to same capture,
--     e.g. when multiple nodes map to `@keywords` capture.
--   - In `h Query:iter_captures`, "captures" refers to each node-to-capture-group pair,
--     not each capture group, i.e. not each `@keyword`.
--   - `id`: Similar to capture group, repeated multiple times in `iter_captures`,
--     once per mapping to one capture group, thus if several nodes match capture group `@variable`,
--     then same `id` occurs once per such match.
--
-- - One node may have several matches, i.e. there might be several entries
--   in `Query:iter_captures` with same node, e.g. TSNode with name `iter_captures` has two query matches,
--   i.e. two captures:
--   - `variable`.
--   - `function.method.call`.
-- - Ignore capture if current node, and node directly preceding current node, are same,
--   otherwise e.g. last comma in line, when line contains more than one comma, is lost.
-- - When multiple highlights have same priority, last one should be used.
-- ==================================

---@class lazyvim.util.ui
local M = {}

-- Optimized treesitter `foldexpr`.
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- If no filetype, do not check if treesitter is available,
    -- as it is not.
    if vim.bo[buf].filetype == "" then
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

---@param foldtext table<number, table<string, string>>
---@param highlight_add string
---@param highlight_sep? string
function M.foldtext_add(foldtext, highlight_add, highlight_sep)
  local foldtext_as_string = ""
  for _, foldtext_part in ipairs(foldtext) do
    foldtext_as_string = foldtext_as_string .. foldtext_part[1]
  end

  local folded_line_count = vim.v.foldend - vim.v.foldstart + 1
  local sep = vim.fn["repeat"]("-", vim.fn.winwidth(0) - foldtext_as_string:len() - 31)
  local text = "  (length " .. folded_line_count .. ")"
  local ret = {
    { "  ", highlight_sep or "Folded" },
    { sep, highlight_sep or "FoldedSep" },
    { text, highlight_add },
  }

  return ret
end

function M.foldtext()
  -- Line number of first line of fold when fold is created,
  -- i.e. when `opt.foldtext` is evaluated.
  local pos = vim.v.foldstart

  -- String of first line of fold.
  local line = vim.api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]

  -- Get language of current buffer.
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)

  -- Create `LanguageTree`, i.e. parser object, for current buffer filetype.
  local parser = vim.treesitter.get_parser(0, lang)

  if parser == nil then
    return vim.fn.foldtext()
  end

  -- Get `highlights` query for current buffer parser, as table from file,
  -- which gives information on highlights of tree nodes produced by parser.
  local query = vim.treesitter.query.get(parser:lang(), "highlights")

  if query == nil then
    return vim.fn.foldtext()
  end

  -- Partial TSTree for buffer, including root TSNode, and TSNodes of folded line.
  -- PERF: Only parsing needed range, as parsing whole file would be slower.
  local tree = parser:parse({ pos - 1, pos })[1]

  local result = {}
  local line_pos = 0
  local prev_range = { 0, 0 }

  -- Loop through matched "captures", i.e. node-to-capture-group pairs,
  -- for each TSNode in given range.
  -- Each TSNode could occur several times in list, i.e. map to several capture groups,
  -- and each capture group could be used by several TSNodes.
  for id, node, _ in query:iter_captures(tree:root(), 0, pos - 1, pos) do
    -- Name of capture group from query, for current capture.
    local name = query.captures[id]

    -- Text of captured node.
    local text = vim.treesitter.get_node_text(node, 0)

    -- Range, i.e. lines in source file, captured TSNode spans, where row is first line of fold.
    local start_row, start_col, end_row, end_col = node:range()

    -- Include part of folded line between captured TSNodes, i.e. whitespace,
    -- with arbitrary highlight group, e.g. "Folded", in final `foldtext`.
    if start_col > line_pos then
      table.insert(result, { line:sub(line_pos + 1, start_col), "Folded" })
    end

    -- For control flow analysis, break if TSNode does not have proper range.
    if end_col == nil or start_col == nil then
      break
    end

    -- Move `line_pos` to end column of current node,
    -- thus ensuring next loop iteration includes whitespace between TSNodes.
    line_pos = end_col

    -- Save source code range current TSNode spans, so current TSNode can be ignored if
    -- next capture is for TSNode covering same section of source code.
    local range = { start_col, end_col }

    -- Use language specific highlight, if it exists.
    local highlight = "@" .. name
    local highlight_lang = highlight .. "." .. lang
    if vim.fn.hlexists(highlight_lang) then
      highlight = highlight_lang
    end

    -- Insert TSNode text itself, with highlight group from treesitter.
    if range[1] == prev_range[1] and range[2] == prev_range[2] then
      -- Overwrite previous capture, as it was for same range from source code.
      result[#result] = { text, highlight }
    else
      -- Insert capture for TSNode covering new range of source code.
      table.insert(result, { text, highlight })
      prev_range = range
    end
  end

  local add = M.foldtext_add(result, "@keyword")
  for _, v in ipairs(add) do
    table.insert(result, v)
  end

  return result
end

return M
