---@class myvim.util.lsp
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: vim.lsp.Client):boolean}

---@param opts? lsp.Client.filter
function M.get_clients(opts)
  local ret = {} ---@type vim.lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ret = vim.lsp.get_clients(opts)
    if opts and opts.method then
      ---@param client vim.lsp.Client
      ret = vim.tbl_filter(function(client)
        return client:supports_method(opts.method, opts.bufnr)
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

-- Create autocmd that executes `on_attach(client, buffer)` callback,
-- when LSP client `client` attaches to buffer `buffer`.
---@param on_attach fun(client:vim.lsp.Client, buffer)
---@param name? string
function M.on_attach(on_attach, name)
  return vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
end

-- `_supports_method` example:
-- {
--   "textDocument/inlayHints" = {
--     eslintClient = { 1 = true, 2 = false, 5 = true }
--   }
-- }

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M._supports_method = {}

-- Overwrite handler function, which runs when registering new capability on LSP client,
-- with new function that registers capability on client,
-- and then runs autocmd `LspDyncamicCapability` for every buffer which that client is attached to,
-- with `client.id` and `buffer` passed in.
--
-- It also adds new autocmd which runs when LSP `client` *first* attaches to `buffer`,
-- which executes some function and method previously registered via `on_support_method`,
-- if client supports given method for buffer being attached to.
--
-- Specifically, for every methond in `_supports_method`,
-- if method does not already have entry for attaching client and buffer,
-- or it has entry stating that client does *not* support method for buffer,
-- then check if client supports current method for given buffer with `client.supports_method(method, { buffer })`,
-- and if client indeed supports method, then set `_supports_method.method.client.buffer = true`,
-- and execute `LspSupportsMethod` autocmd with `client.id`, `buffer`, `method`,
-- which executes a previously added function for specific method given at time of registration.
--
-- Finally, it registers same function and method so it can execute upon `User` autocmd `LspDynamicCapability`,
-- in addition to whenever client attaches to buffer,
-- which is executed whenever client registers new capability.
function M.setup()
  local register_capability = vim.lsp.handlers["client/registerCapability"]
  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    ---@diagnostic disable-next-line: no-unknown
    local ret = register_capability(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      for buffer in pairs(client.attached_buffers) do
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspDynamicCapability",
          data = { client_id = client.id, buffer = buffer },
        })
      end
    end
    return ret
  end
  M.on_attach(M._check_methods)
  M.on_dynamic_capability(M._check_methods)
end

---@param client vim.lsp.Client
function M._check_methods(client, buffer)
  -- Don't trigger `LspSupportsMethod` on invalid buffers.
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  -- Don't trigger `LspSupportsMethod` on non-listed buffers.
  if not vim.bo[buffer].buflisted then
    return
  end
  -- Don't trigger `LspSupportsMethod` on nofile buffers.
  if vim.bo[buffer].buftype == "nofile" then
    return
  end
  for method, clients in pairs(M._supports_method) do
    clients[client] = clients[client] or {}
    if not clients[client][buffer] then
      if client:supports_method(method, buffer) then
        clients[client][buffer] = true
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspSupportsMethod",
          data = { client_id = client.id, buffer = buffer, method = method },
        })
      end
    end
  end
end

---@param fn fun(client:vim.lsp.Client, buffer):boolean?
---@param opts? {group?: integer}
function M.on_dynamic_capability(fn, opts)
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspDynamicCapability",
    group = opts and opts.group or nil,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      if client then
        return fn(client, buffer)
      end
    end,
  })
end

-- Create autocmd executing given `fn(client, buffer)`,
-- for passed in `client` (id) and `buffer` (id),
-- on event `User` and pattern `LspSupportsMethod`.
-- `LspSupportsMethod` is e.g. executed when any client attaches to any buffer,
-- so that `fn(client, buffer)` is executed for every method in `_supports_methods`
-- that matches method passed into this function,
-- but only when client supports the method for given buffer,
-- and only when method entry is first added to `_supports_method` table,
-- i.e. if `LspSupportsMethod` has not run before.
---@param method string
---@param fn fun(client:vim.lsp.Client, buffer)
function M.on_supports_method(method, fn)
  M._supports_method[method] = M._supports_method[method] or setmetatable({}, { __mode = "k" })
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspSupportsMethod",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      if client and method == args.data.method then
        return fn(client, buffer)
      end
    end,
  })
end

function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

---@return {default_config:lspconfig.Config}
function M.get_raw_config(server)
  local ok, ret = pcall(require, "lspconfig.configs." .. server)
  if ok then
    return ret
  end
  return require("lspconfig.server_configurations." .. server)
end

function M.is_enabled(server)
  local c = M.get_config(server)
  return c and c.enabled ~= false
end

