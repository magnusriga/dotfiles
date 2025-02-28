-- ====================================
-- Order.
-- ====================================
-- - `nvim-lspconfig` config-function must run *after* `blink.cmp` config-function.
-- - Enables getting `blink.cmp` capabilities, and adding them to Neovim's built-in
--   LSP client config, so those capabilities are communicated to every used language server.
-- - See: `https://cmp.saghen.dev/installation`.
-- - Enabled by adding `blink.cmp` to `dependencies` of `nvim-lspconfig`: `plugins/lsp/init.lua`.
-- ====================================

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
  {
    "saghen/blink.cmp",

    -- Use release tag to download pre-built binaries.
    version = not vim.g.myvim_blink_main and "*",

    -- If not using release tag, build from source.
    build = vim.g.myvim_blink_main and "cargo build --release",

    -- Ensure nested field `sources` is actually extended, and not overwritten,
    -- when other `blink.cmp` specs define same field.
    -- `opts_extend`: Takes each dot-separated word and uses it as key in `opts`,
    -- mergining that table's values with values from same table in parent spec.
    opts_extend = {
      "sources.default",
    },

    dependencies = {
      "rafamadriz/friendly-snippets",
      "onsails/lspkind-nvim",
    },

    -- Delay plugin load until entering Insert mode.
    event = "InsertEnter",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        expand = function(snippet)
          return MyVim.cmp.expand(snippet)
        end,
      },

      appearance = {
        -- Sets fallback highlight groups to nvim-cmp's highlight groups,
        -- useful for when theme doesn't support `blink.cmp`.
        -- Will be removed in future release, assuming themes add support.
        use_nvim_cmp_as_default = false,

        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'.
        -- Adjusts spacing to ensure icons are aligned.
        nerd_font_variant = "mono",
      },

      completion = {
        accept = {
          -- Experimental auto-brackets support.
          auto_brackets = {
            enabled = true,
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },

        -- list = {
        --   -- No effect on cmdline mode, probably due to `config/options.lua` settings,
        --   -- for wildmenu.
        --   selection = {
        --     -- When `true`, automatically select first item in completion list.
        --     -- Default: `true`.
        --     -- Makes no difference, as `<c-y>` anyways selects first item.
        --     -- First item not auto-inserted, even if `auto_insert` is `true`.
        --     -- preselect = function(ctx)
        --     --   return ctx.mode ~= "cmdline"
        --     -- end,

        --     -- When `true`, insert completion item automatically when selecting it,
        --     -- use `<C-e>` to both undo selection and hide completion menu.
        --     -- Default: `true`.
        --     -- auto_insert = function(ctx)
        --     --   return ctx.mode ~= "cmdline"
        --     -- end,
        --   },
        -- },

        menu = {
          -- Better looking without border.
          -- border = "rounded",

          -- cmdline_position = function()
          --   if vim.g.ui_cmdline_pos ~= nil then
          --     local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
          --     return { pos[1] - 1, pos[2] }
          --   end
          --   local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
          --   return { vim.o.lines - height, 0 }
          -- end,

          draw = {
            treesitter = { "lsp" },

            -- Show `kind` as text, e.g. `Snippet`, on RHS of completion menu.
            -- No need, as `kind_icon` already shown on LHS.
            -- columns = {
            --   { "kind_icon", "label", gap = 1 },
            --   { "kind" },
            -- },
          },
        },

        ghost_text = {
          -- - Show entries from completion menu as ghost text.
          -- - Interferes with Copilot suggestions if those also shown as ghost text.
          --
          -- - Thus, only enable `blink.cmp` ghost text below, if Copilot suggestions
          --   ONLY shown as entries in `blink.nvim` completion menu, NOT as ghost text.
          --
          -- - See: `plugins/addons/ai.lua` | `plugins/blink.lua` | `config/options.lua`.
          enabled = vim.g.ai_cmp,
        },
      },

      -- Experimental signature help support.
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      -- Match built-in cmdline completion.
      cmdline = {
        enabled = true,
      },

      -- List of enabled providers.
      -- Extendable through other `blink.cmp` specs, due to `opts_extend`,
      -- e.g. below for `lazydev` provider.
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- providers = {
        --   lsp = {
        --     override = {
        --       get_trigger_characters = function(self)
        --         local trigger_characters = self:get_trigger_characters()
        --         vim.list_extend(trigger_characters, { "\n", "\t", " " })
        --         return trigger_characters
        --       end,
        --     },
        --   },
        -- },
      },

      keymap = {
        -- 'default': Mappings similar to built-in completion.
        -- 'super-tab': Mappings similar to vscode (tab to accept, arrow keys to navigate).
        -- 'enter': Mappings similar to 'super-tab' but with 'enter' to accept.
        -- preset = "enter",
        preset = "default",
        -- Default:
        -- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        -- ["<C-e>"] = { "hide" },
        -- ["<C-y>"] = { "select_and_accept" },

        -- ["<Up>"] = { "select_prev", "fallback" },
        -- ["<Down>"] = { "select_next", "fallback" },
        -- ["<C-p>"] = { "select_prev", "fallback" },
        -- ["<C-n>"] = { "select_next", "fallback" },

        -- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        -- ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- ["<Tab>"] = { "snippet_forward", "fallback" },
        -- ["<S-Tab>"] = { "snippet_backward", "fallback" },

        -- ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },

        -- Traditional completion keymaps.
        --['<CR>'] = cmp.mapping.confirm { select = true },
        --['<Tab>'] = cmp.mapping.select_next_item(),
        --['<S-Tab>'] = cmp.mapping.select_prev_item(),
      },
    },

    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      -- - `plugins/blink.lua` (below):
      --   `<Tab>` mapped to call each `MyVim.action` function, in sequence.
      --
      -- - `MyVim.cmp.lua`:
      --   `snippet_forward` and `snippet_backward` functions are added to
      --   `MyVim.cmp.actions` table, which moves forward and backward in snippet ONLY if
      --   snippet is active, i.e. being filled in on screen, otherwise does nothing.
      --
      -- - `plugins/addons/ai.lua`:
      --   `ai_accept` function is added to `MyVim.cmp.actions` table,
      --   which accepts AI suggestion if visible ONLY if Copilot suggestion is visible,
      --   which is always when typing, since `auto_trigger` is `true`, otherwise does nothing.
      --
      -- - `else` condition below applies, as `super-tab` preset is not used, see above,
      --   using `default` preset instead, which follows Neovim built-in completion keymaps,
      --   e.g. `<C-y>` | etc.
      --
      -- - Thus, `<Tab>` calls these functions in sequence:
      --   - If snippet visible: `snippet_forward` function, to move forward to next snippet input.
      --   - If Copilot suggestion visible: `ai_accept` function, to accept Copilot suggestion.
      if not opts.keymap["<Tab>"] then
        if opts.keymap.preset == "super-tab" then
          opts.keymap["<Tab>"] = {
            require("blink.cmp.keymap.presets")["super-tab"]["<Tab>"][1],
            MyVim.cmp.map({ "snippet_forward", "ai_accept" }),
            "fallback",
          }
        else
          -- - This condition applies, as `default` preset is used, not `super-tab`.
          -- - Thus, `<Tab>` calls `snippet_forward` if snippet is visible,
          --   then `ai_accept` if Copilot suggestion is visible.
          opts.keymap["<Tab>"] = {
            MyVim.cmp.map({ "snippet_forward", "ai_accept" }),
            "fallback",
          }
        end
      end

      -- Check if symbol kinds must be overwritten,
      -- needed by `addons/ai.lua > copilot`.
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
            end
            return items
          end

          -- Unset custom prop to pass blink.cmp validation
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },

  -- Add icons to completion menu.
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("force", opts.appearance.kind_icons or {}, MyVim.config.icons.kinds)
    end,
  },

  -- `lazydev` plugin, included in `plugin/coding.lua`,
  -- forces LuaLS to only load modules, within `.config/nvim`, when module has been `require()`'ed
  -- by some open `.lua` file, in order to make completions faster.
  --
  -- As side effect, LuaLS does not give completion suggestions, and throws diagnostic errors for,
  -- types exported from within `.config/nvim` but not `require()`'ed by open `.lua` file.
  --
  -- Using `lazydev` as completion provider for `blink.nvim`,
  -- ensures all libraries pre-loaded with `lazydev`, i.e. `library` option,
  -- are loaded by LuaLS, so they populate completion suggestions and prevent diagnostic errors.
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        -- Add `lazydev` to completion providers.
        default = { "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- Show with higher priority than `lsp` completion source.
            score_offset = 100,
          },
        },
      },
    },
  },

  -- Catppuccin colorscheme support.
  -- Installs Cattpucin if not done elsewhere,
  -- but does not activate it.
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
