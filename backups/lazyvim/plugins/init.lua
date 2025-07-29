return {
  -- Add any tools you want to have installed.
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },

  { -- Biome formatter.
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
      }

      opts.formatters.biome = {
        args = {
          "check", "--fix", "--stdin-file-path", "$FILENAME"
        }
      }
    end,
  },

  -- Monorepo root dir.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.vtsls.root_dir = require("lspconfig").util.root_pattern(".git")
    end,
  },

  -- Add more treesitter parsers.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })
    end,
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      -- explorer = { enabled = true },
      -- indent = { enabled = true },
      -- input = { enabled = tjue },
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          grep = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/.git/*",
              "**/.next/*",
              "**/node_modules/*",
            },
          },
          files = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/.git/*",
              "**/.next/*",
              "**/node_modules/*",
            },
          },
        },
      },
      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- scope = { enabled = true },
      croll = { enabled = false },
      -- statuscolumn = { enabled = true },
      words = { enabled = false },
    },
  },

  {
    "folke/tokyonight.nvim",
    event = { "VeryLazy" },
    opts = {
      -- style = "night",
      dim_inactive = true,
      on_highlights = function(hl)
        hl.CursorLine = {
          bg = nil,
        }
        -- hl.NvimTreeCursorLine = {
        --   bg = "#333666",
        --   fg = "#bbbbbb",
        -- }
        -- hl.WinSeparator = {
        --   fg = "#555555",
        -- }
        -- hl.NvimTreeWinSeparator = {
        --   fg = "#555555",
        -- }
      end,
    },
  },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_width_percentage = 0.35,
      },
    },
    keys = {
      -- Add `which-key` group name.
      { "<leader>a",  nil,                   desc = "AI/Claude Code" },

      -- Launch ClaudeCode.
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<c-/>",      "<cmd>ClaudeCode<cr>", mode = "n",             desc = "Toggle Claude" },

      -- - Swap to left window, with standard Neovim keybinding.
      -- - Removes `<c-w` to delete word in terminal, when in insert mode,
      --   as mode is only `t` and Insert/Normal mode, within terminal mode,
      --   is delivered by shell.
      {
        "<c-w>h",
        function()
          vim.schedule(function()
            vim.cmd("wincmd h")
          end)
        end,
        mode = "t",
        desc = "Focus Left",
      },

      -- - Move cursor to ClaudeCode window.
      -- - No need, use `<c-w>l` | `<c-w>w`.
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },

      -- `--continue`: Automaticlly continue most recent conversation.
      -- `--resume`: Show convestation picker.
      -- BUG: Does not currently work in `claudecode.nvim`.
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },

      -- Start ClaudeCode with current buffer as context.
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },

      -- Start ClaudeCode with visual selection as context.
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                 desc = "Send to Claude" },

      -- Start ClaudeCode with file(s) from file explorere as context.
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },

      -- - Diff management.
      -- - Alternative:
      --   - Accept: `:w`
      --   - Reject: `:q`
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },
}