---@param server string
---@param cond fun( root_dir, config): boolean
function M.disable(server, cond)
  local util = require("lspconfig.util")
  local def = M.get_config(server)
  ---@diagnostic disable-next-line: undefined-field
  def.document_config.on_new_config = util.add_hook_before(def.document_config.on_new_config, function(config, root_dir)
    if cond(root_dir, config) then
      config.enabled = false
    end
  end)
end

-- Run when registering LSP formatter, from `plugins/lsp/init.lua` to `util/format.lua`.
--
-- Conform formatter registered in `plugins/formatting.lua`, is primary formatter
-- with priority 100.
--
-- LSP formatter registered in `plugins/lsp/init.lua` via `util/lsp.lua`,
-- is also `primary` formatter, but has priority 1, thus it never runs,
-- since only one `primary` formatter is permitted, and one with highest priority is used.
--
-- Certain other LSPs, like `eslint`, register new non-`primary` formatters,
-- with even higher priority, e.g. 200, thus these run first,
-- following which conform using `formatter_by_ft` runs.
-- `eslint`'s formatter just does ESLintFixAll, before prettier runs via conform.
---@param opts? MyFormatter| {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter
  ---@cast filter lsp.Client.filter
  ---@type MyFormatter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format(MyVim.merge({}, filter, { bufnr = buf }))
    end,
    -- `sources` is table containing name of every LSP client attached to buffer trying to run `util/format.lua > format()`,
    -- assuming LSP client has `formatting` | `rangeFormatting` capabilities.
    -- All attached LSP clients with those capabilities are used for formatting,
    -- run by `conform.nvim` or built-in `vim.lsp.buf.format` if `conform.nvim` not installed.
    sources = function(buf)
      local clients = M.get_clients(MyVim.merge({}, filter, { bufnr = buf }))
      ---@param client vim.lsp.Client
      local ret = vim.tbl_filter(function(client)
        return client:supports_method("textDocument/formatting")
          or client:supports_method("textDocument/rangeFormatting")
      end, clients)
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  }
  return MyVim.merge(ret, opts) --[[@as MyFormatter]]
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

---@param opts? lsp.Client.format
function M.format(opts)
  opts = vim.tbl_deep_extend(
    "force",
    {},
    opts or {},
    MyVim.opts("nvim-lspconfig").format or {},
    MyVim.opts("conform.nvim").format or {}
  )
  local ok, conform = pcall(require, "conform")
  -- Use conform for formatting with LSP when available,
  -- since it has better format diffing.
  -- Since `opts.formatters` is emptied,
  -- and `lsp_format` is set to `fallback`,
  -- conform will indeed use LSP client's formatter
  -- to run this `format`, e.g. `eslint`.
  if ok then
    opts.formatters = {}
    conform.format(opts)
  else
    -- If `conform.nvim` is not installed, use built-in LSP format function,
    -- which formats buffer with all attached LSP clients, in arbitrary order.
    vim.lsp.buf.format(opts)
  end
end

-- `MyVim.lsp.action.<action>`:
-- - Execute `<action>` with `vim.lsp.buf.code_action(..)`.
M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      })
    end
  end,
})

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler

-- =================================================================
-- `workspace/executeCommand`.
-- =================================================================
-- 1. Client method `workspace/executeCommand` is request sent from client to server,
--    to trigger command execution on server.
-- 2. Server creates `WorkspaceEdit` structure.
-- 3. Server sends request back to client to apply edits, with server method `workspace/applyEdit`.
-- =================================================================

-- =================================================================
-- Code Action Request: Example of using `workspace/executeCommand`.
-- =================================================================
-- Code action request uses client method `workspace/executeCommand` under hood, with following flow:
-- 1. Client sends `textDocument/codeAction` request to server, making server compute code action commands
--    for given text document and range, typically code fixes to either fix problems or to beautify/refactor code.
-- 2. Server computes array of Command literals, and sends these back to client.
-- 3. Commands are presented in user interface, allowing user to choose action.
-- 4. User chooses command, which either:
--    1. Makes client execute command directly, if command is present in `client.commands` table.
--    2. Makes client execute client method `workspace/executeCommand`,
--       if command is not present in `client.commands` table,
--       which sends user-chosen command back to server, where server executes given command.
-- 5. If server executes command, and command results in edits to codebase,
--    server executes server method `workspace/applyEdit`, which is request from server to client,
--    to make client apply edits.
--
-- Command:
-- - Command, e.g. chosen via code action, should be executed by server, not by client.
-- =================================================================

-- Make client execute client method `workspace/executeCommand`,
-- in which client sends request to server to execute given workspace-wide command, with given arguments.
-- If `opts.open` is set, open `trouble.nvim` buffer to show result of passed in `lsp.command`?
---@param opts LspCommand
function M.execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  if opts.open then
    require("trouble").open({
      mode = "lsp_command",
      params = params,
    })
  else
    return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
  end
end

return M
