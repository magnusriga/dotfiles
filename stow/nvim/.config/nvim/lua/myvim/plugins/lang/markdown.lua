local lsp_name = "marksman"

MyVim.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      -- Prefer formatting with `pretter` and linting with `markdownlint`.
      formatters_by_ft = {
        ["markdown"] = { "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "markdownlint-cli2", "markdown-toc" },
        -- ["markdown"] = { "prettier", "markdownlint", "markdown-toc" },
        -- ["markdown.mdx"] = { "prettier", "markdownlint", "markdown-toc" },
        -- ["markdown"] = { "prettierd", "markdownlint", "markdown-toc" },
        -- ["markdown.mdx"] = { "prettierd", "markdownlint", "markdown-toc" },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Uses custom `ensure_installed`, see: `plugins/mason.lua`.
      opts.ensure_installed = opts.ensure_installed or {}
      -- vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "markdownlint", "markdown-toc" })
      vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "markdown-toc" })
    end,
  },

  -- `mason-lspconfig`:
  -- - Installs `marksman` LSP server program.
  -- - Automatically calls `vim.lsp.enable("marksman")`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },

  -- Prefer `nvim-lint`.
  -- Not using `none-ls` anywhere else in Neovim config.
  -- {
  --   "nvimtools/none-ls.nvim",
  --   config = function(_, opts)
  --     local null_ls = require("null-ls")
  --     local sources = {
  --       -- null_ls.builtins.diagnostics.markdownlint_cli2,
  --       null_ls.builtins.diagnostics.markdownlint,
  --     }
  --     null_ls.setup({ sources = sources })
  --   end,
  -- },

  -- - Using `markdownlint-cli2`, like LazyVim.
  -- - `markdownlint-cli2` limitation
  --   - Cannot update diagnostics on `InsertLeave` and `TextChanged` events,
  --     only when buffer written to file.
  --   - `markdownlint` does not have this limitation.
  --   - Stick with `markdownlint-cli2`, more popular.
  -- - Prefer `nvim-lint` over `none-ls`.
  --   - Avoids installing another LSP server.
  --   - `nvim-lint` offer better linting messages.
  --   - `nvim-lint` also used for other file linting, setup in `plugins/linting.lua`.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
        -- markdown = { "markdownlint" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.expand("$HOME/.config/markdownlint-cli2/.markdownlint-cli2.jsonc"), "--" },
        },
      },
    },

    -- init = function()
    -- local markdownlint = require("lint").linters.markdownlint
    -- markdownlint.args = {
    --   "-q",
    --   -- <- Add a new parameter here
    --   "--report=json",
    --   "-",
    -- }
    --   -- Disable diagnostics for markdown files, re-enabled with `<leader>ud`.
    -- vim.api.nvim_create_autocmd("FileType", {
    --   group = vim.api.nvim_create_augroup("disable-diagnostics", { clear = true }),
    --   callback = function()
    --     if vim.bo.filetype == "markdown" then
    --       vim.diagnostic.enable(false)
    --     end
    --   end,
    -- })
    -- end,
  },

  -- Markdown convenience tools, including creating notes from templates.
  {
    "magnusriga/markdown-tools.nvim",
    -- dir = "~/dev/nvim-plugins/markdown-tools.nvim",
    opts = {
      -- frontmatter_custom = {
      --   -- Example: Adds a 'status' field and supports {{status}} placeholder
      --   magnus = function(_opts)
      --     return "rg"
      --   end,
      --   -- Example: Adds a 'related' field (list) and supports {{related}} placeholder
      --   foo = function(_opts)
      --     return { "foo", "bar", "baz" }
      --   end,
      -- },
      -- picker = "snacks",
    },
  },

  -- Preview Markdown in browser, with synchronised scrolling and flexible configuration.
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
  },

  -- Improved view of markdown files, inside Neovim.
  -- Adds markdown colors and formatting directly inside Neovim.
  -- NOTE: Previously called `markdown.nvim`.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Vim modes that will show rendered view of markdown file, :h mode(), for all enabled components.
      -- Individual components can be enabled for other modes.
      -- Remaining modes will be unaffected by this plugin.
      -- Default: render_modes = { "n", "c", "t" },
      render_modes = { "n", "c", "t", "i", "v" },
      bullet = {
        -- Default: `{ '●', '○', '◆', '◇' }`.
        -- icons = { "●", "󰧞", "○", "◆", "◇" },
        icons = { "●", "", "◆", "◇" },
      },
      -- Options for code block and inline code rendering.
      code = {
        -- Turn on / off any sign column related rendering.
        -- Default: `true`.
        sign = false,

        -- Width of code block background.
        -- `full` (default): Full width of window.
        -- `block`: Width of code block.
        -- width = "block",

        -- Amount of padding to add to right of code blocks, when width is 'block'.
        -- If float < 1 is provided, it is treated as percentage of available window space.
        -- Default: `0`.
        -- right_pad = 1,
      },

      -- Options for heading rendering.
      -- `level`: Number of '#' in heading marker.
      -- `sections`: For each level, how deeply nested heading is.
      heading = {
        -- Turn on / off any sign column related rendering.
        -- Default: `true`.
        sign = false,

        -- Replaces '#+' of 'atx_h._marker'.
        -- Output is evaluated depending on type.
        -- `function`: `value(context)`.
        -- `string[]`: `cycle(value, context.level)`.
        -- Default: `{ '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }`.
        icons = { "󰲡  ", "󰲣  ", "󰲥  ", "󰲧  ", "󰲩  ", "󰲫  " },
      },
      -- Checkboxes are special instance of 'list_item', that start with 'shortcut_link'.
      -- There are two special states for unchecked & checked defined in markdown grammar.
      -- checkbox = {
      -- Turn on / off checkbox state rendering.
      -- Default: `true`.
      -- enabled = false,
      -- },

      -- File types this plugin runs on.
      -- Default: `markdown`.
      file_types = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
    },
    -- Lazy-load on filetype.
    ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = function()
          return require("render-markdown.state").enabled
        end,
        set = function(enabled)
          local m = require("render-markdown")
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map("<leader>um")
    end,
  },
}
