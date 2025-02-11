_G.MyVim = require("util")

---@class MyVimConfig: MyVimOptions
local M = {}

MyVim.config = M

---@class MyVimOptions
local defaults = {
  -- Colorscheme can be string like `catppuccin` or function that will load colorscheme.
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- Load default settings.
  defaults = {
    autocmds = true,
    keymaps = true,
    -- `config.options` cannot be configured here, since it is loaded via import `plugins`,
    -- whose modules run before autocmds herein.
  },
  -- Icons used by plugins.
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  -- `kind_filter`: Used in LSP symbol search.
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    -- Specify different filter for each filetype.
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- Remove package since luals uses it for control flow structures.
      "Property",
      "Struct",
      "Trait",

      -- Also include these.
      "Object",
      "Array",
      "Variable",
      -- "Constant",
      -- "Number",
      -- "String",
      -- "Boolean",
    },
  },
}

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  local kind_filter_ft = M.kind_filter[ft]
  if type(kind_filter_ft) == "table" then
    return kind_filter_ft
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"  | "hlgroups"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      MyVim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  local pattern = "MyVim" .. name:sub(1, 1):upper() .. name:sub(2)

  -- Load file.
  _load("config." .. name)

  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

local options
local neovim_clipboard

-- `VeryLazy`: Event fired by `lazy.nvim`, after `lazy.nvim` is done installing and loading plugins.
--
-- 1. If Neovim started with arguments, i.e. files, load autocommands right away: `config/autocmds`.
--
-- 2. Create autocmd running on `VeryLazy` to:
--    a. Load autocmds from: `/config/autocmds`.
--    b. Load keymaps from: `/config/keymaps`.
--    c. Create autocmd and usercommand to format buffer,
--       using registered formatter, i.e. conform by filetype,
--       and any other registered non-primary formatters, like `eslint`.
--    d. Create usercommand to get root of buffer,
--       and autocommand to delete cache of buffer root paths.
--    e. Create usercommand to `checkhealth`.
--
-- 3. Set default colorscheme.
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults or {}, opts or {}) or {}

  -- When opening Neovim with file, i.e. argument list,
  -- `config/autocmds` must run right away, before `lazy.nvim`
  -- has installed and loaded plugins.
  local neovim_autocmds = vim.fn.argc(-1) == 0
  if not neovim_autocmds then
    M.load("autocmds")
  end

  -- Load autocmds and keymaps after `lazy.nvim` has
  -- installed and loaded all plugins, i.e. at `VeryLazy` event.
  local group = vim.api.nvim_create_augroup("NeovimSetup", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if neovim_autocmds then
        M.load("autocmds")
      end

      M.load("keymaps")
      if neovim_clipboard ~= nil then
        vim.opt.clipboard = neovim_clipboard
      end

      -- Create autocommand and usercommand to format buffer,
      -- using registered formatter, i.e. conform by filetype,
      -- and any other registered non-primary formatters, like `eslint`.
      MyVim.format.setup()

      -- Create usercommand to get root of buffer,
      -- and autocommand to delete cache of buffer root paths.
      MyVim.root.setup()

      -- Load highlight groups.
      M.load("hlgroups")

      -- Load symbols cahce feature.
      require("util.document_symbol")

      vim.api.nvim_create_user_command("MyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })
    end,
  })

  -- Attempt to load default colorscheme defined above, e.g. `tokyonight`,
  -- meant to run while plugins are installed and loaded,
  -- as `lazy.nvim` plugins, including `colorscheme.nvim`, has not loaded
  -- when this file runs.
  -- Defualt colorscheme is used until plugins are installed and loaded.
  MyVim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load default colorscheme.",
    on_error = function(msg)
      MyVim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
end

M.did_init = false

-- =============================================================================================
-- Program Flow.
-- =============================================================================================
-- 1. Top-level `init.lua` runs: `config/init.lua > setup()`.
--    - Load own `config/autocmd` immediately, if `nvim <file>...`, i.e. with arguments.
--    - Creates `VeryLazy` autocmd to:
--      - Load own `config/autocmd` and `config/keymaps`.
--      - Create autocmds and usercommands to format buffer, get buffer root, and check program health.
--    - Activates default colorscheme.
--      - Used before `lazy.nvim` installs and loads new colorscheme(s).
--
-- 3. Top-level `init.lua` runs: `require('config.lazy-plugins')`.
--    - `lazy.nvim` stores all specs, by running files in `plugins` directory. Order matters?
--    - When importing `plugins/init.lua`, call: `require('config).init()`.
--
-- 4. `require('config).init()`: See below.
--
-- 5. `lazy.nvim`:
--    - Installs plugins.
--    - Merges all `opts`, `keys`, `ft`, `events`, for plugins from same source.
--    - Loads plugins, i.e. runs `config` function passing in merged `opts`
--
-- Result:
-- - `plugins/init.lua` and `init()` below: Run before own autocmds and keymaps have been added,
--   which is before plugins are installed and loaded.
--
-- =============================================================================================
-- `init()`.
-- =============================================================================================
-- - Run from `plugins/init.lua`, which in turn runs when `lazy.nvim`
--   is gathering specs from imported directories, before any plugins are installed | loaded.
-- - Thus, `init()` runs before any plugins are installed and loaded.
--
-- 1. Delay all notifications for maximum 500ms, and replays them once `vim.notify` has
--    been replaced by `snacks.nvim`'s `notifier` | `noice.nvim`, or falls back to
--    original `vim.notify` if no replacement within 500ms (uses polling in separate thread).
-- 2. Load `config/options`, i.e. before plugins installed and loaded, and before own
--    `config/autocmds` and `config/keymaps` are exectued, latter happens at `VeryLazy` event.
-- 3. Replace `vim.opt.clipboard` with empty string, and reinstate at VeryLazy,
--    thus avoiding startup delay due to `xsel` | `pbcopy`.
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  -- Pause all notifications and start check handle, which checks in separate thread,
  -- once per event loop iteration, if `vim.notify` has been replaced.
  --
  -- Once replacement has happened, or 500ms has passed, run all delayed notifications,
  -- either using new `vim.notify`, or original `vim.notify` if replacement did not happen.
  --
  -- Actual replacement happens in `snacks.nvim`'s `notifier` | `noice.nvim`,
  -- thus those plugins must load within 500ms for notifications in first 500ms to be run by
  -- replaced `vim.notify`.
  MyVim.lazy_notify()

  -- Load options here, before `lazy.nvim` installs and loads plugins,
  -- i.e. before cloning from GitHub and subsequently running `require(<name>)`.setup(opts)`.
  -- Must happen before installing plugins, for some reason.
  M.load("options")

  -- - Defer built-in clipboard handling, as "xsel" and "pbcopy" can be slow,
  --   by saving `vim.opt.clipboard` to `neovim_clipboard`,
  --   and setting `vim.opt.clipboard`  to empty string.
  -- - Later, at `VeryLazy` event, i.e. after plugins installed and loaded,
  --   `vim.opt.clipboard` is set back to original value.
  --   See: `config/init.lua > setup()`.
  neovim_clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  -- Creates `LazyFile` and `User LazyFile` events, firing on built-in buffer read|write events:
  -- - `LazyFile`     : `BufReadPost` | `BufNewFile` | `BufWritePre`.
  -- - `User LazyFile`: `LazyFile`.
  MyVim.plugin.setup()
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    return options[key]
  end,
})

return M
