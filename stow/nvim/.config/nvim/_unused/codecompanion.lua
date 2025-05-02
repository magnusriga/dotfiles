return {
  -- AI programming, alternative to `avante.nvim`.
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      {
        "Davidyz/VectorCode",
        version = "*",
        build = "pipx upgrade vectorcode",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
      -- "j-hui/fidget.nvim",
      -- { "echasnovski/mini.pick", config = true },
      -- { "ibhagwan/fzf-lua", config = true },
    },
    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "infisical secrets --projectId=5e229f8f-bb80-493c-bd26-b118fefc73ad get ANTHROPIC_API_KEY --plain --silent",
            },
          })
        end,
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
        -- deepseek = function()
        --   return require("codecompanion.adapters").extend("deepseek", {
        --     env = {
        --       api_key = "cmd:op read op://personal/DeepSeek_API/credential --no-newline",
        --     },
        --   })
        -- end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "infisical secrets --projectId=5e229f8f-bb80-493c-bd26-b118fefc73ad get GEMINI_API_KEY --plain --silent",
            },
          })
        end,
        -- novita = function()
        --   return require("codecompanion.adapters").extend("novita", {
        --     env = {
        --       api_key = "cmd:op read op://personal/Novita_API/credential --no-newline",
        --     },
        --     schema = {
        --       model = {
        --         default = function()
        --           return "meta-llama/llama-3.1-8b-instruct"
        --         end,
        --       },
        --     },
        --   })
        -- end,
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                default = "llama3.1:latest",
              },
              num_ctx = {
                default = 20000,
              },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            opts = {
              stream = true,
            },
            env = {
              api_key = "cmd:infisical secrets --projectId=5e229f8f-bb80-493c-bd26-b118fefc73ad get OPENAI_API_KEY --plain --silent",
            },
            schema = {
              model = {
                default = function()
                  return "gpt-4o"
                end,
              },
            },
          })
        end,
        -- xai = function()
        --   return require("codecompanion.adapters").extend("xai", {
        --     env = {
        --       api_key = "cmd:op read op://personal/xAI_API/credential --no-newline",
        --     },
        --   })
        -- end,
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
      prompt_library = {
        ["Boilerplate HTML"] = {
          strategy = "inline",
          description = "Generate some boilerplate HTML",
          opts = {
            mapping = "<LocalLeader>ch",
            ---@return number
            pre_hook = function()
              local bufnr = vim.api.nvim_create_buf(true, false)
              vim.api.nvim_set_current_buf(bufnr)
              vim.api.nvim_set_option_value("filetype", "html", { buf = bufnr })
              return bufnr
            end,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert HTML programmer",
            },
            {
              role = "user",
              content = "<user_prompt>Please generate some HTML boilerplate for me. Return the code only and no markdown codeblocks</user_prompt>",
            },
          },
        },
        ["Code Expert"] = {
          strategy = "chat",
          description = "Get some special advice from an LLM",
          opts = {
            mapping = "<LocalLeader>ce",
            modes = { "v" },
            short_name = "expert",
            auto_submit = true,
            stop_context_insertion = true,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                return "I want you to act as a senior "
                  .. context.filetype
                  .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
              end,
            },
            {
              role = "user",
              content = function(context)
                local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Docusaurus"] = {
          strategy = "chat",
          description = "Write documentation for me",
          opts = {
            index = 11,
            is_slash_cmd = false,
            auto_submit = false,
            short_name = "docs",
          },
          references = {
            {
              type = "file",
              path = {
                "doc/.vitepress/config.mjs",
                "lua/codecompanion/config.lua",
                "README.md",
              },
            },
          },
          prompts = {
            {
              role = "user",
              content = [[I'm rewriting the documentation for my plugin CodeCompanion.nvim, as I'm moving to a vitepress website. Can you help me rewrite it?

I'm sharing my vitepress config file so you have the context of how the documentation website is structured in the `sidebar` section of that file.

I'm also sharing my `config.lua` file which I'm mapping to the `configuration` section of the sidebar.
]],
            },
          },
        },
        ["Test workflow"] = {
          strategy = "workflow",
          description = "Use a workflow to test the plugin",
          opts = {
            index = 4,
          },
          prompts = {
            {
              {
                role = "user",
                content = "Generate a Python class for managing a book library with methods for adding, removing, and searching books",
                opts = {
                  auto_submit = false,
                },
              },
            },
            {
              {
                role = "user",
                content = "Write unit tests for the library class you just created",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Create a TypeScript interface for a complex e-commerce shopping cart system",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Write a recursive algorithm to balance a binary search tree in Java",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Generate a comprehensive regex pattern to validate email addresses with explanations",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Create a Rust struct and implementation for a thread-safe message queue",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Write a GitHub Actions workflow file for CI/CD with multiple stages",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Create SQL queries for a complex database schema with joins across 4 tables",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Write a Lua configuration for Neovim with custom keybindings and plugins",
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = "user",
                content = "Generate documentation in JSDoc format for a complex JavaScript API client",
                opts = {
                  auto_submit = true,
                },
              },
            },
          },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            user = "magnus",
          },
          keymaps = {
            send = {
              modes = {
                -- Default: `modes = { n = "<C-s>", i = "<C-s>" }`,
                -- thus overwrite to not clash with tmux.
                i = { "<C-CR>", "<C-s>" },
                -- n = { "<C-CR>", "<C-s>" },
              },
            },
            -- completion = {
            --   modes = {
            --     i = "<C-x>",
            --   },
            -- },
          },
          -- slash_commands = {
          --   ["buffer"] = {
          --     opts = {
          --       keymaps = {
          --         modes = {
          --           i = "<C-b>",
          --         },
          --       },
          --     },
          --   },
          --   ["help"] = {
          --     opts = {
          --       max_lines = 1000,
          --     },
          --   },
          -- },
          tools = {
            vectorcode = {
              description = "Run VectorCode to retrieve the project context.",
              callback = function()
                return require("vectorcode.integrations").codecompanion.chat.make_tool()
              end,
            },
          },
        },
        inline = { adapter = "copilot" },
        cmd = { adapter = "copilot" },
      },
      -- display = {
      --   action_palette = {
      --     provider = "default",
      --   },
      --   chat = {
      --   show_references = true,
      --   show_header_separator = false,
      --   show_settings = false,
      --   },
      --   diff = {
      --     provider = "mini_diff",
      --   },
      -- },
      opts = {
        log_level = "DEBUG",
      },
    },
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
      -- require("legendary").keymaps({
      --   {
      --     itemgroup = "CodeCompanion",
      --     icon = "",
      --     description = "Use the power of AI...",
      --     keymaps = {
      --       {
      --         "<C-a>",
      --         "<cmd>CodeCompanionActions<CR>",
      --         description = "Open the action palette",
      --         mode = { "n", "v" },
      --       },
      --       {
      --         "<LocalLeader>a",
      --         "<cmd>CodeCompanionChat Toggle<CR>",
      --         description = "Toggle a chat buffer",
      --         mode = { "n", "v" },
      --       },
      --       {
      --         "ga",
      --         "<cmd>CodeCompanionChat Add<CR>",
      --         description = "Add selected text to a chat buffer",
      --         mode = { "n", "v" },
      --       },
      --     },
      --   },
      -- })
      -- require("util.spinner"):init()
    end,
  },

  -- Add `codecompanion` to completion providers.
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "codecompanion" },
      },
    },
  },
}
