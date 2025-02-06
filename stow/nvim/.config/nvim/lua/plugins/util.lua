-- Terminal mappings.
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  -- Enables utility sub-modules from `snacks.nvim`:
  -- - `bigfile`.
  -- - `quickfile`.
  -- - `terminal`.
  --
  -- To enable sub-plugin, either:
  -- - Specify sub-plugin configuration: `terminal = { <config> }`.
  -- - Use sub-plugin default configuration: `notifier = { enabled = true }`.
  --
  -- Main `snacks.nvim` spec, with more information: `plugins/init.lua`:
  {
    "snacks.nvim",
    opts = {
      -- Adds new filetype `bigfile` to Neovim, that triggers when file is larger than configured size, by default 1.5MB.
      -- Automatically prevents things like LSP and Treesitter attaching to buffer.
      -- Notification is shown when enabled.
      bigfile = { enabled = true },

      -- On `nvim <file>...`, render <file> before loading plugins.
      quickfile = { enabled = true },

      -- `Snacks.lazygit` does not require enabling with config, but done here to change colors.
      lazygit = {
        theme = {
          -- =======================================================================
          -- Defaults, from `snacks.nvim`.
          -- =======================================================================
          -- [241]                      = { fg = "Special" },
          -- activeBorderColor          = { fg = "MatchParen", bold = true },
          -- cherryPickedCommitBgColor  = { fg = "Identifier" },
          -- cherryPickedCommitFgColor  = { fg = "Function" },
          -- defaultFgColor             = { fg = "Normal" },
          -- inactiveBorderColor        = { fg = "FloatBorder" },
          -- optionsTextColor           = { fg = "Function" },
          -- searchingActiveBorderColor = { fg = "MatchParen", bold = true },
          -- selectedLineBgColor        = { bg = "Visual" }, -- set to `default` to have no background colour
          -- unstagedChangesColor       = { fg = "DiagnosticError" },
          -- =======================================================================

          -- [241] = { fg = "LazygitMain" },
          activeBorderColor = { fg = "LazygitActiveBorderColor", bold = true },
          -- cherryPickedCommitBgColor = { fg = "LazygitCherryPickedCommitBgColor" },
          -- cherryPickedCommitFgColor = { fg = "LazygitCherryPickedCommitFgColor" },
          -- defaultFgColor = { fg = "LazygitDefaultFgColor" },
          -- inactiveBorderColor = { fg = "LazygitInactiveBorderColor" },
          -- optionsTextColor = { fg = "LazygitOptionsTextColor" },
          -- searchingActiveBorderColor = { fg = "LazygitSearchingActiveBorderColor", bold = true },
          -- selectedLineBgColor = { bg = "LazygitSelectedLineBgColor" }, -- Set to `default` to have no background color.
          -- unstagedChangesColor = { fg = "LazygitUnstagedChangesColor" },
        },
      },

      -- Configuration for Snack's ability to toggle floating | split terminal windows.
      -- - No cmd: Bottom split, with winbar containing terminal title.
      -- - Cmd: Floating.
      terminal = {
        win = {
          -- Keys within terminal, e.g. to change terminal windows.
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
    },

    -- Keybindings to open scratch buffers, for testing code, creating notes, etc.
    -- Built into Snacks, cannot disable.
    -- stylua: ignore
    keys = {
      -- Use `<leader>.` for `fzf-lua.oldfiles`.
      -- { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    },
  },

  -- Session management to save session in background,
  -- keeping track of open buffers, window arrangement, and more.
  -- Restore sessions when returning through dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- Library used by other plugins.
  { "nvim-lua/plenary.nvim", lazy = true },
}
