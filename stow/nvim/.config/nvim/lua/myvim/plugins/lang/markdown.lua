MyVim.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["markdown"] = { "prettierd" },
        ["markdown.mdx"] = { "prettierd" },
      },
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
      -- Options for code block and inline code rendering.
      -- code = {
      -- Turn on / off any sign column related rendering.
      -- Default: `true`.
      -- sign = false,

      -- Width of code block background.
      -- `full` (default): Full width of window.
      -- `block`: Width of code block.
      -- width = "block",

      -- Amount of padding to add to right of code blocks, when width is 'block'.
      -- If float < 1 is provided, it is treated as percentage of available window space.
      -- Default: `0`.
      -- right_pad = 1,
      -- },

      -- Options for heading rendering.
      -- `level`: Number of '#' in heading marker.
      -- `sections`: For each level, how deeply nested heading is.
      heading = {
        -- Turn on / off any sign column related rendering.
        -- Default: `true`.
        -- sign = false,

        -- Replaces '#+' of 'atx_h._marker'.
        -- Output is evaluated depending on type.
        -- `function`: `value(context)`.
        -- `string[]`: `cycle(value, context.level)`.
        -- Default: `{ '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }`.
        icons = {},
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
