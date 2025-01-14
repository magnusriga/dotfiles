_G.MyVim = require("util")

local M = {}

MyVim.config = M 

local defaults = {
  -- Colorscheme can be a string like `catppuccin` or a function that will load the colorscheme.
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- Load default settings.
  defaults = {
    autocmds = true,
    keymaps = true,
    -- config.options can't be configured here since that is loaded via import `plugins`,
    -- whose modules run before the autocmds herein.
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
  -- `kind_filter` is used to choose symbol types,
  -- for LSP symbol search.
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
    },
  },
}

M.json = {
  version = 7,
  path = vim.g.myvim_json or vim.fn.stdpath("config") .. "/myvim.json",
  data = {
    version = nil, ---@type string?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

function M.json.load()
  local f = io.open(M.json.path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      if M.json.data.version ~= M.json.version then
        MyVim.json.migrate()
      end
    end
  end
end

local options
local neovim_clipboard

function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults or {}, opts or {}) or {}

  -- When opening vim with a file, i.e. argument list,
  -- autocmds must be loaded right away,
  -- before lazy.nvim has finished loading plugins.
  local neovim_autocmds = vim.fn.argc(-1) == 0
  if not neovim_autocmds then
    M.load("autocmds")
  end

  -- Generally, load autocmds and keymaps after lazy.nvim has
  -- installed and loaded all plugins.
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

      MyVim.format.setup()
      -- MyVim.news.setup()
      MyVim.root.setup()

      vim.api.nvim_create_user_command("MyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

    end,
  })

  MyVim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load colorscheme.",
    on_error = function(msg)
      MyVim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
end

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
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      MyVim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  local pattern = "Neovim" .. name:sub(1, 1):upper() .. name:sub(2)
  -- if M.defaults[name] or name == "options" then
  --   _load("other.config." .. name)
  --   vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
  -- end
  _load("config." .. name)
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  -- `require("plugins.lsp.format")` will return `MyVim.format`.
  package.preload["plugins.lsp.format"] = function()
    return MyVim.format
  end

  -- Delay notifications until `vim.notify` was replaced,
  -- or use built-in `vim.notify` if `vim.notify` was not replaced after 500ms.
  MyVim.lazy_notify()

  -- Load options here, before lazy.nvim installs and loads plugins,
  -- i.e. before cloning from GitHub and subsequently running 
  -- `require(<name>)`.setup(opts)`,
  -- see `lazy-plugins.lua` for details.
  -- Needed to make sure options are correctly applied
  -- after installing missing plugins.
  M.load("options")

  -- Defer built-in clipboard handling,
  -- as "xsel" and "pbcopy" can be slow.
  neovim_clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  MyVim.plugin.setup()
  M.json.load()
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
