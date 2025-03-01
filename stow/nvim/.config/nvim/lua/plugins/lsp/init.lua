-- ========================================================
-- Notes on `lspconfig`.
-- ========================================================
-- - `require('lua_ls')`:
--   1. `local default_config = tbl_deep_extend('keep', config_def.default_config, util.default_config)``
--      - `config_def`: Object returned from `configs/lua_ls.lua`, containing e.g. `default_config`.
--      - `util.default_config`: Object returned from `configs/lua_ls.lua`.
--      - The two `default_config`s are merged, so `setup` function can merge that with `user_config`.
--   2. `config.lua_ls =  { setup = function (user_config) {..} }`.
--      - Meaning, `config` table gets new `lua_ls` object, which contains `setup` function.
--      - `user_config`: Table passed to `setup` function, amending and overwriting `default_config`.
--      - `setup` function is closure, with access to newly created `default_config`.
--   3. Return: `config` table.
--      - `config` table now contains `setup` function.
--
-- - `require('lua_ls').setup(<user_config>)`:
--    - `user_config` is merged with previously created `default_config`,
--      containing fields from both `configs/lua_ls.lua` > `default_config`, and `util.default_config`.
-- ========================================================

return {
  -- `nvim-lspconfig` is data-only repository of configuration
  -- tables of Neovim's built-in LSP client, allowing it to automatically launch third-party
  -- language servers, and specify configuration for them
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },

      -- Ensure `blink.cmp` is loaded before `nvim-lspconfig`,
      -- so capabilites from `blink.cmp` are available.
      -- TODO: Remove once this is merged: https://github.com/neovim/nvim-lspconfig/issues/3494
      { "saghen/blink.cmp" },
    },

    -- Done as function without arguments, but returning table,
    -- which means it overwrites `opts` from other `nvim-lspconfig` specs in `plugins` directory
    -- appearing in files with filename earlier in alphabetical order,
    -- since plugins get `opts` merged, and `opts`-function run, in order specs for same plugin
    -- appear from top-level spec and forward, with imported specs loaded in alphabetical order of filenames.
    -- NOTE: Thus, this spec must be sourced before other `nvim-lspconfig` specs in `plugins` directory,
    -- i.e. `plugins/addons/lang/<language>.lua`, to ensure merging `opts` correctly.
    opts = function()
      ---@class PluginLspOpts
      local ret = {
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
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- Options for `vim.lsp.buf.format`.
        -- Conform is used for formatting, also when formatter is LSP.
        -- `vim.lsp.format` arguments `filter` and `bufnr` are defined when registering LSP formatter,
        -- thus no need to specify those arguments here.
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- - User config for built-in Neovim LSP client, which `nvim-lspconfig` combines with
        --   own built-in config, and its `util/config.lua`, for servers included in `servers` list.
        -- - Allows built-in Neovim LSP client to run specific third-party language servers automatically,
        --   when opening specific file types, with desired configuration.
        servers = {
          lua_ls = {
            -- Set to false if you don't want this server to be installed with mason.
            -- mason = false,

            -- =======================================
            -- Key Bindings.
            -- =======================================
            -- - Most generic LSP-related key bindings are explicitly defined in `plugins/lsp/keymaps.lua`,
            --   e.g. vim.lsp.buf.references()`.
            -- - Language-server specific bindings are defined in `nvim-lspconfig` specs' `opts.keys`.
            -- - `plugins/lsp/keymaps.lua` is loaded when client attaches to buffer,
            --   combining language-server specific key bindings from `opts.servers[client.name]`,
            --   with those explicitly defined in `plugins/lsp/keymaps.lua`.
            -- - That `LspAttach` autocmd is created from:
            --   `plugins/lsp/init.lua` > `nvim-lspconfig` spec > `config`-function.

            -- - Add key bindings for specific lsp servers.
            -- ---@type MyKeysSpec[]
            -- keys = {},

            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
        -- Additional LSP server setup.
        -- Return true to prevent server setup with lspconfig,
        -- as this function will then handle the setup without lspconfig.
        -- Will get all `server_opts` passed in, just like `lspconfig` would.
        ---@type table<string, fun(server:string, opts:unknown):boolean?>
        setup = {
          -- Example setup with typescript.nvim:
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server.
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
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

      -- Setup keymaps when any `client` attaches to any `buffer`,
      -- which combines all keymaps registered on all `nvim_lspconfig` plugins'
      -- `opts.servers[client.name]`, with all keymaps defined in `plugins.lsp.keymaps`.
      -- `client` is only used to ensure any LSP client is actually
      -- attached to buffer when running autocmd to setup keymaps,
      -- whereas `buffer` is used to get all clients attached to that `buffer`,
      -- which in turn is used to get all keymaps from all nvim-lspconfig's for those attached clients,
      -- i.e. `opts.servers[client.name]`,
      -- which in turn are merged with all keymaps defined in `plugins.lsp.keymaps`.
      MyVim.lsp.on_attach(function(client, buffer)
        require("plugins.lsp.keymaps").on_attach(client, buffer)
      end)

      -- Setup autocmds that runs when client attaches to buffer,
      -- and when regestering new capability on client.
      MyVim.lsp.setup()

      -- Setup keymaps when registering new capability on client,
      -- see above for all steps.
      MyVim.lsp.on_dynamic_capability(require("plugins.lsp.keymaps").on_attach)

      -- Inlay hints.
      if opts.inlay_hints.enabled then
        -- This function runs when client attaches to buffer,
        -- and when registring new capability on client,
        -- for every client, and buffer the client is attached to, that
        -- supports "textDocument/inlayHint" method.
        -- Thus, when client attaches to buffer, and when registring new capability on client,
        -- enable inlay hints in Neovim's built-in LSP client.
        -- Note: Function below only runs once for a given method-client-buffer combination,
        -- following which method-client-buffer is registered in `_supported_methods`,
        -- after which function will not run again, whether it was supported or not by
        -- client and buffer being attached to, or buffers already attached to in case of capability registration.
        MyVim.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
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
        MyVim.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
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
        opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
          or function(diagnostic)
            local icons = MyVim.config.icons.diagnostics
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
          end
      end

      -- Setup nvim diagnostics, by passing `opts.diagnostics`,
      -- setup above, into `vim.diagnostic.config`.
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- All `opts` in all `nvim-lspconfig` plugin specs are merged
      -- before this `config` function is called by `lazy.nvim`,
      -- thus `opts.servers` contain entries for every server defined
      -- accross all `nvim-lspconfig` specs.
      local servers = opts.servers

      -- Create table with all Neovim's built-in capabilities,
      -- combined with completion capabilities from `blink`,
      -- which will later be passed to LSP server so it knows
      -- that LSP client should receive completion suggestions.
      -- Used for all servers.
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      -- Finally, create function to setup LSP server,
      -- which calls `require("lspconfig")[server].setup(server_opts)`,
      -- where `server_opts` is table containing all options for given `server`,
      -- including server-specific capabilities merged with global capabilities,
      -- from all `nvim-lspconfig` specs with given `server` in `opts.servers`.
      local function setup(server)
        -- Remember, all `opts` in all `nvim_lspconfig` plugin specs,
        -- are merged before this `config` function is called by `lazy.nvim`,
        -- thus `opts.servers` contain one field named `<lsp_server_name>`,
        -- for every LSP server defined across all `nvim_lspconfig` specs.
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if server_opts.enabled == false then
          return
        end

        -- If `opts.setup[server]` contains server-entry with function value,
        -- run function before loading LSP with `lspconfig`.
        -- Same `server_opts` is passed in, as is passed to `lspconfig`,
        -- so remember to merge `opts`, from all `lspconfig` specs, appropriately.
        --
        -- If `opts.setup[server]` is a defined function which returns `true`,
        -- see top of this file for an example, then do not setup server,
        -- because that `setup` function will then handle the setup without using
        -- `nvim_lspconfig`, as it is executed below with `server_opts` passed in.
        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        -- If `opts.setup` contains catch-all setup, then execute that and
        -- do not proceed to `lspconfig` server setup.
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end

        -- Set `flags` for all servers.
        -- PERF: Might affect performance.
        server_opts.flags = {
          -- Done to allow `$/cancelRequest` to reach server before `textDocument/didChange`,
          -- when former is sent to server by InsertLeave and TextChanged, as part of storing symbols,
          -- if another `textDocument/documentSymbol` request is in flight.
          debounce_text_changes = 1000,
        }

        -- Finally, execute LSP server's setup function.
        --
        -- `require("lspconfig")[server]` returns table with server-specific
        -- `setup` function that already has access to `default_config` from `nvim_lspconfig`
        -- repository for specific `server` (closure), which it combines with `server_opts` defined above,
        -- referred to as `user_config`, where `user_config` takes presedence in case of conflict.
        --
        -- `lsp_config` then starts LSP server when opening buffer with `filetype` matching one of those
        -- listed in `default_config` from `nvim_lspconfig` repository for specific `server`.
        require("lspconfig")[server].setup(server_opts)
      end

      -- Get all servers available through mason-lspconfig.
      -- Possible because `mason-lspconfig` was listed as dependency of `nvim_lspconfig`,
      -- and was thus installed and loaded before `nvim_lspconfig`.
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      -- Add every server key, from `opts.servers` in every `nvim-lspconfig` spec,
      -- to `esure_installed`, which are same names used by `mason-lspconfig`.
      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            -- Run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig.
            if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
              setup(server)
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      -- Combine `ensure_installed` above with
      -- `ensure_installed` from `mason-lspconfig` `opts`,
      -- then execute `require("mason-lspconfig").setup({ ensure_installed})`,
      -- which will make Mason install all LSP servers listed across all
      -- `nvim_lspconfig` specs's `opt.servers` fields.
      --
      -- Result: For other languages, just add `nvim_lspconfig` with `opt.servers` field
      -- containing specific server configuration, e.g. capabilities, etc.
      if have_mason then
        mlsp.setup({
          automatic_installation = true,
          ensure_installed = vim.tbl_deep_extend(
            "force",
            ensure_installed,
            MyVim.opts("mason-lspconfig.nvim").ensure_installed or {}
          ),
          handlers = { setup },
        })
      end

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
    end,
  },

  -- Mason.nvim.
  -- lazy.nvim installs plugins, i.e. clones from GitHub repo,
  -- before running `config(plugin)` | `require('<main>').setup()`.
  -- Thus, other files marking mason as dependency may use local directory in runtimepath,
  -- i.e. `mason.nvim`, instead of "williamboman/mason.nvim", as spec source.
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Trigger FileType event to possibly load this newly installed LSP server.
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
