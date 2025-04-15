-- ===========================
-- Notes.
-- ===========================
-- ---------------------------
-- - Libuv.
-- ---------------------------
-- - Libuv is a C library that provides event loop, networking,
--   and file system functionality.
-- - Libuv is used by Node.js, Neovim, and others.
-- - Libuv is used to handle asynchronous I/O operations, i.e. operations that take
--   time to complete, and thus would block main thread if done synchronously.
-- - Libuv is accessed in Neovim through `vim.uv`, which is Lua wrapper around libuv.
-- - If `vim.uv` has callback, it is asynchronous, meaning execution is deferred to
--   at least next libuv loop iteration.
-- - After async function has completed, passed in callback is executed.
-- - Examples of synchronous functions:
--   - `uv.spawn("cat", { stdio = {stdin, stdout, stderr})`:
--     Initialize process handle and start process.
-- - Examples of asynchronous functions:
--   - `uv.read_start({stream}, {callback})`: Read data from file.
--   - `uv.write({stream}, {data} [, {callback}])`: Write data to stream.
-- - Event loop is central part of libuv's functionality
--   - Takes care of polling for I/O.
--   - Schedules callbacks to be run based on different sources of events.
--   - In luv, implicit uv loop for every Lua state that loads the library.
--
-- ---------------------------
-- - stdio.
-- ---------------------------
-- - Every process gets its own standard streams, i.e. stdin, stdout, and stderr.
-- - Two processes can communicate with each other, by connecting  stdout of
--   one process with stdin of another process, just as is done with pipe operator
--   in shell.
-- - Example: Neovim's built-in LSP client communicates with language server over
--   stdio, meaning language server listens on its stdin for messages from Neovim,
--   and sends responses back to Neovim over its stdout, which Neovim listens to.
-- - Communication presumably done with Libuv, via `uv.write/read`, thus can be
--   asynchronous.
--
-- ---------------------------
-- - Coroutines.
-- ---------------------------
-- - Coroutines are like threads, as coroutines have own separate stack and instruction
--   pointer.
-- - Coroutines are unlike threads, as coroutines are collaborative, i.e. program only
--   runs ONE coroutine at any given time, and `resume` | `yield` swaps between initial
--   thread and coroutine, they do not run concurrently.
-- - Yield can happan at any level inside coroutine, i.e. funciton passed as callback to
--   `wrap` | `create`, it will always then pass execution back to initial thread.
-- - Coroutine, i.e. function passed in, is started by calling functin returned by
--   `coroutine.wrap`, or `coroutine.resume(co, fn)`, where `co` is previously created
--   coroutine, and `fn` is function to run in separate thread.
-- - First time `resume` is called, execution of coroutine function starts.
-- - First encountered `yield` inside coroutine function, will return to function which
--   called `resume`.
-- - Next time `resume` is called on same coroutine, remember specific coroutine is
--   passed to `resume`, execution picks up where last called `yield` left off.
-- - In case of nested coroutines, inner `resume` will start new coroutine, and inner
--   `yield` will return execution to outer coroutine.
-- - Seems like `yield` inside certain coroutine always yields execution to thread one
--   level up.
--
-- ===========================

local uv = vim.uv or vim.loop
local fzf_lua = require("fzf-lua")
local core = require("fzf-lua.core")
-- local path = require("fzf-lua.path")
local utils = require("fzf-lua.utils")
local config = require("fzf-lua.config")
local actions = require("fzf-lua.actions")
local make_entry = require("fzf-lua.make_entry")

local function check_capabilities(handler, silent)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  local num_clients = 0

  for _, client in pairs(clients) do
    if client:supports_method(handler.method) then
      num_clients = num_clients + 1
    end
  end

  if num_clients > 0 then
    return num_clients
  end

  -- UI won't open, reset the CTX.
  core.__CTX = nil

  if utils.tbl_isempty(clients) then
    if not silent then
      utils.info("LSP: no client attached")
    end
    return nil
  else
    if not silent then
      utils.info("LSP: server does not support " .. handler.method)
    end
    return false
  end
end

