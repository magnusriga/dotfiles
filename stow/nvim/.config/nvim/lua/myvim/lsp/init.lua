local M = {}

-- Configuration for all LSP servers.
vim.lsp.config("*", {
  -- Default settings for all LSP servers.
  -- flags = {
  -- -- - Debounce `textDocument/didChange` notifications to server.
  -- -- - Default: 150 ms.
  --   debounce_text_changes = 1000,
  -- },
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
    workspace = {
      fileOperations = {
        didRename = true,
        willRename = true,
      },
    },
  },
})

local opts = {
  -- Used for `vim.diagnostic.config()` below, not passed to language server.
  ---@type vim.diagnostic.Opts
  diagnostics = {
    underline = true,
    -- - By default, Neovim's built-in LSP client updates diagnostics on `InsertLeave`,
    --   i.e. when leaving Insert mode, including when running `ctrl-o` in Insert mode.
    -- - With `update_in_insert = true`, Neovim's built-in LSP client updates diagnostics
    --   when typing in Insert mode, i.e. on `TextChanged`, which can be slow.
    -- - Turn this off, so virual text does not interfere with ghost text from e.g. AI suggestions.
    -- update_in_insert = true,
    update_in_insert = false,

    virtual_text = {
      -- - Position of virtual text.
      -- - Better to use `update_in_insert` instead, to avoid virtual text
      --   interfering with ghost text, e.g. from AI suggestions.
      -- - Possible values:
      --   - `eol`        : Right after eol character (default).
      --   - `overlay`    : Display over specified column, without shifting
      --                    underlying text.
      --   - `right_align`: display right aligned in window.
      --   - `inline`     : Display at specified column, and shift buffer text to
      --                    right as needed.
      -- `virtual_text_pos = "eol",

      -- Empty space before virtual text.
      spacing = 4,

      -- Include diagnostic source in message.
      -- `if_many`: Only show source if multiple sources of diagnostics in buffer.
      source = "if_many",

      -- - Prefix for each diagnostic in window.
      -- - Converted to function in `config`, to return icon based on severity.
      prefix = "icons",
    },

    severity_sort = true,

    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = MyVim.config.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = MyVim.config.icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = MyVim.config.icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = MyVim.config.icons.diagnostics.Info,
      },
    },
  },

  -- Inlay hints are type hints, e.g. on function arguments, in editor.
  -- Remember to configure LSP server to provide inlay hints.
  -- Used below for `vim.lsp.inlay_hint.enable(..)`, not passed to language server.
  inlay_hints = {
    enabled = true,

    -- Disable inlay hints for specific filetypes.
    exclude = { "vue", "typescript", "typescriptreact" },
  },

  -- Code lense is information, e.g. references | implementations | etc., above functions.
  -- Remember to configure LSP server to provide the code lenses.
  -- Only used internally, not passed to LSP server.
  -- PERF: Might affect performance, thus disable by default.
  codelens = {
    enabled = false,
  },

  -- Add global capabilities to built-in Neovim LSP client.
  -- Only used internally, when it is combined with built-in capabilities,
  -- and capabilities from completion engine, into new table which is sent
  -- to LSP server so it knows that Neovim's built-in LSP client can now
  -- do rename operations on all files across entire workspace, in one go.

  -- Options for `vim.lsp.buf.format`.
  -- Conform is used for formatting, also when formatter is LSP.
  -- `vim.lsp.format` arguments `filter` and `bufnr` are defined when registering LSP formatter,
  -- thus no need to specify those arguments here.
  format = {
    formatting_options = nil,
    timeout_ms = nil,
  },
}

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
  -- Register LSP formatter, which uses Conform under the hood,
  -- with `opt.formatters = nil`, which makes Conform fallback
  -- to using this LSP formatter.
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
  --
  -- Thus, below regstering has no effect as long as `conform.nvim` is installed.
  MyVim.format.register(MyVim.lsp.formatter())

  -- - `client/registerCapability` request is sent from server to client,
  --   to let client know that server supports particular client method.
  -- - Request happens dynamically, AFTER LspAttach.
  -- - Only called if client supports dynamic capability registration,
  --   which all clients in Neovim should do.
  -- - Client can even cherrypick specific capabilities for which to support
  --   dynamic capability registration.
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

  -- - Execute `LspSupportsMethod`s when LSP client attaches to buffer,
  -- - Enables inlay hints and codelens refresh, assuming client supports
  --   `textDocument/inlayHint` and `textDocument/codeLens`.
  MyVim.lsp.on_attach(MyVim.lsp._check_methods)

  -- - Execute `LspSupportsMethod`s when LSP server sends request to client,
  --   telling client it now supports given client method.
  -- - Enables inlay hints and codelens refresh, assuming client supports
  --   `textDocument/inlayHint` and `textDocument/codeLens`.
  MyVim.lsp.on_dynamic_capability(MyVim.lsp._check_methods)

  -- Setup keymaps when any `client` attaches to any `buffer`,
  -- which combines all keymaps registered on all `nvim_lspconfig` plugins'
  -- `opts.servers[client.name]`, with all keymaps defined in `lsp/keymaps`.
  -- `client` is only used to ensure any LSP client is actually
  -- attached to buffer when running autocmd to setup keymaps,
  -- whereas `buffer` is used to get all clients attached to that `buffer`,
  -- which in turn is used to get all keymaps from all nvim-lspconfig's for those attached clients,
  -- i.e. `opts.servers[client.name]`,
  -- which in turn are merged with all keymaps defined in `lsp/keymaps`.
  MyVim.lsp.on_attach(require("myvim.lsp.keymaps").on_attach)

  -- Setup keymaps when server dynamically registers new capability on client.
  -- NOTE: Needed again, despite already added via `on_attach()`,
  -- because keymaps only registered if client supports method from `has` field,
  -- and that method might be dynamically registered by server on client,
  -- via `client/registerCapability`, AFTER LSP has attached.
  MyVim.lsp.on_dynamic_capability(require("myvim.lsp.keymaps").on_attach)

  -- Inlay hints.
  if opts.inlay_hints.enabled then
    -- This function runs when client attaches to buffer,
    -- and when registring new capability on client,
    -- for every client, and buffer the client is attached to,
    -- that supports "textDocument/inlayHint" method.
    -- Thus, when client attaches to buffer, and when registring new capability on client,
    -- enable inlay hints in Neovim's built-in LSP client.
    -- Note: Function below only runs once for a given method-client-buffer combination,
    -- following which method-client-buffer is registered in `_supported_methods`,
    -- after which function will not run again, whether it was supported or not by
    -- client and buffer being attached to, or buffers already attached to in case of capability registration.
    MyVim.lsp.on_supports_method("textDocument/inlayHint", function(_, buffer)
      if
        vim.api.nvim_buf_is_valid(buffer)
        and vim.bo[buffer].buftype == ""
        and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
      then
        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
      end
    end)
  end

  -- Code lens.
  if opts.codelens.enabled and vim.lsp.codelens then
    -- This function runs when client attaches to buffer,
    -- and when registring new capability on client,
    -- for every client, and buffer the client is attached to,
    -- that supports "textDocument/codeLens" method.
    -- Thus, when client attaches to buffer, and when registring new capability on client,
    -- refresh codelens list from LSP, and create autocmd that refreshes codelens list
    -- whenever (re)-entering buffer, when no key has been pressed for 4 seconds (`opt.updatetime`),
    -- and when leaving insert mode.
    -- Note: Function below only runs once for a given method-client-buffer combination,
    -- following which method-client-buffer is registered in `_supported_methods`,
    -- after which function will not run again, whether it was supported or not by
    -- client and buffer being attached to, or buffers already attached to in case of capability registration.
    MyVim.lsp.on_supports_method("textDocument/codeLens", function(_, buffer)
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = buffer,
        callback = vim.lsp.codelens.refresh,
      })
    end)
  end

  -- Update `opts.diagnostics.virtual_text.prefix` to function which
  -- returns specific icon from `MyVim.config.icons.diagnostics`,
  -- depending on `diagnostic.severity`.
  if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
    opts.diagnostics.virtual_text.prefix = function(diagnostic)
      local icons = MyVim.config.icons.diagnostics
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
          return icon
        end
      end
      -- Backup icon, in case severity not found.
      return "●"
    end
  end

  -- Setup nvim diagnostics, by passing `opts.diagnostics`,
  -- setup above, into `vim.diagnostic.config`.
  vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

  -- If `denols` is enabled, disable `vtsls`,
  -- and enable `denols` if `root_pattern` files can be found.
  if MyVim.lsp.is_enabled("denols") and MyVim.lsp.is_enabled("vtsls") then
    local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
    MyVim.lsp.disable("vtsls", is_deno)
    MyVim.lsp.disable("denols", function(root_dir, config)
      if not is_deno(root_dir) then
        config.settings.deno.enable = false
      end
      return false
    end)
  end
end

return M
