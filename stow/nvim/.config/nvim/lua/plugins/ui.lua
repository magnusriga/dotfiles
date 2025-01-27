return {
  -- Icons.
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Enables UI-related sub-modules from `snacks.nvim`.
  --
  -- To enable sub-plugin, either:
  -- - Specify sub-plugin configuration: `terminal = { <config> }`.
  -- - Use sub-plugin default configuration: `notifier = { enabled = true }`.
  --
  -- Main `snacks.nvim` spec, with more information: `plugins/init.lua`:
  {
    "snacks.nvim",
    opts = {
      --   indent = { enabled = true },
      --   input = { enabled = true },
      --   scope = { enabled = true },
      --   scroll = { enabled = true },
      --   statuscolumn = { enabled = false }, -- we set this in options.lua

      -- `toggle`:
      -- - Saves state of any function that can be toggled on|off, allowing easy toggling.
      -- - Manual usage: `Snacks.toggle.inlay_hints():toggle()`.
      -- - Keymap usage: `Snacks.toggle.inlay_hints():map("<leader>uh")`.
      -- - Works without config here, but set `config` to specify new `map` function.
      toggle = {
        -- `safe_keymap_set`: Creates keymap,
        -- but only if `lhs` and `modes` not already defined as keymap in `lazy.nvim`.
        map = MyVim.safe_keymap_set,
      },

      -- No need for `notifier`,
      -- use built-in `vim.notify`, or `noice.nvim` for custom notifications.
      -- notifier = { enabled = true },

      -- ==========================
      -- `Snacks.words`.
      -- ==========================
      -- - `vim.lsp.buf.document_highlight()`: Adds extmarks AND highlights for all symbols matching word under cursor, in current file only.
      -- - Symbols are defined by language, so e.g. cursor on `then` will highlight `if` and `end`.
      -- - `vim.lsp.buf.clear_references()`: Removes BOTH extmarks AND highlights for all symbols matching word under cursor, in current file.
      -- - `Snacks.words.enable()`: Schedules `vim.lsp.buf.document_highlight()` to run on `CursorMoved` | `CursorMovedI` | `ModeChanged`,
      --   debounced to not run more often than every 200 ms, immediately followed by `vim.lsp.buf.clear_references()`.
      -- - Result: `Snacks.words` highlight references within same file automatically when cursor moves, via `vim.lsp.buf.document_highlight()`,
      --   and allows jumping to those references using key bindings mapping to `Snacks.words.jump(<count>, [<cycle>])`.
      -- - `config.notify_jump` is `false` by default, set to `true` to run `vim.notify` at jump.
      --
      -- - All usage of `Snacks.words`:
      --   - { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
      --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      --   - { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
      --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
      --   - { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
      --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      --   - { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
      --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
      -- - If `Snacks.words` not enabled, keybindings above follow built-in behavior.
      --
      -- - Disabled by default, but enabled by passing config | `{ enabled = true }`.
      -- - Keep disabled, enable manually if needed: `Snacks.words.enable()`.
      -- words = { enabled = true },
    },

    -- No need for `notifier`,
    -- use built-in `vim.notify`, or `noice.nvim` for custom notifications.
    -- stylua: ignore
    -- keys = {
    --   { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    --   { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- },
  },
}
