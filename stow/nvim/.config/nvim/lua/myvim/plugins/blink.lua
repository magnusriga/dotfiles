-- ====================================
-- Order.
-- ====================================
-- - `nvim-lspconfig` config-function must run *after* `blink.cmp` config-function.
-- - Enables getting `blink.cmp` capabilities, and adding them to Neovim's built-in
--   LSP client config, so those capabilities are communicated to every used language server.
-- - See: `https://cmp.saghen.dev/installation`.
-- - Enabled by adding `blink.cmp` to `dependencies` of `nvim-lspconfig`: `plugins/lsp/init.lua`.
-- - To make sorting work: `fuzzy.implementation = 'lua'`.
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

-- Build blink from source, i.e. main branch, to keep up with latest changes.
-- vim.g.myvim_blink_main = true
vim.g.myvim_blink_main = false

return {
  {
    "saghen/blink.cmp",

    -- Use release tag to download pre-built binaries.
    version = not vim.g.myvim_blink_main and "*",

    -- If not using release tag, build from source.
    build = vim.g.myvim_blink_main and "cargo build --release",

    -- Ensure nested array `sources` is actually extended, and not overwritten,
    -- when other `blink.cmp` specs define same field.
    -- `opts_extend`: Takes each dot-separated word and uses it as key in `opts`,
    -- mergining that table's values with values from same table in parent spec.
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },

    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "saghen/blink.compat",
        opts = {},
        version = not vim.g.myvim_blink_main and "*",
      },
      -- "onsails/lspkind-nvim", -- Prefer own icons.
      -- "xzbdmw/colorful-menu.nvim", -- Does not work well, avoid.
      -- "jdrupal-dev/css-vars.nvim",
      "Kaiser-Yang/blink-cmp-git",
      "Kaiser-Yang/blink-cmp-avante",

      -- WARNING: Slows down completion menu, avoid.
      -- "disrupted/blink-cmp-conventional-commits",

      -- "nvim-tree/nvim-web-devicons",
    },

    -- Delay plugin load until entering Insert mode.
    event = "InsertEnter",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        -- Function to use when expanding LSP provided snippets.
        -- Default: `function(snippet) vim.snippet.expand(snippet) end`.
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
        accept = { auto_brackets = { enabled = true } },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },

        list = {
          -- Maximum number of items to display.
          -- Default: 200.
          max_items = 7500,
          -- No effect on cmdline mode, probably due to `config/options.lua` settings,
          -- for wildmenu.
          selection = {
            -- When `true`, automatically select first item in completion list.
            -- Default: `true`.
            -- Makes no difference, as `<c-y>` anyways selects first item.
            -- First item not auto-inserted, even if `auto_insert` is `true`.
            -- preselect = function(ctx)
            --   return ctx.mode ~= "cmdline"
            -- end,

            -- When `true`, insert completion item automatically when selecting it,
            -- use `<C-e>` to both undo selection and hide completion menu.
            -- Default: `true`.
            -- auto_insert = function(ctx)
            --   return ctx.mode ~= "cmdline"
            -- end,
            auto_insert = false,
          },
        },

        menu = {
          -- Better looking without border.
          border = "rounded",

          cmdline_position = function()
            if vim.g.ui_cmdline_pos ~= nil then
              local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
              return { pos[1] - 1, pos[2] }
            end
            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
            return { vim.o.lines - height, 0 }
          end,

          draw = {
            -- Show `kind_icon` and `label`, i.e. name, on LHS of completion menu,
            -- and `kind`, i.e. type as text, e.g. `Snippet`, on RHS.
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              -- { "kind" },
            },

            -- Use treesitter to highlight `label.text`.
            -- Prefer `colorful-menu`, see below.
            treesitter = { "lsp" },

            components = {
              -- Use `mini.icons` for `kind_icon.text+highlight`,
              -- i.e. icon itself and its color.
              -- kind_icon = {
              --   text = function(ctx)
              --     local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
              --     return kind_icon
              --   end,
              --   highlight = function(ctx)
              --     local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              --     return hl
              --   end,
              -- },

              -- Use `nvim-web-devicons` for `kind_icon.text+highlight`,
              -- i.e. icon itself and its color, if completion item is a file path,
              -- otherwise use own icon (not lspkind).
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local kind_icon, _, is_default = require("mini.icons").get("file", ctx.label)
                    vim.print(ctx.label)
                    if not is_default then
                      icon = kind_icon
                    else
                      icon, _, _ = require("mini.icons").get("directory", ctx.label)
                    end
                  end

                  return icon .. ctx.icon_gap
                end,

                highlight = function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local _, kind_hl, is_default = require("mini.icons").get("file", ctx.label)
                    if not is_default then
                      hl = kind_hl
                    else
                      _, hl, _ = require("mini.icons").get("directory", ctx.label)
                    end
                  end
                  return hl
                end,
              },

              -- `colorful-menu`:
              -- - Modifies label to also include surrounding context,
              --   e.g. rest of function, and highlights both label and context.
              -- - Does not work well, avoid.
              -- label = {
              --   text = function(ctx)
              --     return require("colorful-menu").blink_components_text(ctx)
              --   end,
              --   highlight = function(ctx)
              --     return require("colorful-menu").blink_components_highlight(ctx)
              --   end,
              -- },
              --
              -- label = {
              --   text = function(ctx)
              --     local highlights_info = require("colorful-menu").blink_highlights(ctx)
              --     if highlights_info ~= nil then
              --       -- Can add more information to label.
              --       return highlights_info.label
              --     else
              --       return ctx.label
              --     end
              --   end,
              --   highlight = function(ctx)
              --     if vim.tbl_contains({ "Path" }, ctx.source_name) then
              --       local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
              --       if dev_icon then
              --         return dev_hl
              --       end
              --     end
              --     local highlights = {}
              --     local highlights_info = require("colorful-menu").blink_highlights(ctx)
              --     if highlights_info ~= nil then
              --       highlights = highlights_info.highlights
              --     end
              --     for _, idx in ipairs(ctx.label_matched_indices) do
              --       table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
              --     end
              --     return highlights
              --   end,
              -- },

              -- label = {
              --   -- text = function(item)
              --   --   return item.label
              --   -- end,
              --   highlight = function(ctx)
              --     local hl = ctx.kind_hl
              --     if vim.tbl_contains({ "Path" }, ctx.source_name) then
              --       local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
              --       if dev_icon then
              --         hl = dev_hl
              --       end
              --     end
              --     return hl
              --   end,
              -- },

              -- Use `mini.icons` for `kind.highlight`, i.e. kind as text,
              -- so it matches icon color.
              -- kind = {
              --   -- (optional) use highlights from mini.icons
              --   highlight = function(ctx)
              --     local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              --     return hl
              --   end,
              -- },

              -- Use `nvim-web-devicons` for `kind.highlight`, i.e. kind as text,
              -- if completion item is a file path, otherwise use built-in kind color.
              -- kind = {
              --   highlight = function(ctx)
              --     local hl = ctx.kind_hl
              --     if vim.tbl_contains({ "Path" }, ctx.source_name) then
              --       local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
              --       if dev_icon then
              --         hl = dev_hl
              --       end
              --     end
              --     return hl
              --   end,
              -- },
            },
          },
        },

        ghost_text = {
          -- - Show entries from completion menu as ghost text.
          -- - Interferes with Copilot suggestions if those also shown as ghost text.
          -- - Thus, only enable `blink.cmp` ghost text below, if Copilot suggestions are
          --   ONLY shown as entries in `blink.nvim` completion menu, NOT as ghost text.
          -- - See: `plugins/addons/ai.lua` | `plugins/blink.lua` | `config/options.lua`.
          enabled = vim.g.ai_cmp,

          -- Only show ghost text when menu is closed.
          show_with_menu = false,
        },

        -- trigger = {
        -- By default, `blink.cmp` blocks newline, tab, and space trigger characters.
        -- Disable that behavior, to allow menu to show on whitespace (for Copilot suggestions).
        -- show_on_blocked_trigger_characters = {},
        -- },
      },

      fuzzy = {
        -- NOTE: To make sorting work: `fuzzy.implementation = 'lua'`.
        -- implementation = "lua",
        implementation = "prefer_rust_with_warning",

        -- -------------------------------
        -- LSP completion items.
        -- -------------------------------
        -- 1. LSP client sends `textDocument/completion` request, with `CompletionParams`, to LSP server.
        -- 2. LSP server responds with: `CompletionItem[]` | `CompletionList` | `null`.
        --
        -- Trigger characters:
        -- - LSP client sets default trigger characters: `[a-zA-Z]`.
        -- - LSP server can define addition trigger characters.
        -- - JS/TS: Server typically inlcudes `.` as trigger character.
        --
        -- - `CompletionItem` from LSP server:
        --   - `label`:
        --     - Text to display in completion menu.
        --     - By default, used as `insertText` (see below).
        --   - `labelDetails`:
        --     - `detail`     : If defined, insert after `label`, when selecting item.
        --     - `description`: If defined, insert after `labelDetails.detail`, when selecting item.
        --   - `kind`:
        --     - Kind of completion item.
        --     - Default kinds:
        --       export namespace CompletionItemKind {
        --         export const Text = 1;
        --         export const Method = 2;
        --         export const Function = 3;
        --         export const Constructor = 4;
        --         export const Field = 5;
        --         export const Variable = 6;
        --         export const Class = 7;
        --         export const Interface = 8;
        --         export const Module = 9;
        --         export const Property = 10;
        --         export const Unit = 11;
        --         export const Value = 12;
        --         export const Enum = 13;
        --         export const Keyword = 14;
        --         export const Snippet = 15;
        --         export const Color = 16;
        --         export const File = 17;
        --         export const Reference = 18;
        --         export const Folder = 19;
        --         export const EnumMember = 20;
        --         export const Constant = 21;
        --         export const Struct = 22;
        --         export const Event = 23;
        --         export const Operator = 24;
        --         export const TypeParameter = 25;
        --       }
        --     - `sortText`:
        --       - String used to sort this item against other items.
        --       - If not defined, `label` is used.
        --     - `filterText`:
        --       - String used to filter this item against other items, when typing in IDE.
        --       - If not defined, `label` is used.
        --     - `insertText`:
        --       - String inserted into document when this completion item is selected.
        --       - If not defined, `label` is used.
        --     - `insertTextFormat`:
        --        - Defines if item is plain text or snippet.
        --     - Several others.

        -- -------------------------------
        -- `blink.cmp` > `fuzzy.sorts`.
        -- -------------------------------
        -- - Controls sorting of completion items.
        -- - If one entry of `sorts` returns `nil`, `blink.cmp` continues to next entry.
        -- - Accepts:
        --   - Built-in strings.
        --   - Function(s): Works like Lua's `table.sort`.
        -- - `exact`:
        --   - Sort by exact match.
        --   - Case-sensitive.
        -- - `score`:
        --   - Sort by fuzzy matching score.
        --   - Determined by `blink.nvim`.
        --   - Uses: Frequency (previous select count) | proximity.
        -- - `sort_text`:
        --   - Sort by `sortText` property from LSP.
        --   - `sortText`: Returned by LSP server as part of `textDocument/completion` response.
        --   - `sortText`: String used when comparing this item with other items.
        --   - When `sortText` omitted from LSP response, `label` used for sorting.
        -- - `label`:
        --   - Sort by `label` field from completion item, e.g. from LSP server.
        --   - Deprioritizes items with leading `_`.
        -- - `kind`:
        --   - Sort by numeric `kind` field, defined in LSP (protocol).
        --   - See list above.
        --
        -- - NOTE:Entry in `sorts` returns `nil` if two items have same weight,
        --        thus next entry in `sorts` determines sorting among items with equal
        --        parent weight.

        -- Boost score of most recently/frequently used items.
        -- Note: Does not apply when using Lua implementation.
        -- Default: `true`.
        -- use_frecency = false,

        -- Boosts score of items matching nearby words.
        -- Note: Does not apply when using Lua implementation.
        -- Default: `true`.
        -- use_proximity = false,

        -- UNSAFE!! When enabled, disables lock and fsync when writing to frecency database.
        -- Should only be used on unsupported platforms (i.e. alpine termux).
        -- Note: Does not apply when using Lua implementation.
        -- Default: `false`.
        -- use_unsafe_no_lock = false,

        -- sorts = {
        -- Always prioritize exact matches, case-sensitive.
        -- "exact",

        -- Pass function for custom behavior.
        -- function(item_a, item_b)
        --   return item_a.score > item_b.score
        -- end,

        -- Sort snippets last.
        -- function(a, b)
        --   if (a.kind == nil or b.kind == nil) or (a.kind == b.kind) then
        --     return
        --   end
        --   return b.kind == 15
        -- end,

        -- Sort by Fuzzy matching score.
        -- "score",

        -- Sort by `sortText` field from LSP server, defaults to `label`.
        -- `sortText` often differs from `label`.
        -- "sort_text",

        -- Sort by `label` field from LSP server, i.e. name in completion menu.
        -- Needed to sort results from LSP server by `label`,
        -- even though protocol specifies default value of `sortText` is `label`.
        -- "label",
        -- },
      },

      -- Experimental signature help support.
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      -- Cmdline completion, applies to:
      -- - `:`: Command line completion.
      -- - `/`: Search completion.
      -- - `?`: Search completion.
      -- - `!`: Shell command completion.
      cmdline = {
        -- enabled = false,
        sources = { "cmdline" },
        completion = { menu = { auto_show = true } },
        keymap = {
          -- Recommended when auto_show completion menu,
          -- as default keymap will only show and select next item.
          ["<Tab>"] = { "show", "accept" },
        },
      },

      -- - List of enabled providers.
      -- - Extendable through other `blink.cmp` specs, due to `opts_extend`,
      --   e.g. below for `lazydev` provider.
      -- - By default, `blink.cmp` uses snippets from `friendly-snippets`,
      --   and `~/.config/nvim/snippets`.
      sources = {
        -- `default`:
        -- - Static list of enabled providers, or function to dynamically
        --   enable/disable providers based on context.
        -- - Remove 'buffer' to skip text completions, by default it is only enabled
        --   when LSP returns no items.
        default = { "lsp", "path", "snippets", "buffer" },

        -- `per_filetype`:
        -- - Define providers per filetype
        -- per_filetype = {
        --   lua = { 'lsp', 'path' },
        -- },

        -- `transform_items`:
        -- - Function to transform items before returned, for all providers.
        -- - Default function lowers score for snippets, to sort them lower in list.
        -- transform_items = function(_, items)
        --   return items
        -- end,

        -- `min_keyword_length`:
        -- - Minimum number of characters in keyword to trigger any provider.
        -- - May also be `function(ctx: blink.cmp.Context): number`.
        -- - Default: `0`.
        -- min_keyword_length = 0,

        -- `providers`:
        -- - Configuration for each provider.
        providers = {
          -- Only needed when using command line completion.
          cmdline = {
            min_keyword_length = function(ctx)
              -- Only auto-show completion menu after typing 3 characters or more than one word.
              if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
                return 3
              end
              return 0
            end,
          },

          -- - Remove `Keyword` items from LSP completion results,
          --   e.g. `if`, `else`, `for`, etc.
          -- - Use snippets instead.
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Keyword
              end, items)
            end,
          },

          -- Activate completion menu on whitespace, currently not working.
          -- lsp = {
          --   override = {
          --     get_trigger_characters = function(self)
          --       local trigger_characters = self:get_trigger_characters()
          --       vim.list_extend(trigger_characters, { "\n", "\t", " " })
          --       return trigger_characters
          --     end,
          --   },
          -- },

          -- - Activate different providers after specific number of characters,
          --   so snippets are easy to find after just typing one character,
          --   and all lsp results only show after typing two characters.
          -- - Not useful, as c-space does not work.
          -- path = {
          --   min_keyword_length = 0,
          -- },
          --
          -- lsp = {
          --   min_keyword_length = 2, -- Number of characters to trigger porvider
          --   score_offset = 0, -- Boost/penalize the score of the items
          -- },
          --
          -- buffer = {
          --   min_keyword_length = 5,
          --   max_items = 5,
          -- },
        },
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
      -- Setup compat sources.
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- Add inline_completion to `cmp` actions, called below.
      MyVim.cmp.actions.inline_completion = function()
        if vim.lsp.inline_completion.get() then
          return true
        end
      end

      -- ==========================================
      -- `<Tab>` behavior.
      -- ==========================================
      -- - `sidekick.lua`
      --   - Not sure if the below covers normal mode.
      --   - Thus, setup `<Tab>` there as well, for normal mode.
      --
      -- - `MyVim.cmp.lua`
      --   - `snippet_forward`, `snippet_backward`, and other functions are added to
      --     `MyVim.cmp.actions` table.
      --   - Snippet functions move forward and backward in snippet ONLY if snippet is active,
      --     i.e. being filled in on screen, otherwise does nothing.
      --   - No need to include `snippet_forward` on `<Tab>`, in e.g. `sidekick`
      --     `keys`, as `default` `blink.cmp` preset above handles it.
      --   - Still, include to be safe.
      --
      -- - Thus, `<Tab>` calls these functions, in sequence:
      --   - If snippet visible: `snippet_forward`, to move forward to next snippet input.
      --   - `sidekick.nes_jump_or_apply()`.
      --   - `ai_accept` function, if added to `MyVim.cmp.actions`.
      --   - `vim.inline_completion.accept()`.
      --   - `<tab>` fallback, i.e. inserts tab character.
      --
      -- - `plugins/copilot.lua`
      --   - Not used, using `vim.inline_completion` instead.
      --   - Before
      --     - `ai_accept` function was added to `MyVim.cmp.actions` table.
      --     - Accepted AI suggestion if visible, ONLY if Copilot suggestion is visible,
      --       which is always when typing, since `auto_trigger` is `true`,
      --       otherwise does nothing.
      --     - No longer applies.
      --
      if not opts.keymap["<Tab>"] then
        if opts.keymap.preset == "super-tab" then -- super-tab
          opts.keymap["<Tab>"] = {
            require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
            MyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            function()
              return vim.lsp.inline_completion.get()
            end,
            "fallback",
          }
        else
          -- - This condition applies, overwriting `Tab` in selected preset, i.e. `default`.
          -- - Land in this `else`, as not using `super-tab` preset.
          -- - Thus, `<Tab>` calls `snippet_forward` if snippet is visible,
          --   then `ai_nes` if Copilot suggestion is visible,
          --   then `inline_completion` if inline suggestion is visible,
          --   otherwise falls back to inserting tab character.
          opts.keymap["<Tab>"] = {
            MyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            function()
              return vim.lsp.inline_completion.get()
            end,
            "fallback",
          }
        end
      end

      -- Unset custom prop to pass `blink.cmp` validation.
      opts.sources.compat = nil

      -- Check if symbol kinds must be overwritten,
      -- needed by `ai/copilot.lua`.
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx
          print("Adding kind: " .. CompletionItemKind)

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

          -- Unset custom prop to pass blink.cmp validation.
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },

  -- Overwrite default icons with custom ones.
  -- Default icons:
  --   Text = '󰉿',
  --   Method = '󰊕',
  --   Function = '󰊕',
  --   Constructor = '󰒓',
  --
  --   Field = '󰜢',
  --   Variable = '󰆦',
  --   Property = '󰖷',
  --
  --   Class = '󱡠',
  --   Interface = '󱡠',
  --   Struct = '󱡠',
  --   Module = '󰅩',
  --
  --   Unit = '󰪚',
  --   Value = '󰦨',
  --   Enum = '󰦨',
  --   EnumMember = '󰦨',
  --
  --   Keyword = '󰻾',
  --   Constant = '󰏿',
  --
  --   Snippet = '󱄽',
  --   Color = '󰏘',
  --   File = '󰈔',
  --   Reference = '󰬲',
  --   Folder = '󰉋',
  --   Event = '󱐋',
  --   Operator = '󰪚',
  --   TypeParameter = '󰬛',
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = MyVim.config.icons.kinds

      -- Use block instead of icon for color items, to make swatches more usable.
      opts.appearance.kind_icons = vim.tbl_extend("keep", {
        Color = "██",
      }, MyVim.config.icons.kinds)
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

  -- Completion of conventional commits, i.e. `fix`, `feat`, etc.,
  -- in filetypes `gitcommit` | `markdown`.
  -- WARNING: Slows down completion menu, avoid.
  -- {
  --   "saghen/blink.cmp",
  --   opts = {
  --     sources = {
  --       default = { "conventional_commits" },
  --       providers = {
  --         conventional_commits = {
  --           name = "Conventional Commits",
  --           module = "blink-cmp-conventional-commits",
  --           enabled = function()
  --             -- Enable source for filetype: `gitcommit` | `markdown`.
  --             return vim.tbl_contains({ "gitcommit", "markdown" }, vim.bo.filetype)
  --           end,
  --           opts = {},
  --         },
  --       },
  --     },
  --   },
  -- },

  -- Completion of CSS variables.
  -- Scans project for css variables, using ripgrep, on boot.
  -- Thus, restart neovim to update variables.
  -- Not working.
  -- {
  --   "Saghen/blink.cmp",
  --   opts = {
  --     providers = {
  --       css_vars = {
  --         name = "css-vars",
  --         module = "css-vars.blink",
  --         opts = {
  --           search_extensions = { ".js", ".ts", ".jsx", ".tsx" },
  --         },
  --       },
  --     },
  --   },
  -- },

  -- Add git provider, allowing to search and insert following into commit messages in
  -- filetypes `octo` | `gitcommit` | `markdown`:
  -- - Commit hashes (`:`).
  -- - GitHub issues and pull request (`#`), users (`@`),
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "git" },
        providers = {
          git = {
            module = "blink-cmp-git",
            name = "Git",
            -- Enable source for filetype: `gitcommit` | `markdown` | `octo`.
            enabled = function()
              return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype)
            end,
            --- @module 'blink-cmp-git'
            --- @type blink-cmp-git.Options
            opts = {
              commit = {
                -- Customize when to enable commit source.
                -- The default will enable this when `git` is found and `cwd` is in a git repository
                -- enable = function() end
                -- Change triggers.
                -- triggers = { ':' },
              },
              git_centers = {
                github = {
                  -- Those below have the same fields with `commit`
                  -- Those features will be enabled when `git` and `gh` (or `curl`) are found and
                  -- remote contains `github.com`
                  -- issue = {
                  --     get_token = function() return '' end,
                  -- },
                  -- pull_request = {
                  --     get_token = function() return '' end,
                  -- },
                  -- mention = {
                  --     get_token = function() return '' end,
                  --     get_documentation = function(item)
                  --         local default = require('blink-cmp-git.default.github')
                  --             .mention.get_documentation(item)
                  --         default.get_token = function() return '' end
                  --         return default
                  --     end
                  -- }
                },
                -- gitlab = {
                -- Those below have the same fields with `commit`
                -- Those features will be enabled when `git` and `glab` (or `curl`) are found and
                -- remote contains `gitlab.com`
                -- issue = {
                --     get_token = function() return '' end,
                -- },
                -- NOTE:
                -- Even for `gitlab`, you should use `pull_request` rather than`merge_request`
                -- pull_request = {
                --     get_token = function() return '' end,
                -- },
                -- mention = {
                --     get_token = function() return '' end,
                --     get_documentation = function(item)
                --         local default = require('blink-cmp-git.default.gitlab')
                --            .mention.get_documentation(item)
                --         default.get_token = function() return '' end
                --         return default
                --     end
                -- }
                -- },
              },
            },
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
