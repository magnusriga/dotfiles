-- Close all Snacks automatically, when quitting last non-snacks window.
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local snacks_windows = {}
    local floating_windows = {}
    local windows = vim.api.nvim_list_wins()
    for _, w in ipairs(windows) do
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(w) })
      if filetype:match("snacks_") ~= nil then
        table.insert(snacks_windows, w)
      elseif vim.api.nvim_win_get_config(w).relative ~= "" then
        table.insert(floating_windows, w)
      end
    end
    if 1 == #windows - #floating_windows - #snacks_windows then
      -- Should quit, so we close all Snacks windows.
      for _, w in ipairs(snacks_windows) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})

-- `snacks.nvim` file explorer.
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    -- `snacks.nvim` file explorer options.
    -- Empty means default configuration.
    explorer = {},
    -- `snacks.nvim` picker options, for explorer source.
    -- Empty means default configuration.
    picker = {
      sources = {
        -- ---@type snacks.picker.explorer.Config: snacks.picker.files.Config|{}
        explorer = {
          hidden = true,
          -- ignored = false,
          ignored = true,
          -- follow_file = false,
        },
        grep = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = MyVim.root() })
        vim.schedule(function()
          vim.api.nvim_feedkeys("zz", "m", false)
        end)
      end,
      desc = "Explorer (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer (cwd)",
    },
    -- {
    --   "<leader>f-",
    --   function()
    --     Snacks.explorer.reveal()
    --   end,
    --   desc = "Explorer (Reveal, cwd)",
    -- },
    { "<leader>e", "<leader>fe", desc = "Explorer (Root Dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer (cwd)", remap = true },
    -- { "<leader>-", "<leader>f-", desc = "Explorer (Reveal, cwd)", remap = true },
  },
}
