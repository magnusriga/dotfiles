local M = {}

---@type MyKeysLspSpec[]|nil
M._keys = nil

---@alias MyKeysLspSpec MyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias MyKeysLsp MyKeys|{has?:string|string[], cond?:fun():boolean}

---@return MyKeysLspSpec[]
function M.get()
  if M._keys then
    return M._keys
  end
    -- stylua: ignore
    M._keys =  {
      { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
      { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
      { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
      { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
      { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
      { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      { "<leader>cA", MyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
        desc = "Prev. Reference", cond = function() return Snacks.words.is_enabled() end },
      { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
        desc = "Prev. Reference", cond = function() return Snacks.words.is_enabled() end },
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
    if client.supports_method(method) then
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
  local opts = MyVim.opts("nvim-lspconfig")
  local clients = MyVim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

-- Uses `keymaps` table containing all keymaps above and all those defined in `nvim-lspconfig` for attached server,
-- i.e. `opts.servers[<client>].keys`,
-- where each element contains `keys` table with fields `lhs`, `rhs`, `mode` (default to `n`), `id`,
-- and all other fields from each keymap spec above, e.g. `cond`, `has`, etc.
-- then checks if any attached client supports the `has` method, e.g. `textDocument/codeLens`,
-- and if `cond` returns `true`.
-- If so, save all fields on keymaps above into new `opts`, keeping only those fields whose key is not a number,
-- and skipping `{ mode = true, id = true, ft = true, rhs = true, lhs = true }`,
-- then create keymap passing in `opts`, with current buffer added to `opts`,
-- and `opts.mode` defaulting to `n`.
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
