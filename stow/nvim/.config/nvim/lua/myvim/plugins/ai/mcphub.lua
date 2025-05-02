return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      -- Required for Job and HTTP requests.
      "nvim-lua/plenary.nvim",
    },
    -- Uncomment to load hub lazily.
    --cmd = "MCPHub",
    -- Installs required mcp-hub npm module.
    -- Done in dotfile scripts.
    build = "npm install -g mcp-hub@latest",
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    config = function()
      require("mcphub").setup()
    end,
  },
}
