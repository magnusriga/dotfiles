local M = {}

-- Filetypes for which Biome should be used.
local biome_ft = {
  "astro",
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "svelte",
  "typescript",
  "typescript.tsx",
  "typescriptreact",
  "vue",
}

-- Using Biome instead, when supported.
local prettier_ft = {
  -- "css",
  -- "graphql",
  "handlebars",
  "html",
  -- "javascript",
  -- "javascriptreact",
  -- "json",
  -- "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  -- "typescript",
  -- "typescriptreact",
  -- "vue",
  "xhtml",
  "yaml",
}

--- Checks if a Prettier config file exists for the given context.
---@param ctx conform.Context`
function M.has_config(ctx)
  local config_path = vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
  -- vim.print("prettier config path: ", config_path)
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true.
--- * Otherwise, check if a parser can be inferred.
---@param ctx conform.Context
function M.has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- Default filetypes are always supported.
  if vim.tbl_contains(prettier_ft, ft) then
    return true
  end
  -- Otherwise, check if a parser can be inferred.
  local ret = vim.fn.system({ "prettier", "--file-info", ctx.filename })
  ---@type boolean, string?
  local ok, parser = pcall(function()
    return vim.fn.json_decode(ret).inferredParser
  end)
  return ok and parser and parser ~= vim.NIL
end

M.has_config = MyVim.memoize(M.has_config)
M.has_parser = MyVim.memoize(M.has_parser)

---@param opts conform.setupOpts
function M.setup(_, opts)
  for _, key in ipairs({ "format_on_save", "format_after_save" }) do
    if opts[key] then
      local msg = "Don't set `opts.%s` for `conform.nvim`.\nConform formatter is used automatically."
      MyVim.warn(msg:format(key))
      ---@diagnostic disable-next-line: no-unknown
      opts[key] = nil
    end
  end
  require("conform").setup(opts)
end

local prettier_condition = function(_, ctx)
  return M.has_parser(ctx) and (vim.g.myvim_prettier_needs_config ~= true or M.has_config(ctx))
end

return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          -- Uses custom `ensure_installed`, see: `plugins/mason.lua`.
          opts.ensure_installed = opts.ensure_installed or {}
          -- NOTE: Do not install `biome`, using project-local `biome` executable,
          -- installed with `pnpm`.
          vim.list_extend(opts.ensure_installed, { "kulala-fmt" })
        end,
      },
    },
    -- Only load this plugin when `require('conform')`,
    -- which happens when running formatter,
    -- as seen in registration table below.
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    init = function()
      -- Register conform formatter on VeryLazy event,
      -- i.e. after all plugins have been installed and loaded, as `primary` formatter.
      --
      -- LSP formatter registered in `plugins/lsp/init.lua` via `util/lsp.lua`,
      -- is also `primary` formatter, but has priority 1, thus it never runs,
      -- as only one `primary` formatter is permitted, and one with highest priority is used.
      --
      -- Certain other LSPs, like `eslint`, register new non-`primary` formatters,
      -- with even higher priority, e.g. 200, thus these run first,
      -- following which conform using `formatter_by_ft` runs.
      --
      -- `eslint`'s formatter just does ESLintFixAll, before prettier runs via conform.
      --
      -- `gq` always uses `require('conform').formatexpr()`, which uses formatters_by_ft,
      -- without setting `opts.formatters` to nil (which makes conform use LSP formatter).
      MyVim.on_very_lazy(function()
        MyVim.format.register({
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            -- Since conform is `lazy=true`,
            -- the conform plugin is only loaded when this format function runs,
            -- which happens on every formatting keybinding and when running `formatexr()`.
            -- Require return values are cached, so it will only be "slow" on first format.
            require("conform").format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function()
      ---@type conform.setupOpts
      local opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          http = { "kulala" },
        },

        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          prettier = {
            condition = prettier_condition,
          },
          kulala = {
            command = "kulala-fmt",
            args = { "format", "$FILENAME" },
            stdin = false,
          },
          -- biome = {
          -- Important:
          -- - `biome` can be run from any directory, it will always use
          --   config file nearest to file being formatted.
          -- - In other words, it is irrelevant where `biome` is run from
          -- - Meaning, Conform's `cwd` is irrelevant.
          --
          -- Default command:
          -- - `command = util.from_node_modules("biome")`
          -- - Uses `biome` executable in `node_modules` nearest file being formatted.
          --
          -- Where command is run from:
          -- - `cwd = util.root_file({ "biome.json", "biome.jsonc", })`
          -- - Command run from directory with config file, nearest file being formatted.
          --
          -- Config file:
          -- - `biome` always uses config file nearest to file being formatted,
          --   regardless of where `biome` is run from.
          -- },
          --
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
        },
      }

      --- Add biome as formatter for supported filetypes.
      --- Use `biome-check` formatter, as it uses `biome check`,
      for _, ft in ipairs(biome_ft) do
        opts.formatters_by_ft[ft] = { "biome-check" }
      end

      -- Add prettier as formatter for supported filetypes.
      for _, ft in ipairs(prettier_ft) do
        opts.formatters_by_ft[ft] = { "prettierd" }
      end

      return opts
    end,
    config = M.setup,
  },
}