-- Handler, called after all clients have responded.
local function async_lsp_handler(co, handler, opts)
  return function(err, result, context)
    -- Increment callback & result counters.
    opts.num_callbacks = opts.num_callbacks + 1
    opts.num_results = (opts.num_results or 0) + (result and utils.tbl_count(result) or 0)
    if err then
      -- vim.print("Request done with error, callback executing.")
      if not opts.silent then
        utils.err(string.format("Error executing '%s': %s", handler.method, err))
      end
      -- Resume coroutine after failed LSP request, i.e. proceed to next client or
      -- finish `content` if last client, with request `err` passed to `coroutine.yield`,
      -- where request can be resent or error ignored.
      coroutine.resume(co, true, err)
    else
      -- vim.print("Request done successfully, callback executing.")
      -- `done` is `true` when all clients sent back their responses.
      local done = opts.num_callbacks == opts.num_clients
      -- Resume coroutine after successful LSP request, i.e. proceed to next client or
      -- finish `content` if last client, with request `result` passed to `coroutine.yield`.
      coroutine.resume(co, done, err, result, context)
    end
  end
end

-- Variable to store cancel function from `buf_request`,
-- reset to `nil` when all LSP requests are done, so cancellation only occurs
-- when LSP request is in process.
local _cancel_all = nil

-- Cancel callback, used every time symbol list is requested.
local fn_cancel_all = function()
  if _cancel_all then
    vim.notify("Cancelling all LSP requests.")
    _cancel_all()
    _cancel_all = nil
  end
end

