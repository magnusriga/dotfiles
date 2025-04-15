return {
  -- AI coding via Claude or other models.
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    -- Never set `version = "*"`, `false` means latest from GitHub.
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

      -- For providers='copilot'.
      "zbirenbaum/copilot.lua",
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
            -- use_absolute_path = true,
          },
        },
      },
      -- {
      --   -- Needed, when `lazy=true`.
      --   "MeanderingProgrammer/render-markdown.nvim",
      --   opts = {
      --     file_types = { "markdown", "Avante" },
      --   },
      --   ft = { "markdown", "Avante" },
      -- },
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
        temperature = 0,
        max_tokens = 4096,
        -- temperature = 1,
        -- max_tokens = 20000,

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
      -- - Settings:
      --   1. enabled: Whether to enable dual_boost mode. Default to false.
      --   2. first_provider: The first provider to generate response. Default to "openai".
      --   3. second_provider: The second provider to generate response. Default to "claude".
      --   4. prompt: The prompt to generate response based on the two reference outputs.
      --   5. timeout: Timeout in milliseconds. Default to 60000.
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

        -- Whether to enable Claude Text Editor Tool Mode.
        enable_claude_text_editor_tool_mode = false,
      },
    },
  },

  -- Add `avante` to completion providers.
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "avante" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
    },
  },
}
