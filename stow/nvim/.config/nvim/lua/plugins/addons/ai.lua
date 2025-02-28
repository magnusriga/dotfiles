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
  -- Github Copilot basic working setup.
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require("copilot").setup({
  --       suggestion = {
  --         auto_trigger = true,
  --         keymap = {
  --           -- Handled by `blink.cmp`.
  --           -- <c-y> is used by Neovim and completion engine for confirm,
  --           -- <Tab> is used by completiokkkkkkkkkkkkkn engine to move forward in snippets,
  --           -- thus use `<c-l>` to accept. a
  --           --
  --           -- so use <Tab> here instead.
  --           -- TODO: Check if it interferes with snippets from blink.cmp.
  --           accept = "<Tab>",
  --
  --           next = "<C-l>",
  --           dismiss = "<C-]>",
  --         },
  --       },
  --     })
  --   end,
  -- },

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
        enabled = true,

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

  -- AI coding via Claude or other models.
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    -- `lazy = *`: Always pull latest release version.
    -- `lazy = false`: Update to latest version from GitHub.
    lazy = false,
    version = false,
    -- Build from source: `make BUILD_FROM_SOURCE=true`.
    build = "make",
    -- Windows:
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",

      -- Autocompletion for avante commands and mentions.
      -- "hrsh7th/nvim-cmp",

      -- Use `fzf-lua` as `file_selector`.
      "ibhagwan/fzf-lua",

      "nvim-tree/nvim-web-devicons",

      -- If providers='copilot'.
      -- "zbirenbaum/copilot.lua",
      {
        -- Support for image pasting.
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- For Windows.
            use_absolute_path = true,
          },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "ToggleMyPrompt",
        callback = function()
          require("avante.config").override({ system_prompt = "MY CUSTOM SYSTEM PROMPT" })
        end,
      })

      vim.keymap.set("n", "<leader>am", function()
        vim.api.nvim_exec_autocmds("User", { pattern = "ToggleMyPrompt" })
      end, { desc = "avante: toggle my prompt" })
    end,
    opts = {
      -- Provider used in Aider mode and planning phase of Cursor Planning mode.
      -- `claude` | `openai` | `azure` | `gemini` | `cohere` | `copilot` | `string`.
      provider = "claude",

      -- WARNING: Since auto-suggestions are high-frequency operation and therefore expensive,
      -- currently designating it as `copilot` provider is dangerous because:
      -- https://github.com/yetone/avante.nvim/issues/1048
      -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
      auto_suggestions_provider = "claude",

      -- Provider used in applying phase of Cursor Planning Mode, defaults to `nil`.
      -- When `nil`, uses `Config.provider` as provider for applying phase.
      cursor_applying_provider = nil,

      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        timeout = 30000,
        temperature = 1,
        max_tokens = 20000,

        -- Defaults:
        -- endpoint = "https://api.anthropic.com",
        -- model = "claude-3-5-sonnet-20241022",
        -- timeout = 30000, -- Timeout in milliseconds
        -- temperature = 0,
        -- max_tokens = 4096,

        -- If model does not support tools.
        -- disable_tools = true,

        -- Unsure if these settings work.
        -- thinking = true,
        -- budget_tokens = 16000,
      },
      -- provider = "openai",
      -- openai = {
      --   endpoint = "https://api.openai.com/v1",
      --   model = "gpt-4o", -- Desired model.
      --   timeout = 30000, -- Timeout in milliseconds.
      --   temperature = 0,
      --   max_tokens = 4096,
      --   -- reasoning_effort = "high" -- Supported for reasoning models (o1, etc.).
      -- },

      -- - Specify special dual_boost mode.
      -- - Experimental feature, may not work as expected.
      --
      -- - Settings:
      --   1. enabled: Whether to enable dual_boost mode. Default to false.
      --   2. first_provider: The first provider to generate response. Default to "openai".
      --   3. second_provider: The second provider to generate response. Default to "claude".
      --   4. prompt: The prompt to generate response based on the two reference outputs.
      --   5. timeout: Timeout in milliseconds. Default to 60000.
      --
      -- - How it works:
      --   - When dual_boost is enabled, avante will generate two responses,
      --     from first_provider and second_provider respectively.
      --   - Then use response from first_provider as provider1_output and response from
      --     second_provider as provider2_output.
      --   - Finally, avante will generate response based on prompt and two reference outputs,
      --     with default Provider as normal.
      dual_boost = {
        enabled = false,
        first_provider = "openai",
        second_provider = "claude",
        prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000, -- Timeout in milliseconds
      },

      behaviour = {
        -- Experimental.
        auto_suggestions = false,

        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,

        -- Whether to remove unchanged lines when applying code block.
        minimize_diff = true,

        -- Whether to enable token counting. Default: `true`.
        enable_token_counting = true,

        -- Whether to enable Cursor Planning Mode. Default: `false`.
        enable_cursor_planning_mode = false,
      },
    },
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
