local M = {}

local prettier_supported = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
function M.has_config(ctx)
  local config_path = vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
  vim.print("prettier config path: ", config_path)
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true.
--- * Otherwise, check if a parser can be inferred.
---@param ctx ConformCtx
function M.has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- Default filetypes are always supported.
  if vim.tbl_contains(prettier_supported, ft) then
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

return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "mason.nvim",
        opts = { ensure_installed = { "prettier" } },
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
      -- i.e. after all plugins have been installed and loaded.
      -- LSP formatter has priority 1 by defualt,
      -- `eslint` LSP formatter overwrites that with priority 200.
      -- Thus, in lua files, conform is first invoked with LSP formatter, which has priority 1,
      -- i.e. `vim.lsp.buf.format`, then conform runs formatter registered below, which has priority 100,
      --
      -- with formatters from `formatter_by_ft` runs first,
      -- then `eslint` formatter runs.
      -- gq always uses `require('conform').formatexpr()`, which uses formatters_by_ft,
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
        default_format_opts = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
        },

        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          prettier = {
            condition = function(_, ctx)
              return M.has_parser(ctx) and (vim.g.myvim_prettier_needs_config ~= true or M.has_config(ctx))
            end,
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

      for _, ft in ipairs(prettier_supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "prettierd")
        table.insert(opts.formatters_by_ft[ft], "prettier")
      end

      return opts
    end,
    config = M.setup,
  },
}
