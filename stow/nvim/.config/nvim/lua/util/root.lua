---@class myvim.util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m)
    return m.get()
  end,
})

---@class MyRoot
---@field paths string[]
---@field spec MyRootSpec

---@alias MyRootFn fun(buf: number): (string|string[])

---@alias MyRootSpec string|string[]|MyRootFn

---@type MyRootSpec[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

function M.detectors.cwd()
  return { vim.uv.cwd() }
end

-- - Returns list of root paths for current buffer, based on every attached LSP client's
--   `workspace_folders`, which defaults to `root_dir`, which for most typescript LSPs is
--   first ancestor with `tsconfig.json`.
-- - For typescript files, below function returns list of at least four identical paths,
--   one for each LSP client attached to typescript buffer, e.g. `vtsls`, `tailwind`,
--   `eslint`, `copilot`, etc.
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  local clients = MyVim.lsp.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients)
  for _, client in pairs(clients) do
    -- - `client.config`:
    --   - Copy of config passed into `vim.lsp.start()`.
    --   - Meaning, table passed into `require(nvim-lspconfig).setup(<table>)`,
    --     defined in `nvim-lspconfig` spec > `opts.servers.<server>`.
    --   - E.g. `addons/lang/typescript.lua` > `opts.servers.vtsls`,
    --     which `nvim-lspconfig` merges with its own `default_config` and
    --     `util.default_config`, latter being config for all servers.
    --
    -- - `vim.lsp.ClientConfig.workspace_folders`:
    --   - List of workspace folders passed to language server.
    --   - Default: `vim.lsp.ClientConfig.root_dir`.
    --   - Typically not set, i.e. equals `root_dir`.
    --
    -- - `vim.lsp.ClientConfig.root_dir`:
    --   - Set by `nvim-lspconfig` > `default_config`, or own `nvim-lspconfig` spec.
    --   - If `root_dir` not set, default to traverse file system upwards, using
    --     `vim.fs.root()`, from current directory, to `pyproject.toml` | `setup.py`.
    --
    -- - `nvim-lspconfig`:
    --   - Uses own `util.root_pattern(<files>)` to find root of project,
    --     which accepts array of filenames, and returns path to first match found.
    --   - Thus, order of filenames in `root_pattern` is important.
    --   - `vtsls`: root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')`.
    --   - Thus, `vtsls` uses first ancestor with `tsconfig.json` as both `root_dir` and
    --     `workspace_folders`, which is passed to language server as `workspaceFolders`.
    --     passed to language server as `root_uri`, and `workspace_folders`, passed to
    --
    -- - Important:
    --   - `root_dir` is used by Neovim built-in LSP client to send `workspaceFolders`,
    --     `rootUri` and `rootPath` to language server.
    --   - Language server only uses `workspaceFolders`, as `root_uri` and `root_path`
    --     are both deprecated.
    --   - Thus, `root_dir` is only important for `workspaceFolders`.
    --   - `workspaceFolders` can also be set with `ClientConfig.workspace_folders`,
    --     which would overwrite `root_dir` for `workspaceFolders` sent to language server.
    --
    -- - Monorepos.
    --   - Keep one workspace folder, instead of one per package.
    --   - Use `.git` as root pattern.
    --   - Matches VSCose behavior, where one folder is one workspace.
    --   - Just reorder `root_pattern` to have `.git` first.
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  -- Retuns list of paths, but only those that are prefixes of current buffer path,
  -- meaning they are root paths of current buffer.
  return vim.tbl_filter(function(path)
    path = MyVim.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

-- - Traverse file system upwards, from directory of current buffer, to find first file
--   OR directory that matches one of passed in patterns, e.g. `.git`, `lua`, etc.
-- - Patterns are full file -or directory name.
-- - Stops after first match, returning containing directory of file match,
--   or directory itself if directory match.
-- - Thus, returns path of first found `.git` | `lua` directory.
---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()

  local function check(pattern, name)
    if name == patterns then
      return true
    end
    if pattern:sub(1, 1) == "*" and name:find(vim.pesc(pattern:sub(2)) .. "$") then
      return true
    end
    return false
  end

  local pattern = vim.fs.find(function(name)
    if type(patterns) == "string" then
      if check(patterns, name) then
        return true
      end
    else
      for _, p in ipairs(patterns) do
        if check(p, name) then
          return true
        end
      end
    end
    return false
  end, { path = path, upward = true })[1]

  -- Return parent directory of first file found that matches one of passed in patterns,
  -- e.g. `.git`, `lua`, etc.
  return pattern and { vim.fs.dirname(pattern) } or {}
end

function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return MyVim.norm(path)
end

-- Receives: `spec`, i.e. `{ "lsp", { ".git", "lua" }, "cwd" }`.
-- Returns: Detector function, e.g. `MyRoot.detectors.lsp` | `MyRoot.detectors.pattern`.
---@param spec MyRootSpec
---@return MyRootFn
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

-- - Receives: Buffer, typically current buffer, and spec, using `vim.g.root_spec` |
--   `MyRoot.spec`, i.e. `{ "lsp", { ".git", "lua" }, "cwd" }`.
--
-- - Returns: List of root paths, for each spec, which each can return table of paths.
--
-- - Within each spec, paths are sorted alphabetically.
--
-- - Lsp: Returns list of workspace folders for each LSP client attached to buffer,
--   which is at least four identical paths for typescript buffer, e.g. `vtsls`,
--   `tailwind`, `eslint`, `copilot`, etc.
--
-- - Example output:
--  `{
--     { spec = "lsp", paths = { "/path/to/project", "/path/to/project", .. } },
--     { spec = ".git", paths = { "/path/to/project" } },
--   }`.
--
-- - Typically, `all = false`, thus only first spec entry is returned, i.e. `lsp`:
-- `{
--    { spec = "lsp", paths = { "/path/to/project", "/path/to/project", .. } },
--  }`.
---@param opts? { buf?: number, spec?: MyRootSpec[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type MyRoot[]
  for _, spec in ipairs(opts.spec) do
    -- - Runs one detector function for each spec, passing in current buffer,
    --   which returns root paths, e.g. `{ "/path/to/project" }`.
    -- - E.g. `MyRoot.detectors.lsp(<buf>)` | `MyRoot.detectors.pattern(<buf>)`.
    -- - `MyRoot.detectors.lsp(<buf>)` for `typescript` buffer returns at least four
    --   identical paths, one for each LSP client attached to typescript buffer,
    --   e.g. `vtsls`, `tailwind`, `eslint`, `copilot`, etc.
    local paths = M.resolve(spec)(opts.buf)

    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

function M.info()
  local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec

  local roots = M.detect({ all = true })
  local lines = {} ---@type string[]
  local first = true
  for _, root in ipairs(roots) do
    local root_spec = root.spec
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root_spec) == "table" and table.concat(root_spec, ", ") or root_spec
      )
      first = false
    end
  end
  lines[#lines + 1] = "```lua"
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
  lines[#lines + 1] = "```"
  MyVim.info(lines, { title = "MyVim Roots" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

-- Cache containing root paths for buffer,
-- indexed by buffer number.
---@type table<number, string>
M.cache = {}

-- Create usercommand to get root of buffer,
-- and autocommand to delete cache of buffer root paths.
-- TODO: Delete if not used.
function M.setup()
  vim.api.nvim_create_user_command("MyRoot", function()
    MyVim.root.info()
  end, { desc = "MyVim roots for the current buffer" })

  -- FIX: Doesn't properly clear cache in neo-tree `set_root` (which should happen presumably on `DirChanged`),
  -- probably because the event is triggered in the neo-tree buffer, therefore add `BufEnter`.
  -- Maybe this is too frequent on `BufEnter` and something else should be done instead??
  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("myvim_root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

-- ===========================
-- `get()`.
-- ===========================
-- - `detect()` returns table with only one entry, e.g. `lsp`, since `all = false`.
--
-- - Example output of `detect()`, with several entries:
--  `{
--     { spec = "lsp", paths = { "/path/to/project", "/path/to/project", .. } },
--     { spec = { ".git", "lua" }, paths = { "/path/to/project" } },
--     ...
--   }`.
--
-- - Each entry has path sorted alphabetically.
--
-- - `lsp` has several identical paths, one for each LSP client attached to buffer.
--
-- - `get()`:
--   - Finds root path of current buffer, based on `detect()` output.
--   - Uses `vim.g.root_spec` | `MyRoot.spec`: `{ "lsp", { ".git", "lua" }, "cwd" }`.
--   - Returns first path of from first spec, i.e. first path in `lsp` table.
--
-- - Thus, `get()` can return root path based on:
--   * Lsp workspace folders, of which root path of first attached LSP is chosen.
--   * Root path of first found `.git` | `lua` directory.
--   * Current working directory, as is.
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    local roots = M.detect({ all = false, buf = buf })
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end
  if opts and opts.normalize then
    return ret
  end
  return MyVim.is_win() and ret:gsub("/", "\\") or ret
end

-- Used by e.g. `fzf-lua` and `lazygit` keymaps, to find git root folder.
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

---@param opts? {hl_last?: string}
function M.pretty_path(opts)
  vim.print(opts)
  return ""
end

return M
