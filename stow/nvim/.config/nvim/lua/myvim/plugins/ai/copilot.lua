--=========================================
-- Github Copilot.
--=========================================
-- - To create code, write a comment and bring up panel on line below comment,
--   using `:Copilot panel`.
--=========================================

-- ====================================
-- `blink.cmp` and Copilot.
-- ====================================
-- - Problematic that completion menu is blocking view of Copilot ghost text.
-- - Would be same even if copilot suggestion came from completion menu.
-- - Yes, but then at least full text shows in documentation window.
-- - But, `blink.cmp` completion menu does not seem to update as frequently as ghost text from copilot.
-- - Example: When writing any comment, e.g. "-- Function printing fibbionacci …", it stops showing suggestions.
-- - Also impossible to generate code based on comments, as completion menu does not show up
--   on white space, and triggring it with `<C-Space>` does not make the Copilot function
--   suggestion show up.
-- - Some bug in `blink.cmp`?
-- - Thus, turn off `vim.g.ai_cmp` in `config/options.lua`, to disable `blink.cmp` ghost text,
--   and not show Copilot suggestions in completion menu, and instead only show them as ghost text.
-- - To remove completion menu if blocking view of Copilot ghost text: `<C-e>`.
-- ====================================

-- ====================================
-- Usage.
-- ====================================
-- - Ghost text from Copilot is shown automatically when typing, since `auto_trigger` is `true`.
-- - `<Tab>`    : Accept Copilot suggestion, if visible.
-- - `<c-l>`    : Next Copilot suggestion.
-- - `<c-e>`    : Close completion menu, if blocking Copilot ghost text.
-- - `<c-n|p|y>`: Navigate completion menu.
-- - `<c-space>`: Manually trigger completion menu.
-- ====================================

return {
  -- Github Copilot.
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      -- Default `copilot.lua` setting for `panel`, included here for reference.
      panel = {
        -- Panel is shown with `:Copilot panel`, even if `enabled` is `false`,
        -- but `true` allows navigating panel and selecting suggenstion with keybindings.
        -- enabled = true,
        enabled = not vim.g.ai_cmp,

        auto_refresh = false,

        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",

          -- Overlaps with built-in `gr..` bindings, but OK to keep as
          -- only applies in Copilot panel, and both are still accessible with
          -- long and short click.
          refresh = "gr",

          open = "<M-CR>",
        },

        layout = {
          -- Position of split panel buffer:
          -- `top` | `left` | `right` | `horizontal` | `vertical`.
          position = "bottom",

          ratio = 0.4,
        },
      },
      suggestion = {
        -- - With suggestions `enabled`, Copilot suggestions show as ghost text.
        -- - That works well, if ghost text is turned off in `blink.cmp`.
        -- - Alternatively, set `enabled` to `false` here, and add Copilot suggestions
        --   to `blink.cmp` completion menu, see below, then activate ghost text in
        --   `blink.cmp` to ensure first entry, i.e. Copilot suggestion, is visible as
        --   ghost text.
        enabled = not vim.g.ai_cmp,

        -- Show suggestions automatically when typing, via ghost text or in completion
        -- menu, depending on `enabled` setting.
        -- Default: `false`.
        -- Must be `true` for ghost text to appear automatically when typing.
        auto_trigger = true,

        -- Hide Copilot suggestions when completion menu is active.
        hide_during_completion = vim.g.ai_cmp,

        -- Debounce time in milliseconds, default `75`.
        -- debounce = 75,

        keymap = {
          -- - Accept ghost text suggestion, default: `<M-l>`.
          -- - Using `<Tab>` instead, see below additon to `MyVim.acitons`.
          accept = false,

          -- Needed for tab-accept of AI suggestion.
          accept_word = false,
          accept_line = false,

          -- - Move to next Copilot suggestion, in ghost text, default: `<M-]>`.
          -- - Set to `<M-l>`, since `alt` is not available, i.e. used by window
          --   tiling manager, and `<Tab>` is used for `accept`, see below.
          next = "<c-l>",

          -- Leave as deafault, not used.
          -- prev = "<M-[>",
          -- dismiss = "<C-]>",
        },
      },

      -- - Turn off copilot for certain filetypes.
      -- - Default:
      --   - yaml = false,
      --   - markdown = false,
      --   - help = false,
      --   - gitcommit = false,
      --   - gitrebase = false,
      --   - hgcommit = false,
      --   - svn = false,
      --   - cvs = false,
      --   - ["."] = false,
      filetypes = {
        -- Revert "off" default settings for `markdown` and `help` files,
        -- so Copilot works in those filetypes.
        markdown = true,
        help = true,
      },

      -- Change function that gets root folder, default directory with `.git`.
      -- root_dir = function()
      --   return require("copilot.util").find_git_ancestor(vim.fn.expand("%:p"))
      -- end,
    },
  },

  -- - `plugins/blink.lua`:
  --   `<Tab>` mapped to call each `MyVim.action` function, in sequence.
  --
  -- - `MyVim.cmp.lua`:
  --   `snippet_forward` and `snippet_backward` functions are added to
  --   `MyVim.cmp.actions` table, which moves forward and backward in snippet ONLY if
  --   snippet is active, i.e. being filled in on screen, otherwise does nothing.
  --
  -- - `plugins/addons/ai.lua` (below):
  --   `ai_accept` function is added to `MyVim.cmp.actions` table,
  --   which accepts AI suggestion if visible ONLY if Copilot suggestion is visible,
  --   which is always when typing, since `auto_trigger` is `true`, otherwise does nothing.
  --
  -- - Thus, `<Tab>` calls these functions in sequence:
  --   - If snippet visible: `snippet_forward` function, to move forward to next snippet input.
  --   - If Copilot suggestion visible: `ai_accept` function, to accept Copilot suggestion.
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

  -- Add copilot completion source.
  vim.g.ai_cmp
      and {
        "saghen/blink.cmp",
        optional = true,
        dependencies = {
          "fang2hou/blink-copilot",
          opts = {
            -- Below are default options for `blink-copilot`:
            -- max_completions = 3, -- Global default for max_completions.
            -- max_attempts = 4, -- Global default for max_attempts.
            -- kind_name = "Copilot", ---@type string | false
            -- kind_icon = " ", ---@type string | false
            -- kind_hl = false, ---@type string | false
            -- debounce = 200, ---@type integer | false
            -- auto_refresh = {
            --   backward = true,
            --   forward = true,
            -- },
          },
        },
        opts = {
          sources = {
            default = { "copilot" },
            providers = {
              copilot = {
                name = "copilot",
                module = "blink-copilot",
                score_offset = 100,
                -- `async` speeds up completion.
                async = true,
                opts = {
                  -- Local options override global defaults.
                  max_completions = 3,

                  -- Final settings:
                  -- * max_completions = 3
                  -- * max_attempts = 2
                  -- * all other options are default
                },
              },
            },
          },
        },
      }
    or nil,
}
