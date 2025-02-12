--=========================================
-- Github Copilot.
--=========================================
-- - To create code, write a comment and bring up panel on line below comment,
--   using `:Copilot panel`.
--=========================================

-- TODO: Check if shadow text can be kept when typing space.
-- TODO: Bring up suggestion menu automatically under comment?

return {
  -- Github Copilot.
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      panel = {
        -- Panel can be brought up with `:Copilot panel` even if this is `false`,
        -- however setting it to `true` allows navigating panel and selecting suggenstion,
        -- with keybindings below.
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          -- Overlaps with built-in `gr..` bindings, but only in Copilot panel,
          -- and both are still accessible with long and short click.
          refresh = "gr",
          open = "<M-CR>",
        },
        layout = {
          -- top | left | right | horizontal | vertical.
          position = "bottom",
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = not vim.g.ai_cmp,
        -- auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        debounce = 75,
        keymap = {
          -- Handled by `blink.cmp`.
          accept = false,

          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  -- Add `ai_accept` function to completion action,
  -- called when hitting <Tab> to accept visible AI suggestion.
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      MyVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          MyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
  },

  -- Add copilot icon to Lualine.
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        MyVim.lualine.status(MyVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded["copilot"] and MyVim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
          if #clients > 0 then
            local status = require("copilot.api").status.data.status
            return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
          end
        end)
      )
    end,
  },

  vim.g.ai_cmp
      and {
        -- Add copilot completion source.
        {
          "saghen/blink.cmp",
          optional = true,
          dependencies = { "giuxtaposition/blink-cmp-copilot" },
          opts = {
            sources = {
              default = { "copilot" },
              providers = {
                copilot = {
                  name = "copilot",
                  module = "blink-cmp-copilot",
                  kind = "Copilot",
                  score_offset = 100,
                  async = true,
                },
              },
            },
          },
        },
      }
    or nil,
}
