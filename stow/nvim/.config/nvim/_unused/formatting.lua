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
        -- default_format_opts = {
        --   timeout_ms = 3000,
        --   async = false,
        --   quiet = false,
        --   lsp_format = "fallback",
        -- },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          http = { "kulala" },
          typescript = { "biome" },
        },

        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          -- injected = { options = { ignore_errors = true } },
          -- prettier = {
          --   condition = prettier_condition,
          -- },
          kulala = {
            command = "kulala-fmt",
            args = { "format", "$FILENAME" },
            stdin = false,
          },
          biome = {
            inherit = false,
            meta = {
              url = "https://github.com/biomejs/biome",
              description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
            },
            -- command = require("conform.util").from_node_modules("biome"),
            command = "echo",
            stdin = true,
            -- args = { "format", "--stdin-file-path", "$FILENAME" },
            args = {},
            cwd = require("conform.util").root_file({
              "biome.json",
              "biome.jsonc",
            }),
            require_cwd = true,
            -- -- command = require("conform.util").from_node_modules("biome"),
            -- -- command = "pnpm biome check --stdin-file-path='foo.ts' --write",
            -- command = "echo hello world",
            -- args = {},
            -- -- args = { "check", "--stdin-file-path", "$FILENAME", "--write" },
            -- -- args = { "check", "--write", "$FILENAME" },
            -- -- args = { "check", "--write", "$FILENAME" },
            -- stdin = true,
            -- cwd = require("conform.util").root_file({
            --   "biome.json",
            --   "biome.jsonc",
            -- }),
            -- Default: args = { "format", "--stdin-file-path", "$FILENAME" },
            -- args = { "check", "--stdin-file-path", "$FILENAME" },
            -- args = { "format", "--stdin-file-path", "$FILENAME" },
          },
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

      --- Add biome as a formatter for supported filetypes.
      for _, ft in ipairs(biome_ft) do
        opts.formatters_by_ft[ft] = { "biome" }
        -- opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        -- table.insert(opts.formatters_by_ft[ft], "prettierd")
        -- table.insert(opts.formatters_by_ft[ft], "prettier")
      end

      -- Add prettier as a formatter for supported filetypes.
      -- for _, ft in ipairs(prettier_ft) do
      --   opts.formatters_by_ft[ft] = { "prettierd" }
      --   -- opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      --   -- table.insert(opts.formatters_by_ft[ft], "prettierd")
      --   -- table.insert(opts.formatters_by_ft[ft], "prettier")
      -- end

      return opts
    end,
    config = M.setup,
  },
}
