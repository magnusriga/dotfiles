local lsp_name = "bashls"
-- vim.lsp.config(lsp_name, {
-- settings = {
--   shellcheck = {
--     enable = true,
--     executable = "shellcheck",
--     lintCommand = "shellcheck -f gcc -x",
--     lintIgnoreExitCode = true,
--   },
--   sh = {
--     shellcheck = { enable = true },
--   },
-- },
-- })

---@type string
local xdg_config = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"

---@param path string
local function have(path)
  return vim.uv.fs_stat(xdg_config .. "/" .. path) ~= nil
end

-- Language support for dotfiles.
return {
  -- `mason-lspconfig`:
  -- - Installs underlying LSP server program.
  -- - Automatically calls `vim.lsp.enable(..)`.
  {
    "mason-org/mason-lspconfig.nvim",
    -- Using `opts_extend`, see `plugins/mason.lua`.
    opts = { ensure_installed = { lsp_name } },
  },

  -- `shellcheck`: Linting for shell scripts.
  -- `shfmt`: Used by `bashls` for formatting.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Uses custom `ensure_installed`, see: `plugins/mason.lua`.
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "shellcheck", "shfmt" })
    end,
  },

  -- Add treesitter support, i.e. syntax highlighting, for various dotfiles.
  -- - `rasi`: Rofi configuration files.
  -- - `rofi`: Rofi configuration files.
  -- - `wofi`: Wofi configuration files.
  -- - `vifmrc`: Vifm configuration files.
  --
  -- - `waybar`: Waybar configuration files.
  -- - `mako`: Mako configuration files.
  -- - `kitty`: Kitty terminal configuration files.
  -- - `hyprlang`: Hypr configuration files.
  -- - `sh`: Shell scripts.
  --
  -- - `gitconfig`: Git configuration files.
  -- - `fish`: Fish shell configuration files.
  --
  --
  -- - `jsonc`: JSON with comments.
  -- - `dosini`: INI files.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Function to install treesitter language parser, for given language.
      local function add(lang)
        if type(opts.ensure_installed) == "table" then
          table.insert(opts.ensure_installed, lang)
        end
      end

      -- Set custom filetypes for specific files, by extension, filename, or pattern.
      vim.filetype.add({
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename = {
          ["vifmrc"] = "vim",
          [".shrc"] = "sh",
        },
        pattern = {
          [".*/.vscode/settings.json"] = "jsonc",
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/kitty/.+%.conf"] = "kitty",
          [".*/hypr/.+%.conf"] = "hyprlang",
          ["%.env%.[%w_.-]+"] = "sh",
        },
      })

      -- Use `bash` treesitter parser for filetype `kitty`.
      vim.treesitter.language.register("bash", "kitty")

      add("git_config")

      if have("hypr") then
        add("hyprlang")
      end

      if have("fish") then
        add("fish")
      end

      if have("rofi") or have("wofi") then
        add("rasi")
      end
    end,
  },
}