local function gen_lsp_contents(opts)
  assert(opts.lsp_handler)
  opts.magnus = "magnus"

  -- Save local copy of lsp parameters and handler,
  -- otherwise are overwritten when calling generator more than once.
  local lsp_params, lsp_handler = opts.lsp_params, opts.lsp_handler

  -- Build positional params for LSP query from context buffer and cursor position.
  if not lsp_params then
    lsp_params = function(client)
      --- @class lsp.TextDocumentPositionParams
      local params = vim.lsp.util.make_position_params(core.CTX().winid, client and client.offset_encoding or "utf-8")
      params.context = {
        includeDeclaration = opts.includeDeclaration == nil and true or opts.includeDeclaration,
      }
      return params
    end
  end

  -- ---------------------------
  -- - How it works.
  -- ---------------------------
  -- - `vim.lsp.buf_request` sends async rpc request, meaning it runs in separate thread.
  --   - Multiple threads do not typically run concurrently, but CPU swaps between them
  --     fast, thus similar to parallel operations.
  --   - Getting response from language server takes time, thus rpc is async.
  -- - Could now pass handler into rpc, which calls `fzf_cb` for reach element in response
  --   from language server, which adds lines to fzf, which - Handler also runs async from
  --   main thread.
  -- - Alternatively, only do some basic additions to `opts` inside handler,
  --   and create `coroutine` within which handler runs and lines are added.
  -- - In latter approach, must await, i.e. yield, before adding lines, until LSP response
  --   returns, during which Neovim is responsive.
  -- - If handler also added lines, get same non-blocking effect.

  opts._fn_post_fzf = fn_cancel_all

  opts.__contents = function(bufnr)
    -- Call coroutine right away, to immediately start executing callback with separate
    -- call stack, allowing swapping back and forth between initial thread and coroutine.
    coroutine.wrap(function()
      local co = coroutine.running()

      -- Save no. of attached clients **supporting the capability**
      -- to determine if all callbacks were completed (#468).
      local async_opts = {
        num_results = 0,
        num_callbacks = 0,
        num_clients = check_capabilities(lsp_handler, opts.silent),
        -- Signals the handler to not print a warning when empty result set
        -- is returned, important for `live_workspace_symbols` when the user
        -- inputs a query that returns no results.
        -- Also used with `finder` to prevent the window from being closed.
        no_autoclose = opts.no_autoclose or opts.fn_reload,
        silent = opts.silent or opts.fn_reload,
      }

      -- Cancel all lingering LSP queries before starting new.
      fn_cancel_all()

      local async_buf_request = function()
        -- ---------------------------
        -- - `buf_request`.
        -- ---------------------------
        -- - `buf_request` sends async request, thus execution comes back here immediately.
        -- - Async is different from `coroutines`, as async implies parallel execution,
        --   or at least seemingly parallel if one CPU core, where CPU rapidly switches
        --   between threads, whereas in `coroutines` manual swapping between threads with
        --   `yield` and `resume`.
        -- - Save cancel all `fnref` to enable cancelling of all requests when using
        --   `live_ws_symbols`
        -- - Send async `textDocument/documentSymbol` request, for all clients attached to
        --   current buffer.
        -- - `lsp_handler` only passed into request, for error message purposes,
        --   otherwise not used.
        -- - Passed in callback, i.e. function returned by `async_lsp_handler`,
        --   is called like this:
        --   - handler(err, result, {
        --       method = method,
        --       client_id = self.id,
        --       bufnr = bufnr,
        --       params = params,
        --       version = version,
        --     })
        --   - `result`: Response from language server, i.e. `result` table with list of
        --     symbols, is returned by `corouting.resume`, which can be retreived by
        --     `coroutine.yield`, see below.
        -- - Passed in handler does this:
        --   - Sets: `opts.num_callbacks = opts.num_callbacks + 1`.
        --   - Sets: `opts.num_results = (opts.num_results or 0) + (result and
        --     utils.tbl_count(result) or 0)`.
        --   - Calls `coroutine.resume(co, done, err, result, context)`, so yield below
        --     returns those values.
        --
        -- ---------------------------
        -- - Cancellation.
        -- ---------------------------
        -- - `buf_request` returns function that cancels all ongoing requests.
        -- - Called when `store_symbols` is called.
        _, _cancel_all = vim.lsp.buf_request(
          core.CTX().bufnr,
          lsp_handler.method,
          lsp_params,
          async_lsp_handler(co, lsp_handler, async_opts)
        )
      end

      -- - If `async_buf_request` is run immediately, async nature of `buf_request`
      --   would still ensure execution continues here before handler runs.
      -- - However, add function to top of call stack, so it is executed when event loop
      --   is done with existing call stack.
      -- - Avoids error when coroutines are nested, i.e. when using 'finder':
      --   E5560: nvim_exec_autocmds must not be called in a lua loop callback nil
      if vim.in_fast_event() then
        vim.schedule(function()
          async_buf_request()
        end)
      else
        async_buf_request()
      end

      -- Process results from all LSP clients.
      local err, result, context, done

      -- ---------------------------
      -- - What happens.
      -- ---------------------------
      -- - Add lines separately for each client.
      -- - 1. Yield until first client responds, i.e. handler runs first time.
      -- - 2. Call `symbol_handler`, passing in `cb` callback.
      -- - 3. `symbol_handler` calls `cb` callback once per item from language server,
      --      after converting item into symbol line to add to `fzf`.
      -- - 4. When `cb` is called, once per symbol, call:
      --      `fzf_cb(e, function coroutine.resume(co) end)`, which adds line to fzf
      --      with `uv.write(e, function coroutine.resume(co) end)`.
      -- - 5. Since `uv.write` is asynchronous, using Libuv, `resume` is not called
      --      immediately, and execution continues to `yield`, where it halts until
      --      `uv.write` has completed writing one line and then calls `resume`.
      -- - 6. On `yield` inside `cb`, in loop at end of `symbol_handler`, execution is
      --      passed back to Neovim, to ensure Neovim remains responsive while waiting for
      --      `uv.write` to complete writing one line of data.
      -- - 7. Once `uv.write` completes, `resume` is called, and execution continues from
      --      `yield` line, inside `symbol_handler` loop, continues to next item from
      --      language server, continuing until all items, i.e. all symbols, have been
      --      added to fzf as individual lines.
      -- - 8. Once all lines from one client have been written into fzf, loop continues to
      --      top-level `yield`, which pause until next client has gotten response from
      --      its language server, and thus called `resume` in handler.
      --
      -- - QUESTION: What happens if LSP client calls handler, i.e. `resume`,
      --   before `uv.write` has completed writing lines into fzf, and thus that
      --   `resume` interferes with resume in `cb`?
      --
      -- - Alternatively, use `vim.lsp.buf_request_all`, which wraps handler in new
      --   handler, that only calls original handler once all attached LSP clients have
      --   finised, passing in combined `results` table with different signature from
      --   `result` passed to singular-client handler.
      -- - Stick with `fzf-lua` implementation, as `symbol_handler` only accepts
      --   ONE client result.
      -- - Otherwise, if not for signature of `symbol_handler`, could use
      --   `vim.lsp.buf_request_all`, as it is also async, and thus execution
      --   is returned to Neovim while gathering results from language server.
      repeat
        -- - `yield`: Similar to `await` promise in JavaScript, i.e. execution paused until
        --   `coroutine.resume` is called, which is similar to `resolve` in JavaScript.
        -- - Instead of async function, i.e. `buf_request` returning promise,
        --   which can be awaited, `yield` only occurs inside coroutine,
        --   so no need to keep track of promise, to know where to continue executing
        --   when `coroutine.resume` is called.
        -- - `yield` returns arguments passed into corresponding `coroutine.resume`.
        -- - `done`: `true` when all client have sent responses.
        done, err, result, context = coroutine.yield()

        if not err and type(result) == "table" then
          local cb = function(e)
            -- Instead of calling fzf_cb to add entries as lines in fzf,
            -- store entries in `vim.b.symbols`.
            local symbols = vim.b[bufnr].symbols or {}
            symbols[#symbols + 1] = e
            vim.b[bufnr].symbols = symbols
            vim.b[bufnr].symbols_opts = opts
          end
          -- Calls `symbol_handler`, which only uses `opts`, `cb`, and `result`,
          -- not `method`, `context`, or `{}`, calling `cb` once per item, i.e. symbol,
          -- from language server, to add each item as symbol line to fzf.
          lsp_handler.handler(opts, cb, lsp_handler.method, result, context, {})
        end

      -- Some clients may not always return result (null-ls?), so do not terminate loop
      -- when 'result == nil`, instead only when number of callbacks equal number of
      -- clients.
      until done or err

      -- No more results.
      -- fzf_cb(nil)

      -- Only get here once all requests are done, so clear '_cancel_all'.
      -- vim.print("Removing _cancel_all function")
      _cancel_all = nil
    end)()
  end

  return opts, opts.__contents
end

local function gen_sym2style_map(opts)
  assert(opts.symbol_style ~= nil)
  if fzf_lua._sym2style then
    return
  end
  fzf_lua._sym2style = {}
  for kind, icon in pairs(opts.symbol_icons) do
    -- style==1: "<icon> <kind>"
    -- style==2: "<icon>"
    -- style==3: "<kind>"
    local s = nil
    if tonumber(opts.symbol_style) == 1 then
      s = ("%s %s"):format(icon, kind)
    elseif tonumber(opts.symbol_style) == 2 then
      s = icon
    elseif tonumber(opts.symbol_style) == 3 then
      s = kind
    end
    if s and opts.symbol_hl then
      fzf_lua._sym2style[kind] = utils.ansi_from_hl(opts.symbol_hl(kind), s)
    elseif s then
      fzf_lua._sym2style[kind] = s
    else
      -- Can get here when only 'opts.symbol_fmt' was set.
      fzf_lua._sym2style[kind] = kind
    end
  end
  if type(opts.symbol_fmt) == "function" then
    for k, v in pairs(fzf_lua._sym2style) do
      fzf_lua._sym2style[k] = opts.symbol_fmt(v, opts) or v
    end
  end
end

local function symbol_handler(opts, cb, _, result, _, _)
  result = utils.tbl_islist(result) and result or { result }
  local items = vim.lsp.util.symbols_to_items(result, core.CTX().bufnr)
  -- vim.print(items)
  for _, entry in ipairs(items) do
    if
      (not opts.current_buffer_only or core.CTX().bname == entry.filename)
      and (not opts._regex_filter_fn or opts._regex_filter_fn(entry, core.CTX()))
    then
      local mbicon_align = 0
      if opts.fn_reload and type(opts.query) == "string" and #opts.query > 0 then
        -- Highlight exact matches with `live_workspace_symbols` (#1028).
        local sym, text = entry.text:match("^(.+%])(.*)$")
        local pattern = "["
          .. utils.lua_regex_escape(opts.query:gsub("%a", function(x)
            return string.upper(x) .. string.lower(x)
          end))
          .. "]+"
        entry.text = sym
          .. text:gsub(pattern, function(x)
            return utils.ansi_codes[opts.hls.live_sym](x)
          end)
      end
      if fzf_lua._sym2style then
        local kind = entry.text:match("%[(.-)%]")
        local styled = kind and fzf_lua._sym2style[kind]
        if styled then
          entry.text = entry.text:gsub("%[.-%]", styled, 1)
        end
        -- Align formatting to single byte and multi-byte icons
        -- only styles 1,2 contain an icon.
        if tonumber(opts.symbol_style) == 1 or tonumber(opts.symbol_style) == 2 then
          local icon = opts.symbol_icons and opts.symbol_icons[kind]
          mbicon_align = icon and #icon or mbicon_align
        end
      end
      -- Move symbol `entry.text` to start of line,
      -- will be restored in preview/actions by `opts._fmt.from`.
      local symbol = entry.text
      entry.text = nil
      local final_entry = make_entry.lcol(entry, opts)
      if final_entry then
        final_entry = make_entry.file(final_entry, opts)
      end
      -- entry = make_entry.lcol(entry, opts)
      -- entry = make_entry.file(entry, opts)
      -- if entry then
      if final_entry then
        local align = 48 + mbicon_align + utils.ansi_escseq_len(symbol)
        -- TODO: string.format %-{n}s fails with align > ~100?
        -- entry = string.format("%-" .. align .. "s%s%s", symbol, utils.nbsp, entry)
        if align > #symbol then
          symbol = symbol .. string.rep(" ", align - #symbol)
        end
        -- entry = symbol .. utils.nbsp .. entry
        -- cb(entry)
        final_entry = symbol .. utils.nbsp .. final_entry
        cb(final_entry)
      end
    end
  end
end

local handler = {
  ["document_symbols"] = {
    label = "Document Symbols",
    resolved_capability = "document_symbol",
    server_capability = "documentSymbolProvider",
    method = "textDocument/documentSymbol",
    handler = symbol_handler,
  },
}

local normalize_lsp_opts = function(opts, cfg, __resume_key)
  opts = config.normalize_opts(opts, cfg, __resume_key)
  if not opts then
    return
  end

  -- `title_prefix` is priortized over both `prompt` and `prompt_prefix`.
  if (not opts.winopts or opts.winopts.title == nil) and opts.title_prefix then
    utils.map_set(opts, "winopts.title", string.format(" %s %s ", opts.title_prefix, opts.lsp_handler.label))
  elseif opts.prompt == nil and opts.prompt_postfix then
    opts.prompt = opts.lsp_handler.label .. (opts.prompt_postfix or "")
  end

  -- Required for relative paths presentation.
  if not opts.cwd or #opts.cwd == 0 then
    opts.cwd = uv.cwd()
  elseif opts.cwd_only == nil then
    opts.cwd_only = true
  end

  return opts
end

local function store_symbols(bufnr, opts)
  opts = opts or {}
  opts.lsp_handler = handler["document_symbols"]
  opts = normalize_lsp_opts(opts, "lsp.symbols", "lsp_document_symbols")
  if not opts then
    return
  end
  -- No support for sym_lsym.
  for k, fn in pairs(opts.actions or {}) do
    if type(fn) == "table" and (fn[1] == actions.sym_lsym or fn.fn == actions.sym_lsym) then
      opts.actions[k] = nil
    end
  end
  opts = core.set_header(opts, opts.headers or { "regex_filter" })
  opts = core.set_fzf_field_index(opts)
  if not opts.fzf_opts or opts.fzf_opts["--with-nth"] == nil then
    -- our delims are {nbsp,:} make sure entry has no icons
    -- "{nbsp}file:line:col:" and hide the last 4 fields
    opts.git_icons = false
    opts.file_icons = false
    opts.fzf_opts = opts.fzf_opts or {}
    opts.fzf_opts["--with-nth"] = "..-4"
  end
  if opts.symbol_style or opts.symbol_fmt then
    opts.fn_pre_fzf = function()
      gen_sym2style_map(opts)
    end
    opts.fn_post_fzf = function()
      fzf_lua._sym2style = nil
    end
    -- Run once in case not running async.
    opts.fn_pre_fzf()
  end
  opts = gen_lsp_contents(opts)
  if not opts.__contents then
    core.__CTX = nil
    return
  end

  -- Create symbols in `vim.b[0].symbols`.
  opts.__contents(bufnr)
end

-- Function to throttle calls to function doing asynchrounous work,
-- so async work has time to finish before next call.
-- With throttle, `fn` is called with regular intervals no matter how fast and long
-- returned function is called.
local function throttle(fn, opts)
  -- Timer handle used to schedule callbacks in future,
  -- returns Lua userdata wrapping timer.
  local timer, ms = assert(uv.new_timer()), opts and opts.ms or 20
  local running = false

  return function(data)
    if running == false then
      running = true
      timer:start(ms, 0, function()
        running = false
      end)
      if vim.in_fast_event() then
        return vim.schedule(fn)
      end
      fn(data)
    end
  end
end

-- Debounce function call, so each call to returned function will only call passed in
-- function `fn` once, after `ms` has passed.
-- With debounce, `fn` is called whenever `ms` has passed since last time returned function
-- was called, meaning if returned function is called constantly wihtout pause, `fn` will never fire.
local function debounce(fn, opts)
  local timer, ms = assert(uv.new_timer()), opts and opts.ms or 20
  return function()
    timer:start(ms, 0, fn)
  end
end

local throttled_store_symbol = throttle(store_symbols, { ms = 1000 })

-- Problem:
-- 1. Make text change, which causes `documentSymbol` message to be sent to server.
-- 2. Make text change while previous request is in flight, which causes `didChange`
--    before cancellation is sent.
--    notification to be sent to server by `on_lines`.
--    - `didChange`: Fired on every keystroke | undo | any other change to text in buffer.
--    - `didChange`: Sent BEFORE cancellation notification from TextChanged event.
-- 3. Result: Server sends `ContentModified` error, as document changed since last
--    `documentSymbol`, before cancellation was sent.
-- 3. Need to cancel request on every text change, i.e. `on_lines`, but BEFORE `on_lines`
--    by Noevim LSP client.
-- - `on_lines` is like `TextChanged`, just more granular, and apparently fires before.
if vim.g.symbols_cache then
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("update_symbols_inner", { clear = true }),
    callback = function(data)
      local clients = vim.lsp.get_clients({ bufnr = data.buf })
      if not clients or #clients < 1 then
        return
      end

      throttled_store_symbol(data.buf)
      -- At this point, symbols have not been stored yet, as LSP request is async.
    end,
  })
end

if vim.g.symbols_cache then
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = vim.api.nvim_create_augroup("didChange", { clear = true }),
    callback = function(data)
      vim.api.nvim_buf_attach(data.buf, false, {
        on_lines = function()
          fn_cancel_all()
        end,
      })
    end,
  })
end

local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then
    ctx.symbols_filter = MyVim.config.get_kind_filter(ctx.bufnr) or false
  end
  if ctx.symbols_filter == false then
    return true
  end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

-- Keymap to open symbols, via cache.
vim.keymap.set("n", "<leader>so", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.b[bufnr].symbols then
    store_symbols(bufnr)
    require("fzf-lua").lsp_document_symbols({
      regex_filter = symbols_filter,
    })
  else
    if #vim.b[bufnr].symbols < 1 then
      vim.notify("No symbols found", "warn")
    else
      require("fzf-lua").fzf_exec(vim.b[bufnr].symbols, vim.b[bufnr].symbols_opts)
    end
  end
end)
