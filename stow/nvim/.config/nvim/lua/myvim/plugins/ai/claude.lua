return {
  -- {
  --   "greggh/claude-code.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim", -- Required for git operations
  --   },
  --   config = function()
  --     require("claude-code").setup({
  --       window = {
  --         position = "vertical",
  --         width = 35, -- Width of the window
  --         -- height = 20, -- Height of the window
  --         -- border = "rounded", -- Border style for the window
  --       },
  --     })
  --     vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })
  --   end,
  -- },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_width_percentage = 0.35,
      },
    },
    keys = {
      -- Add `which-key` group name.
      { "<leader>a", nil, desc = "AI/Claude Code" },

      -- Launch ClaudeCode.
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<c-/>", "<cmd>ClaudeCode<cr>", mode = "n", desc = "Toggle Claude" },

      -- - Swap to left window, with standard Neovim keybinding.
      -- - Removes `<c-w` to delete word in terminal, when in insert mode,
      --   as mode is only `t` and Insert/Normal mode, within terminal mode,
      --   is delivered by shell.
      {
        "<c-w>h",
        function()
          vim.schedule(function()
            vim.cmd("wincmd h")
          end)
        end,
        mode = "t",
        desc = "Focus Left",
      },

      -- - Move cursor to ClaudeCode window.
      -- - No need, use `<c-w>l` | `<c-w>w`.
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },

      -- `--continue`: Automaticlly continue most recent conversation.
      -- `--resume`: Show convestation picker.
      -- BUG: Does not currently work in `claudecode.nvim`.
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },

      -- Start ClaudeCode with current buffer as context.
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },

      -- Start ClaudeCode with visual selection as context.
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },

      -- Start ClaudeCode with file(s) from file explorere as context.
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },

      -- - Diff management.
      -- - Alternative:
      --   - Accept: `:w`
      --   - Reject: `:q`
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
