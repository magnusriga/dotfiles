return {
  -- nvim-lspconfig is a data-only repository of LSP server configurations.
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        -- Options for vim.diagnostic.config().
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            -- prefix = "●",
            -- This will set the prefix to a function that returns the diagnostics icon based on the severity.
            -- Only works on Neovim >= 0.10.0. Will be set to "●" when not supported.
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
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0.
        -- Remember to configure LSP server to provide inlay hints.
	-- Only used internally, not passed to LSP server.
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- Filetypes for which to not enable inlay hints.
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0.
        -- Remember to configure LSP server to provide the code lenses.
	-- Only used internally, not passed to LSP server.
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
        -- LSP Server Settings
        ---@type lspconfig.options
        servers = {
          lua_ls = {
            -- mason = false, -- Set to false if you don't want this server to be installed with mason.
            -- Add keymaps for specific lsp servers.
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
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
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
      -- Runs last, after invoking Conform with `stylua` formatter.
      MyVim.format.register(MyVim.lsp.formatter())

      -- Setup keymaps when any `client` attaches to any `buffer`,
      -- which combines all keymaps registered on all `nvim_lspconfig` plugins'
      -- `opts.servers[client.name]`,
      -- with all keymaps defined in `plugins.lsp.keymaps`.
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

      -- Diagnostics signs when features from Neovim 10 are not available.
      if vim.fn.has("nvim-0.10.0") == 0 then
        if type(opts.diagnostics.signs) ~= "boolean" then
          for severity, icon in pairs(opts.diagnostics.signs.text) do
            local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
            name = "DiagnosticSign" .. name
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
          end
        end
      end

      if vim.fn.has("nvim-0.10") == 1 then
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
	  -- for every client, and buffer the client is attached to, that
	  -- supports "textDocument/codeLens" method.
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

      -- All `opts` in all `nvim_lspconfig` plugin specs,
      -- are merged before this `config` function is called by `lazy.nvim`,
      -- thus `opts.servers` contain one field named `<lsp_server_name>`,
      -- for every LSP server defined across all `nvim_lspconfig` specs.
      local servers = opts.servers
      
      -- Create table with all Neovim's built-in capabilities,
      -- combined with completion capabilities from `blink`,
      -- which will later be passed to LSP server so it knows
      -- that LSP client should receive completion suggestions.
      -- Used for all servers.
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      -- Finally, create function to setup LSP server,
      -- which calls `require("lspconfig")[server].setup(server_opts)`,
      -- where `server_opts` is table containing all options for given `server`,
      -- including server-specific capabilities merged with global capabilities,
      -- i.e. for all servers, defined above.
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

      -- Add every server key, from ever field in every `opts.servers`,
      -- across all `nvim_lspconfig` specs, to `esure_installed`,
      -- which are same names used by `mason-lspconfig`.
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
