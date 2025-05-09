local lsp_name = "vtsls"

local js_ts_opts = {
  -- Update imports across workspace when moving file.
  updateImportsOnFileMove = { enabled = "always" },

  suggest = {
    -- Complete functions with their parameter signature.
    completeFunctionCalls = true,
  },

  inlayHints = {
    -- Inlay hints for member values in enum declarations.
    enumMemberValues = { enabled = true },

    -- Inlay hints for implicit return types on function signatures.
    functionLikeReturnTypes = { enabled = true },

    -- Inlay hints for function parameters:
    -- - `none`   : Disable parameter name hints.
    -- - `literal`: Enable parameter name hints only for literal arguments.
    -- - `all`    : Enable parameter name hints for literal and non-literal arguments.
    parameterNames = { enabled = "literals" },

    -- Inlay hints for implicit parameter types.
    parameterTypes = { enabled = true },

    -- Inlay hints for implicit types on property declarations.
    propertyDeclarationTypes = { enabled = true },

    -- Inlay hints for implicit variable types.
    variableTypes = { enabled = false },
  },
}

vim.lsp.config(lsp_name, {
  -- Explicitly add default filetypes,
  -- to be able to extend list in other related specs.
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },

  -- - Use `.git` directory as project root, instead of default
  --   `package.json` | `tsconfig.json`, since using monorepo.
  -- - Prefer `root_markers` over `root_dir`, former does upward search by default.
  root_markers = { ".git", ".hg" },

  -- Almost same as original VSCode extension:
  -- `https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json`.
  -- `vtsls`: Additional settings exclusive to `vtsls`.
  settings = {
    complete_function_calls = true,

    -- Settings exclusive to `vtsls`.
    vtsls = {
      -- Move code section to target file, interactively.
      -- Requires additonal setup, see below.
      enableMoveToFileCodeAction = true,

      -- Automatically use workspace version of TypeScript lib on startup.
      -- By default, bundled version is used for IntelliSense.
      autoUseWorkspaceTsdk = true,

      experimental = {
        -- Maximum length of single inlay hint.
        -- Hint is simply truncated if limit is exceeded.
        -- Do not set this if client already handles overly long hints gracefully.
        maxInlayHintLength = 30,

        completion = {
          -- Execute fuzzy match of completion items on server side.
          -- Enable this to help filter out useless completion items from tsserver.
          enableServerSideFuzzyMatch = true,
        },
      },
    },

    -- These configuration options are same for `javascript`,
    -- thus copied over later.
    typescript = vim.deepcopy(js_ts_opts),
    javascript = vim.deepcopy(js_ts_opts),
  },
  on_attach = function(client, _)
    client.commands["_typescript.moveToFileRefactoring"] = function(command, _)
      ---@type string, string, lsp.Range
      local action, uri, range = unpack(command.arguments)

      local function move(newf)
        client:request("workspace/executeCommand", {
          command = command.command,
          arguments = { action, uri, range, newf },
        })
      end

      local fname = vim.uri_to_fname(uri)
      client:request("workspace/executeCommand", {
        command = "typescript.tsserverRequest",
        arguments = {
          "getMoveToRefactoringFileSuggestions",
          {
            file = fname,
            startLine = range.start.line + 1,
            startOffset = range.start.character + 1,
            endLine = range["end"].line + 1,
            endOffset = range["end"].character + 1,
          },
        },
      }, function(_, result)
        ---@type string[]
        local files = result.body.files
        table.insert(files, 1, "Enter new path...")
        vim.ui.select(files, {
          prompt = "Select move destination:",
          format_item = function(f)
            return vim.fn.fnamemodify(f, ":~:.")
          end,
        }, function(f)
          if f and f:find("^Enter new path") then
            vim.ui.input({
              prompt = "Enter move destination:",
              default = vim.fn.fnamemodify(fname, ":h") .. "/",
              completion = "file",
            }, function(newf)
              return newf and move(newf)
            end)
          elseif f then
            move(f)
          end
        end)
      end)
    end
  end,

  -- =================================================================
  -- Keys.
  -- =================================================================
  on_init = function(_)
    -- -----------------------------------------------------------------
    -- Server vs. Client.
    -- -----------------------------------------------------------------
    -- - `lua_ls` and `vtsls` are SERVERS, not clients.
    -- - `vtsls` server started with `vtsls --stdio`, following which client can
    --   communicate with `vtsls` server via standard input|output.
    -- - Language client is built into editors themselves, e.g. Neovim,
    --   providing functions allowing client to speak with server,
    --   e.g. `vim.lsp.buf.references()`.
    -- - `vim.lsp.config['luals'] = { cmd = {..}, filetypes = {..}, root_markers = {..}, ... }`.
    --   - Used to define settings for Neovim's built-in LSP client.
    --   - `cwd`: Command and argument to start server.
    --   - `filetypes`: Filetypes for which server should automatically start.
    --   - `settings`: Settings to send to server.
    -- - `nvim-lspconfig`:
    --   - Pre-defines configurations for Neovim's built-in LSP client, for different language servers.
    --   - Example: `vtsls`.

    -- -----------------------------------------------------------------
    -- `workspace/executeCommand`.
    -- -----------------------------------------------------------------
    -- =================================================================
    -- 1. Client method `workspace/executeCommand` is request sent from client to server,
    --    to trigger command execution on server.
    -- 2. Server creates `WorkspaceEdit` structure.
    -- 3. Server sends request back to client to apply edits, with server method `workspace/applyEdit`.

    -- -----------------------------------------------------------------
    -- Code Action Request: Example of using `workspace/executeCommand`.
    -- -----------------------------------------------------------------
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

    -- -----------------------------------------------------------------
    -- Code Lens Request.
    -- -----------------------------------------------------------------
    -- - A code lens represents a command that should be shown along with source text, e.g. number of
    --   references | implementations for classes, interfaces, methods, properties, and exported objects.
    -- - A code lens is unresolved when no command is associated to it.
    -- - For performance reasons, creation of a code lens, and resolving it, should be done in two stages.
    -- - See:
    --   - `<spec>/#textDocument_codeLens`.
    --   - `https://code.visualstudio.com/docs/typescript/typescript-editing#_references-codelens`.

    -- -----------------------------------------------------------------
    -- `client.commands` (see: `h: vim.lsp.commands`).
    -- -----------------------------------------------------------------
    -- - `client.commands`: Table field on LSP client table.
    -- - Key: Unique command name.
    -- - Value: Function, called when server sends command to client matching entry in `client.commands`.
    -- - Example: `client.commands["getMoveToRefactoringFileSuggestions"]`.
    -- - Functions in `client.commands` represent commands not part of core language server protocol specification,
    --   i.e. NOT client method like `textDocument/references` executed with `vim.lsp.buf.references()`.
    -- - Function in `client.commands` list is executed when server sends response to client with given command,
    --   e.g. when user chooses code action from command list provided by server.
    --   - If `client.commands` does not contain command chosen by user based on list from server,
    --     then client invokes client method `workspace/executeCommand`,
    --     which sends request to server to execute command server-side,
    --     since client does not have its implementation.
    --
    -- - Important:
    --   - Commands defined by e.g. `vtsls` are server-side commands, NOT commands in `client.commands`.
    --   - Client asks server to execute server-side command, on server,
    --     by invoking client method `workspace/executeCommand`, providing command name and arguments.

    -- -----------------------------------------------------------------
    -- Key Bindings.
    -- -----------------------------------------------------------------
    -- - Most generic LSP-related key bindings are explicitly defined in `plugins/lsp/keymaps.lua`,
    --   e.g. vim.lsp.buf.references()`.
    -- - Language-server specific bindings are defined in `nvim-lspconfig` specs' `opts.keys`.
    -- - `plugins/lsp/keymaps.lua` is loaded when client attaches to buffer,
    --   combining language-server specific key bindings from `opts.servers[client.name]`,
    --   with those explicitly defined in `plugins/lsp/keymaps.lua`.
    -- - That `LspAttach` autocmd is created from:
    --   `plugins/lsp/init.lua` > `nvim-lspconfig` spec > `config`-function.

    -- -----------------------------------------------------------------
    -- `MyVim.lsp.execute`.
    -- -----------------------------------------------------------------
    -- `typescript.goToSourceDefinition` and `typescript.findAllFileReferences`.
    -- - Typescript specific commands, defined by `vtsls`.
    -- - Thus no built-in Neovim language client method exists that invokes these commands on server.
    -- - Thus, commands must be executed by client invoking client method `workspace/executeCommand`,
    --   passing in name of command, i.e. `typescript.goToSourceDefinition`, and its arguments,
    --   making server execute command.
    --
    -- - Thus, these key bindings are defined below, to be executed with `MyVim.lsp.execute`,
    --   and not defined in `plugins/lsp/keymaps.lua`, to be executed with built-in `vim.lsp.buf.<command>`.
    --
    -- - If `opts.open` is set, open `trouble.nvim` buffer to show result of passed in `lsp.command`?
    --
    -- - Commands defined by e.g. `vtsls` are server-side commands, NOT commands in `client.commands`.
    -- - Client asks server to execute server-side command, on server,
    --   by invoking client method `workspace/executeCommand`, providing command name and arguments.
    --
    -- - Key bindings below, using `MyVim.lsp.execute`, augment key bindings executing standard LSP methods,
    --   e.g. `vim.lsp.buf.references()`, defined explicitly in `plugins/lsp/keymaps.lua`.
    -- - See note on keybindings.
    local Keys = require("myvim.lsp.keymaps").get()
    vim.list_extend(Keys, {
      {
        "gD",
        function()
          local params = vim.lsp.util.make_position_params(0, "utf-8")
          MyVim.lsp.execute({
            command = "typescript.goToSourceDefinition",
            arguments = { params.textDocument.uri, params.position },
            open = true,
          })
        end,
        desc = "Goto Source Definition",
      },
      {
        "gR",
        function()
          MyVim.lsp.execute({
            command = "typescript.findAllFileReferences",
            arguments = { vim.uri_from_bufnr(0) },
            open = true,
          })
        end,
        desc = "File References",
      },

      -- =======================================
      -- `MyVim.lsp.action.<action>`.
      -- =======================================
      -- - Execute code action `<action>`, with `vim.lsp.buf.code_action(..)`.
      -- - Defined here, as code action names are specific to typescripts.
      -- - Example:
      --   vim.lsp.buf.code_action({
      --     apply = true,
      --     context = {
      --       only = { "source.organizeImports" },
      --       diagnostics = {},
      --     },
      --   })
      -- - Same code actions as vscode, list:
      --   `https://github.com/yioneko/vtsls?tab=readme-ov-file#commands`.
      {
        "<leader>co",
        MyVim.lsp.action["source.organizeImports"],
        desc = "Organize Imports",
      },
      {
        "<leader>cM",
        MyVim.lsp.action["source.addMissingImports.ts"],
        desc = "Add missing imports",
      },
      {
        "<leader>cu",
        MyVim.lsp.action["source.removeUnused.ts"],
        desc = "Remove unused imports",
      },
      {
        "<leader>cD",
        MyVim.lsp.action["source.fixAll.ts"],
        desc = "Fix all diagnostics",
      },

      -- Another server-side command,
      -- invoked by client via client method `workspace/executeCommand`.
      {
        "<leader>cV",
        function()
          MyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
        end,
        desc = "Select TS workspace version",
      },
    })
  end,
})

return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          -- Uses custom `ensure_installed`, see: `plugins/mason.lua`.
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              MyVim.get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
              "${port}",
            },
          },
        }
      end
      if not dap.adapters["node"] then
        dap.adapters["node"] = function(cb, config)
          if config.type == "node" then
            config.type = "pwa-node"
          end
          local nativeAdapter = dap.adapters["pwa-node"]
          if type(nativeAdapter) == "function" then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },

  -- Filetype icons.
  -- {
  --   "echasnovski/mini.icons",
  --   opts = {
  --     file = {
  --       [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
  --       [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
  --       [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
  --       [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
  --       ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
  --       ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
  --       ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
  --       ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
  --       ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
  --     },
  --   },
  -- },
}
