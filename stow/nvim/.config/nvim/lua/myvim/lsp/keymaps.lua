local M = {}

---@type MyKeysLspSpec[]|nil
M._keys = nil

---@alias MyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias MyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

---@return MyKeysLspSpec[]
function M.get()
  if M._keys then
    return M._keys
  end
    -- stylua: ignore
    M._keys =  {
      -- { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },

      ---------------------------------------------
      -- Built-in `gr<x>` commands, see: `:h vim-diff`, `:h lsp`.
      ---------------------------------------------
      -- - Normal mode:
      -- - `grn` : `vim.lsp.buf.rename()`
      -- - `gra` : `vim.lsp.buf.code_action()`, Normal | Visual mode.
      -- - `grr` : `vim.lsp.buf.references()`.
      -- - `gri` : `vim.lsp.buf.implementation()`.
      -- - `gO`  : `vim.lsp.buf.document_symbol()`.
      -- - `gq`  : Calls function in `opt.formatexpr()`, initially set to `vim.lsp.formatexpr()` by Neovim,
      --           but remapped to `util/format.lua` > `format()`.
      -- - CTRL-]: `vim.lsp.tagfunc()` > `textdocument/definition` < `vim.lsp.buf.defitition`.
      -- - `K`   : `vim.lsp.buf.hover()`.
      --
      -- - Insert mode:
      -- - CTRL-S: `vim.lsp.buf.signature_help()`.
      --
      -- Therefore, below shortcuts not needed, but built-ins are overwritten in `plugins/fzf.lua`
      -- to open `fzf-lua` picker if multiple results, e.g. mutliple references.

      -- { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
      -- { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
      -- { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
      -- { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
      -- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      -- { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
      -- { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
      -- { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      --
      -- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      ---------------------------------------------

    -- Same as built-in K, but with border around hover window.
    { "K", function() vim.lsp.buf.hover({ border = "single" }) end, desc = "Hover" },

      ---------------------------------------------
      -- Code actions.
      ---------------------------------------------
      -- Opens `vim.ui.select` to choose code action, overwritten in `plugins/fzf.lua` to use `fzf-lua`.
      -- No need, use built-in `gra`, which still uses `fzf-lua` picker, since `vim.ui.select` is replaced.
      -- { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },

      -- Apply code action if only one choice, see: `vim.lsp.buf.code_action()`.
      -- No need, add new `gra` in `fzf-lua` if needed.
      -- { "<leader>ca", function() vim.lsp.buf.code_action({ apply = true }) end, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },

      -- Show list of code actions available at current cursor position, including only
      -- those that apply to entire source file, i.e. entire buffer.
      -- No need, use normal code actions menu.
      -- { "<leader>cA", MyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },

      ---------------------------------------------
      -- Codelens shows information and|or links, next to code.
      ---------------------------------------------
      -- - Codelens information:
      --  - References to piece of code, e.g. functions.
      --  - Changes to piece of code.
      --  - Linked bugs.
      --  - Azure DevOps work items
      --  - Code reviews.
      --  - Linked unit tests.

      -- Get codelenses from language server, and show in buffer.
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },

      -- Run codelens under cursor, i.e. when link to other code, e.g. unit tests.
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },

      ---------------------------------------------
      -- Renaming.
      ---------------------------------------------
      -- Rename file and update references.
      -- Keep, as built-in `grn` only renames source code, not files.
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },

      ---------------------------------------------
      -- `Snacks.words`.
      ---------------------------------------------
      -- - `vim.lsp.buf.document_highlight()`: Adds extmarks AND highlights for all symbols
      --   matching word under cursor, in current file only.
      -- - Symbols are defined by language, so e.g. cursor on `then` will highlight `if` and `end`.
      -- - `vim.lsp.buf.clear_references()`: Removes BOTH extmarks AND highlights for all symbols
      --   matching word under cursor, in current file.
      -- - `Snacks.words.enable()`: Schedules `vim.lsp.buf.document_highlight()` to run
      --   on `CursorMoved` | `CursorMovedI` | `ModeChanged`,
      --   debounced to not run more often than every 200 ms, immediately followed by `vim.lsp.buf.clear_references()`.
      -- - Result: `Snacks.words` highlight references within same file automatically when cursor moves,
      --   via `vim.lsp.buf.document_highlight()`,
      --   and allows jumping to those references using key bindings mapping to `Snacks.words.jump(<count>, [<cycle>])`.
      -- - `config.notify_jump` is `false` by default, set to `true` to run `vim.notify` at jump.
      --
      -- - `Snacks.words` is disabled by default, enable with: `Snacks.words.enable()`.
      -- - No need, interferes with built-in, e.g. `[[`:  N sections backwards.
      -- { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
      --   desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      -- { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
      --   desc = "Prev. Reference", cond = function() return Snacks.words.is_enabled() end },
      -- { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
      --   desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      -- { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
      --  desc = "Prev. Reference", cond = function() return Snacks.words.is_enabled() end },
    }

  return M._keys
end

---@param method string|string[]
function M.has(buffer, method)
  if type(method) == "table" then
    for _, m in ipairs(method) do
      if M.has(buffer, m) then
        return true
      end
    end
    return false
  end
  method = method:find("/") and method or "textDocument/" .. method
  local clients = MyVim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client:supports_method(method) then
      return true
    end
  end
  return false
end

-- Combines above keymaps with those defined in `nvim-lspconfig` plugin's `opts.servers[<client>].keys`,
-- for each LSP client attached to given buffer,
-- then returns table with fields `lhs`, `rhs`, `mode` (default to `n`), `id`,
-- and all other fields from each keymap spec above, e.g. `cond`, `has`, etc.
---@return MyKeysLsp[]
function M.resolve(buffer)
  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    return {}
  end
  local spec = vim.tbl_extend("force", {}, M.get())
  -- local opts = MyVim.opts("nvim-lspconfig")
  local clients = MyVim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    -- local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    local maps = {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

-- Uses `keymaps` table containing all keymaps above and all those defined in `nvim-lspconfig` for attached server,
-- i.e. `opts.servers[<client>].keys`,
-- where each element contains `keys` table with fields `lhs`, `rhs`, `mode` (default to `n`), `id`,
-- and all other fields from each keymap spec above, e.g. `cond`, `has`, etc.
-- Checks if any attached client supports `has` method, e.g. `textDocument/codeLens`,
-- and if `cond` returns `true`.
-- If so, create keymap with relevant fields from above,
-- as well as default `opts` for new keymaps from `lazy.core.handler.keys`.
function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = M.resolve(buffer)

  for _, keys in pairs(keymaps) do
    local has = not keys.has or M.has(buffer, keys.has)
    local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

    if has and cond then
      local opts = Keys.opts(keys)
      opts.cond = nil
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

return M
