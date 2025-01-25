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
      --   notifier = { enabled = true },
      --   scope = { enabled = true },
      --   scroll = { enabled = true },
      --   statuscolumn = { enabled = false }, -- we set this in options.lua
      toggle = {
        -- `map`: Set to function that only sets keymap if `lhs` and `modes`
        -- are not already defined as keymap in `lazy.nvim`,
        -- Usage: `Snacks.toggle.inlay_hints():map("<leader>uh")`.
        map = MyVim.safe_keymap_set,
      },
      --  words = { enabled = true },
    },
    -- stylua: ignore
    -- keys = {
    --   { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    --   { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- },
  },
}
