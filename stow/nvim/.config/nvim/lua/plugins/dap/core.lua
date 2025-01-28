---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return {
  -- Debug Adapter Protocol client implementation for Neovim to:
  -- - Launch application to debug.
  -- - Attach to running applications and debug them.
  -- - Set breakpoints and step through code.
  -- - Inspect state of application.
  --
  -- This spec does not setup dap clients, i.e. it does not load `nvim-dap`, it only:
  -- - Installs dependencies, like debugger ui.
  -- - Sets up key bindings.
  -- - Loads `mason-nvim-dap.nvim`, which installs all adapters listed in its
  --   spec > `ensure_installed`, using `mason.nvim`.
  -- - Allow dap config via `.vscode/launch.json`.
  --
  -- To load `nvim-dap`, i.e. enable debugging for specific language:
  -- 1. Add adapter definition to `nvim-dap`:
  --      require("dap").adapters["pwa-node"] = {
  --        type = "server",
  --        host = "localhost",
  --        port = "${port}",
  --        executable = {
  --          command = "node",
  --          args = {"/path/to/js-debug/src/dapDebugServer.js", "${port}"},
  --        }
  --      }
  -- 2. Add adapter configuration to `nvim-dap`:
  --      require("dap").configurations.javascript = {
  --        {
  --          type = "pwa-node",
  --          request = "launch",
  --          name = "Launch file",
  --          program = "${file}",
  --          cwd = "${workspaceFolder}",
  --        },
  --      }
  --
  -- Both above steps are done from individual language-specific
  -- setup specs in: `plugins/lang/<language>`.
  --
  -- Start debugger:
  -- - Manually run: `require('dap').continue([opts])`.
  --   - Resumes execution of application if debug session is active.
  --   - Start new debug session, if no active session.
  -- - When `continue` starts new session:
  --   - Look up `config` for current filetype.
  --   - If multiple `config`, ask user to pick.
  --   - Call `dap.run(config)` to start new session.
  -- - `require('dap').run(config, opts)`: Looks up adapter entry for given `config`,
  --   by using `config.type` as key: `require("dap").adapters[<key>]`.
  --
  -- - Call `dap.continue()`, i.e. start/continue debugging, with keybinding: `<leader>dc`.
  {
    "mfussenegger/nvim-dap",
    desc = "Debugging support. Requires language specific adapters to be configured.",
    dependencies = {
      "rcarriga/nvim-dap-ui",

      -- Virtual text for debugger.
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

    -- Debugger key bindings.
    -- stylua: ignore
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },

    config = function()
      -- - Adapters are added to `nvim-dap` in `dependencies` of `nvim-dap`, or inside `nvim-dap` opts` functions,
      --   which run after plugins are installed but before plugins are loaded, i.e. before calling `config` function,
      --   in spec files in `plugins/lang/<name>`.
      -- - Thus, all adapters have been added when this `config` runs.
      -- - Load `mason-nvim-dap.nvim` here, after all adapters have been added to `nvim-dap`,
      --   making `mason.nvim` install all adapters added to `nvim-dap`, using right mason-package name,
      --   see below `mason-nvim-dap.nvim` spec.
      if MyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(MyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(MyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- Setup dap config with vscode `.vscode/launch.json` file,
      -- in case that exists at root of project.
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  -- Fancy UI for debugger.
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },

  -- Bridges `mason.nvim` with `nvim-dap`, making it easier to use plugins together:
  -- - Adds commands, like `DapInstall`, which installs adapters listed in `ensure_installed`, with `mason.nvim`.
  -- - Automatically installs adapters listed in `ensure_installed`, with `dap` adapter names, using `mason.nvim`.
  -- - Translates between `dap` adapter names, and `mason.nvim` package names.
  --
  -- All adapters added to `nvim-dap`, in language-specific dap specs within `plugins/lang/<name>`,
  -- with `require('dap').adapter[<adapter_name>]`, are installed automatically with `mason.json`,
  -- by this plugin, using right mason-package name, assuming `automatic_installation = true`.
  --
  -- Thus, `ensure_installed` is unused.
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      -- All adapters added to `nvim-dap`, in language-specific dap specs within
      -- `plugins/lang/<name>`, with `require('dap').adapter[<adapter_name>]`,
      -- are installed automatically with `mason.json`, by this plugin,
      -- using right mason-package name, assuming `automatic_installation = true`.
      automatic_installation = true,

      -- Can provide additional configuration to handlers,
      -- see `mason-nvim-dap` README for more information.
      handlers = {},

      -- List of adapters to install if not already installed.
      -- Use `automatic_installation` instead, see above.
      ensure_installed = {},
    },

    -- `mason-nvim-dap` is loaded when `nvim-dap` loads,
    -- see `nvim-dap` spec above.
    config = function() end,
  },
}
