return {
  -- onedarkpro.
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000, -- Ensure it loads first
    opts = {
      colors = {
        onedark = { bg = "#16161D" }, -- yellow
        -- onedark = { bg = '#1F1F28' }, -- yellow
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)
      vim.cmd.colorscheme("onedark")
      -- Other custom highlight settings.
      -- vim.cmd [[ highlight DiagnosticUnderlineError cterm=undercurl gui=undercurl guifg=NONE guisp=#ef596f guibg=#181818 ]]
      -- vim.cmd [[ highlight DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guifg=NONE guisp=yellow guibg=#3e3e3e ]]
      vim.cmd([[ highlight DiagnosticUnderlineError cterm=undercurl gui=undercurl guifg=NONE guisp=red guibg=#3e3e3e ]])
      vim.cmd([[ highlight DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guifg=NONE guisp=yellow ]])
      vim.cmd([[ highlight DiagnosticUnderlineInfo cterm=undercurl gui=undercurl guifg=NONE guisp=LightBlue ]])
      vim.cmd([[ highlight DiagnosticUnderlineHint cterm=undercurl gui=undercurl guifg=NONE guisp=#2bbac5 ]])
      -- DiagnosticUnnecessary is used for unused variables, but links to highlightgroup Comment, by default.
      vim.cmd([[ highlight DiagnosticUnnecessary guifg=#495162 ]])
    end,
  },

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- catppuccin
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
          end
        end,
      },
    },
  },
}
