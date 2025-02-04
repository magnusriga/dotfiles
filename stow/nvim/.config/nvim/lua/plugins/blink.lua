-- ====================================
-- Order.
-- ====================================
-- - `nvim-lspconfig` config-function must run *after* `blink.cmp` config-function.
-- - Enables getting `blink.cmp` capabilities, and adding them to Neovim's built-in
--   LSP client config, so those capabilities are communicated to every used language server.
-- - See: `https://cmp.saghen.dev/installation`.
-- - Enabled by adding `blink.cmp` to `dependencies` of `nvim-lspconfig`: `plugins/lsp/init.lua`.
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

        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },

        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
      },

      -- Experimental signature help support.
      -- signature = { enabled = true },

      -- List of enabled providers.
      -- Extendable through other `blink.cmp` specs, due to `opts_extend`,
      -- e.g. below for `lazydev` provider.
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        cmdline = {},
      },

      keymap = {
        -- 'default': Mappings similar to built-in completion.
        -- 'super-tab': Mappings similar to vscode (tab to accept, arrow keys to navigate).
        -- 'enter': Mappings similar to 'super-tab' but with 'enter' to accept.
        -- preset = "enter",
        preset = "default",
        ["<C-y>"] = { "select_and_accept" },
      },
    },

    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      -- `map`:
      -- - Runs all `actions` passed in first argument, if defined in `MyVim.cmp.actions`.
      -- - Initially, `MyVim.cmp.actions` does not contain `ai_accept`, but can be added later.

      -- Add `ai_accept` to `<Tab>` key.
      -- If snippet is active, `<Tab>` calls `snippet_forward` action, which jumps to next snippet inpput.
      -- If snippet not active, `<Tab>` calls `ai_accept` action, which chooses most likely snippet.
      if not opts.keymap["<Tab>"] then
        if opts.keymap.preset == "super-tab" then -- super-tab
          opts.keymap["<Tab>"] = {
            require("blink.cmp.keymap.presets")["super-tab"]["<Tab>"][1],
            MyVim.cmp.map({ "snippet_forward", "ai_accept" }),
            "fallback",
          }
        -- Other presets, e.g. `default` | `enter`.
        else
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
