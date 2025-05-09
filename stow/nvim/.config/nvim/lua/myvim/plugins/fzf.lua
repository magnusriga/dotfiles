---@class FzfLuaOpts: myvim.util.pick.Opts
---@field cmd string?

-- ====================================================================
-- When `picker.open(<command>, <opts>)` is called.
-- ====================================================================
-- - `picker.open(<command>, <opts>)` is called when calling `MyVim.pick(<command>)`.
-- - Example:
--   `MyVim.pick("files")` calls `picker.open("files", {})`.
--   `MyVim.pick("files", { cwd = vim.fn.stdpath("config") })` >
--   `MyVim.pick.wrap("files", { cwd = vim.fn.stdpath("config") })` >
--   `MyVim.pick.open("files", { cwd = vim.fn.stdpath("config") })` >
--   `MyVim.pick.picker.open("files", { cwd = vim.fn.stdpath("config") })` >
--   `MyVim.pick.picker === Table from `lua/plugins/fzf.lua`,
--   including `open` | `name` | `commands` keys.
-- - `open`: Uses `fzf-lua` to find root, unless `opts` is passsed in.
---@type MyPicker
local picker = {
  name = "fzf",
  commands = {
    files = "files",
  },

  ---@param command string
  ---@param opts? FzfLuaOpts
  open = function(command, opts)
    opts = opts or {}
    if opts.cmd == nil and command == "git_files" and opts.show_untracked then
      opts.cmd = "git ls-files --exclude-standard --cached --others"
    end
    return require("fzf-lua")[command](opts)
  end,
}

-- Register `fzf-lua` as picker.
if not MyVim.pick.register(picker) then
  return {}
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

return {
  -- `fzf-lua`, picker for FZF.
  {
    "ibhagwan/fzf-lua",
    -- Uses `mini.icons` by default, but add here as dependency
    -- so `mini.icons` loads before `fzf-lua`.
    dependencies = { "echasnovski/mini.icons" },
    -- dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = function(_, opts)
      local trouble_fzf = require("trouble.sources.fzf")
      local config = require("fzf-lua.config")
      local actions = require("fzf-lua.actions")

      -- Change from these defaults:
      -- fzf = {
      --   ["ctrl-z"]         = "abort",
      --   ["ctrl-u"]         = "unix-line-discard",
      --   ["ctrl-f"]         = "half-page-down",
      --   ["ctrl-b"]         = "half-page-up",
      --   ["ctrl-a"]         = "beginning-of-line",
      --   ["ctrl-e"]         = "end-of-line",
      --   ["alt-a"]          = "toggle-all",
      --   ["alt-g"]          = "first",
      --   ["alt-G"]          = "last",
      --   -- Only valid with fzf previewers (bat/cat/git/etc)
      --   ["f3"]             = "toggle-preview-wrap",
      --   ["f4"]             = "toggle-preview",
      --   ["shift-down"]     = "preview-page-down",
      --   ["shift-up"]       = "preview-page-up",
      --   ["alt-shift-down"] = "preview-down",
      --   ["alt-shift-up"]   = "preview-up",
      -- },
      config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"

      -- Vim-style bindings.
      config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
      config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"

      -- Jump to label in list.
      config.defaults.keymap.fzf["ctrl-x"] = "jump"

      -- Preview page navigation.
      config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
      config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
      config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
      config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

      -- ==============================================
      -- `files` command.
      -- ==============================================
      -- - Run `fd --hidden --type f --type l | fzf` i.e. find files and links, then fuzzy search them.
      -- - `fzf` allows searching through all those lines from `fd`, thus it enables
      --   fuzzy-search on directory names as well, only initial list will not contain empty directories.
      -- - Hidden files are included by default.

      -- ==============================================
      -- Default keymaps, i.e. `actions.files`.
      -- ==============================================
      -- - Pickers inheriting these actions: files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
      --   tags, btags, args, buffers, tabs, lines, blines.
      -- - `file_edit_or_qf` opens single selection or sends multiple selection to quickfix.
      -- - Replace `enter` with `file_edit` to open all files/bufs whether single or multiple.
      -- - Replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
      --
      -- - Default keymaps:
      --   ["enter"]       = actions.file_edit_or_qf,
      --   ["ctrl-s"]      = actions.file_split,
      --   ["ctrl-v"]      = actions.file_vsplit,
      --   ["ctrl-t"]      = actions.file_tabedit,
      --   ["alt-q"]       = actions.file_sel_to_qf,
      --   ["alt-Q"]       = actions.file_sel_to_ll,
      --   ["alt-i"]       = actions.toggle_ignore,
      --   ["alt-h"]       = actions.toggle_hidden,
      --   ["alt-f"]       = actions.toggle_follow,
      --
      -- - Grep keymaps:
      --   ["ctrl-g"]      = actions.grep_lgrep, toggles between 'grep' and 'live_grep'.
      --
      -- - Other pickers have other keymaps, like buffers, tabs, git.status, etc.

      ----------------------------------------------------------------
      -- Remap `ctrl-r` for files, from `toggle_ignore` to toggle between root dir and cwd.
      -- No need, use built-in behaviour for `ctrl-r`, i.e. `toggle_ignore`.
      ----------------------------------------------------------------
      -- Toggle where to search from: Root directory | current working directory.
      -- config.defaults.actions.files["ctrl-r"] = function(_, ctx)
      --   local o = vim.deepcopy(ctx.__call_opts)
      --   o.root = o.root == false
      --   o.cwd = nil
      --   o.buf = ctx.__CTX.bufnr
      --   MyVim.pick.open(ctx.__INFO.cmd, o)
      -- end

      -- `alt-c`: Same as `ctrl-r`.
      -- config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]

      -- config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

      ----------------------------------------------------------------
      -- Image preview.
      ----------------------------------------------------------------
      local img_previewer ---@type string[]?
      for _, v in ipairs({
        { cmd = "ueberzug", args = {} },
        { cmd = "chafa", args = { "{file}", "--format=symbols" } },
        { cmd = "viu", args = { "-b" } },
      }) do
        if vim.fn.executable(v.cmd) == 1 then
          img_previewer = vim.list_extend({ v.cmd }, v.args)
          break
        end
      end

      local smart_prefix = require("trouble.util").is_win()
          and "transform(IF %FZF_SELECT_COUNT% LEQ 0 (echo select-all))"
        or "transform([ $FZF_SELECT_COUNT -eq 0 ] && echo select-all)"

      ----------------------------------------------------------------
      -- Action to open selected or all items in `trouble.nvim` list.
      ----------------------------------------------------------------
      ---@param selected string[]
      ---@param fzf_opts fzf.Opts
      ---@param trouble_mode? trouble.Mode
      local trouble_open = function(selected, fzf_opts, trouble_mode)
        trouble_mode = trouble_mode or {}
        trouble_mode.focus = true
        trouble_fzf.items = {}
        trouble_fzf.add(selected, fzf_opts, trouble_mode)
      end
      local trouble_action_open = { fn = trouble_open, prefix = smart_prefix, desc = "smart-open-with-trouble" }

      ----------------------------------------------------------------
      -- `fzf-lua` spec `opts`.
      ----------------------------------------------------------------
      return {
        -- `opt[1]`: Profile, i.e. `default-title`.
        "default-title",

        -- NOTE: Colors set in `util/hlcolors.lua`, with some overrides defined below.

        -- Some colors must be set in global `fzf-lua` config, i.e. `hls`,
        -- since no standard `fzf --color` option exists for them.
        hls = {
          -- `["help_normal"]` does not set `fg` color on help search.
          -- ["help_normal"] = { "fg", "LazygitActiveBorderColor" },
        },
        ----------------------------------------------------------------
        -- `fzf_colors`.
        ----------------------------------------------------------------
        -- - These settings are passed directly to `fzf` in `--color` option.
        -- - Keys: `--color` argument.
        -- - Values: Which part of given highlitht group to use,
        --   e.g. for hex color `--color=separator:#xxxxxx` pick e.g. `fg` from `HighlighGroup`.
        --
        -- - Format.
        --   - `--color=[BASE_SCHEME][,COLOR_NAME[:ANSI_COLOR][:ANSI_ATTRIBUTES]]...`.
        --   - See: `man fzf` for values.
        --
        -- - Terminology.
        --   - `selected`: Any line in fzf list, except current cursor line.
        --                 Called "selected" because typing in fzf will narrow down list,
        --                 and thus "select" certain lines.
        --                 No to be confused with tab-selected lines.
        --   - `current` : Line cursor is currently at.
        --
        -- - Building a custom colorscheme, has the below specifications:
        --   If rhs is of type "string" rhs will be passed raw, e.g.:
        --     `["fg"] = "underline"` will be translated to `--color fg:underline`
        --   If rhs is of type "table", the following convention is used:
        --     [1] "what" field to extract from the hlgroup, i.e "fg", "bg", etc.
        --     [2] Neovim highlight group(s), can be either "string" or "table"
        --         when type is "table" the first existing highlight group is used
        --     [3+] any additional fields are passed raw to fzf's command line args
        --   Example of a "fully loaded" color option:
        --     `["fg"] = { "fg", { "NonExistentHl", "Comment" }, "underline", "bold" }`
        --   Assuming `Comment.fg=#010101` the resulting fzf command line will be:
        --     `--color=fg:#010101:underline:bold`
        --
        -- - To pass raw arguments: `fzf_opts["--color"]` or `fzf_args`.
        fzf_colors = {
          -- Inherit fzf colors not specified below from auto-generated theme, similar to `fzf_colors=true`.
          -- No need, use default and own configuration.
          -- true,

          -- `fg`:
          -- - Forground color of selected lines, i.e. all lines except current cursor line.
          -- - Has no effect, some other setting overrides this.
          -- - If nothing is typed, all lines still use this foreground color.
          -- ["fg"] = { "fg", "FzfLuaCursor" },

          -- `bg`:
          -- - Background color of selected lines, i.e. all lines except current cursor line.
          -- - Keep empty, background would cover most of window and be distracting.
          -- ["bg"] = "red",

          -- `hl`:
          -- - Highlighted substring in selected lines, i.e. all lines except current cursor line.
          -- - Meaning, foreground color and attributres, e.g. underline, of part of selected line matching query.
          -- - If nothing is typed, no lines use this foreground color.
          -- - Pass in `bold regular` to remove underline from substring.
          ["hl"] = { "fg", "FzfLuaFzfMatch", "regular", "bold" },

          -- `fg+`:
          -- - Foreground color of current line.
          -- - Keep `fzf` default, `None` foreground color, in bold.
          -- ["fg+"] = { "fg", "None", "bold" },

          -- `bg+`:
          -- - BOTH gutter color on left for all lines, AND background color of current line.
          -- - Set `gutter` to no background color, see below, and use `CursorLine` for current line.
          ["bg+"] = { "bg", "CursorLine" },

          -- `hl`:
          -- - Highlighted substring in current line, i.e. cursor line.
          -- - Meaning, foreground color and attributes, e.g. underline, of part of current line mathcing query.
          -- - If nothing is typed, no line use this foreground color.
          -- - Keep same as `hl`, since current line is highlighted with `bg+`.
          ["hl+"] = { "fg", "FzfLuaFzfMatch", "regular", "bold" },

          -- Horizontal separator on info line, by default `FzfLuaFzfBorder`.
          -- Meaning, line between search field and matches.
          ["separator"] = { "fg", "FzfLuaFzfSeparator" },

          -- Gutter to left of non-selected lines.
          -- `-1`: Default terminal background and foreground colors.
          ["gutter"] = "-1",

          -- Info line, match counters.
          ["info"] = { "fg", "FzfLuaFzfInfo" },

          -- Prompt text, e.g. `Files>`.
          -- ["prompt"] = { "fg", "Conditional" },

          -- Pointer to current line, i.e. bar to left of selected line.
          -- Red by default.
          -- ["pointer"] = { "fg", "FzfLuaFzfSeparator" },

          -- Multi-select marker.
          -- ["marker"] = { "fg", "Keyword" },

          -- Streaming input indicator.
          -- ["spinner"] = { "fg", "Label" },

          -- Header text, e.g. punctuation in keybindings line, not top search field.
          -- Grey, e.g. `Comment`.
          ["header"] = { "fg", "Comment" },
        },
        fzf_opts = {
          ["--no-scrollbar"] = true,

          --------------------------------
          -- - `--margin` | `--padding`.
          --------------------------------
          --   - `--margin` : Space outside border, `fzf` default: `1`.
          --   - `--padding`: Space between border and content, `fzf` default: `1`.
          --   - Same if no `--border`.
          --   - Since border in `fzf-lua` is different from `--border`, and `--border` is not used,
          --     `--marging` and `--padding` both add space inside outer `fzf-lua` window border.
          --   - Absolute number of lines/columns | percentage of terminal | window height.
          --   - TRBL in one | TB,RL | T,RL,B | T,R,B,L.
          --   - When specified in absolute lines/columns, lines are taller than columns are wide,
          --     thus `1,2` is probably as close to eqaul padding as possible with absolute values.
          --   - Percentage values will also be difficult to make equal, as monitors are not square.
          --------------------------------
          -- Set `--margin=0`, to only have to deal with padding.
          ["--margin"] = 0,
          -- Set `--padding=2`, for two lines on all edges.
          ["--padding"] = "1,2",
        },
        defaults = {
          -- formatter = "path.filename_first",
          formatter = "path.dirname_first",
        },
        previewers = {
          builtin = {
            extensions = {
              ["png"] = img_previewer,
              ["jpg"] = img_previewer,
              ["jpeg"] = img_previewer,
              ["gif"] = img_previewer,
              ["webp"] = img_previewer,
            },
            ueberzug_scaler = "fit_contain",
          },
        },
        -- Overwrite `vim.ui.select`, i.e. interactive select menu, with `fzf-lua`.
        -- Actual replacement is done below, via VeryLazy autocmd.
        ui_select = function(fzf_opts, items)
          -- `vim.o.lines`: Number of lines in the current window, i.e. screen height.
          -- `items`      : Number of items to select from, e.g. number of code action items.
          return vim.tbl_deep_extend("force", fzf_opts, {
            prompt = " ",
            fzf_opts = {
              ["--no-header"] = true,
            },
            winopts = {
              title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
              title_pos = "center",
            },
          }, fzf_opts.kind == "codeaction" and {
            winopts = {
              layout = "vertical",
              -- To determine height, start with number of ui select items,
              -- add 2 lines for top and bottom `fzf` padding, see above,
              -- add 2 lines for query line and separator below query line,
              -- add 16 lines for preview window and its border.
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 4) + 0.5) + 16,
              width = 0.5,

              -- Preview window starts as hidden if language server is `vtsls`, i.e. file is typescript.
              preview = not vim.tbl_isempty(MyVim.lsp.get_clients({ bufnr = 0, name = "vtsls" }))
                  and {
                    layout = "vertical",
                    vertical = "down:15",
                    -- `border`: "rounded" (default) | "border-top" | "none" | `nvim_open_win` options.
                    border = "border-top",
                    hidden = "hidden",
                  }
                or {
                  layout = "vertical",
                  vertical = "down:15",
                  border = "border-top",
                },
            },
          } or {
            winopts = {
              width = 0.5,
              -- Height is number of items, with a max of 80% screen height.
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
            },
          })
        end,
        winopts = {
          width = 0.8,
          height = 0.8,
          row = 0.5,
          col = 0.5,
          preview = {
            scrollchars = { "┃", "" },
          },
        },
        actions = {
          -- Below are default actions.
          -- Setting any value will override defaults.
          -- Other pickers inherit default actions listed below, even if [1] is not `true`.
          -- Pickers inheriting from these dafault actions:
          -- - files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist.
          -- - tags, btags, args, buffers, tabs, lines, blines.
          -- If keybinding not usable in inherited picker, it is ignored.
          files = {
            -- Inherit excplicitly defined mappings below.
            -- - `true` : No need, `true` is default.
            -- - `false`: Pickers do not inherit below mappings.
            -- false,
            -- `file_edit_or_qf` opens single selection or sends multiple selection to quickfix.
            -- Replace `enter` with `file_edit` to open all files/bufs whether single or multiple.
            -- Replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first.
            -- ["enter"] = false,
            ["enter"] = actions.file_edit_or_qf,
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,

            -- `toggle_ignore` is not used by `oldfiles` picker.
            -- Omit, not enough header space and rarely used.
            -- ["ctrl-r"] = actions.toggle_ignore,

            -- Open all fzf-lua matches in `trouble.nvim`.
            -- If `trouble.nvim` not installed, use default behaviour: `actions.file_tabedit`.
            ["ctrl-t"] = MyVim.has("trouble.nvim") and trouble_action_open or actions.file_tabedit,

            -- Remove default `alt` bindings.
            -- ["alt-q"] = actions.file_sel_to_qf,
            -- ["alt-Q"] = actions.file_sel_to_ll,
            -- ["alt-i"] = actions.toggle_ignore,
            -- ["alt-h"] = actions.toggle_hidden,
            -- ["alt-f"] = actions.toggle_follow,
          },
        },
        files = {
          -- By default, cwd appears in header only if `opts` contain cwd
          -- parameter with different directory than current working directory,
          -- i.e. when opening folder in root.
          -- `true` | `false`: Always | never show cwd in header.
          cwd_header = false,

          -- Show cwd as prompt, if `false` show `All>`,
          -- or set manually with `prompt`.
          cwd_prompt = false,

          -- Manually set prompt, used if `cwd_prompt` is `false`.
          prompt = "Files❯ ",

          -- Global `rg` options, does not work, presumably overwritten by same options under `grep`.
          -- rg_opts = [[--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g "!.git" ]]
          --  .. [[-e]],

          -- Additonal key bindings for files picker.
          -- No need, just used inherited bindings, from `actions.files`.
          -- actions = {
          -- `toggle_ignore`: Instead of default `alt-i`, use `ctrl-r`, which is what `grep` uses by default.
          -- ["alt-i"] = { actions.toggle_ignore },
          -- ["alt-h"] = { actions.toggle_hidden },
          -- },
        },
        oldfiles = {
          cwd_header = false,
          -- cwd_only = false,
          prompt = "History❯ ",
          -- Include buffers from current session.
          -- NOTE: When re-opening all previous buffers on Neovim start,
          -- all those buffers are added to `history` list.
          include_current_session = true,
        },
        grep = {
          cwd_header = false,
          prompt = "Rg❯ ",
          input_prompt = "Grep For❯ ",

          -- - Set options passed directly to `rg`.
          -- - Can omit `--hidden` and `-g "!.git"`, set with other config below.
          --   - `--colors`: `{type}:{attribute}:{value}`.
          --   - `type`       : `path` | `line` (line number) | `column` | `match`.
          --   - `attribute`  : `fg` | `bg` | `style`.
          --   - `value`      : Color for `fg` | `bg`, or text style for `style`.
          --   - `{type}:none`: Clears formatting going forward.
          -- - `match:fg`: Defaults to `LightRed`, i.e. ANSI 256 color `9`.
          rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 ]]
            .. [[--colors 'match:fg:0xff,0x96,0x6c' --colors 'line:fg:10' --colors 'column:fg:14' ]]
            .. [[-e]],

          -- Remove basic `fzf` header, showing when no bindings available,
          -- i.e. `CTRL-T: Files/Directories | CTRL-R: All`.
          -- fzf_opts = {
          --   ["--no-header"] = true,
          -- },

          -- Include hidden files.
          hidden = true,

          -- Follow symlinks.
          follow = true,

          -- Do not hide full header, it contains e.g. regex search string.
          -- no_header = true,

          -- Hide interactive header, i.e. `<ctrl-g> to regex search` and `<ctrl-r> to include ignore-files`.
          -- Enables better view of regex search string, but need to see bindings.
          -- no_header_i = true,

          -- Respect `.gitignore`.
          no_ignore = false,
        },
        lsp = {
          symbols = {
            prompt = "Symbols❯ ",
            symbol_hl = function(s)
              return "TroubleIcon" .. s
            end,
            symbol_fmt = function(s)
              return s:lower() .. "\t"
            end,
            child_prefix = false,
          },
          code_actions = {
            -- When git-delta is installed use "codeaction_native" for beautiful diffs
            -- try it out with `:FzfLua lsp_code_actions previewer=codeaction_native`
            -- scroll up to `previewers.codeaction{_native}` for more previewer options
            previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or "codeaction",
          },
        },
        tags = {
          prompt = "Tags❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
        helptags = {
          prompt = "Helptags❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
        jumps = {
          prompt = "Jumptags❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
        keymaps = {
          prompt = "Keymaps❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
        marks = {
          prompt = "Marks❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
        manpages = {
          prompt = "Manpages❯ ",
          fzf_opts = {
            ["--no-header"] = true,
          },
        },
      }
    end,
    config = function(_, opts)
      -- This is true, `opt[1]`, i.e. profile, is `default-title`.
      if opts[1] == "default-title" then
        -- Use same prompt for all pickers for profile `default-title` and
        -- profiles that use `default-title` as base profile.
        local function fix(t)
          t.prompt = t.prompt ~= nil and " " or nil
          for _, v in pairs(t) do
            if type(v) == "table" then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
        opts[1] = nil
      end
      require("fzf-lua").setup(opts)
    end,
    init = function()
      MyVim.on_very_lazy(function()
        -- Overwrite `vim.ui.select`, i.e. interactive select menu,
        -- with `fzf-lua`, passing in `opt.ui_select` from above,
        -- when `lazy.nvim` is done installing and loading plugins.
        vim.ui.select = function(...)
          require("lazy").load({ plugins = { "fzf-lua" } })
          local opts = MyVim.opts("fzf-lua") or {}
          require("fzf-lua").register_ui_select(opts.ui_select or nil)
          return vim.ui.select(...)
        end
      end)

      -- - Overwrite behaviour for built-in LSP keybindings, and/or from `plugins/lsp/keymaps.lua` (not used),
      --   so `fzf-lua` is used in case LSP command could returns multiple results from language server.
      -- - `opts` as function, so this just executes right before `opts` is passed to `config`
      --   function, during `opts` merging.
      -- - Since below function extends `Keys`, it extends reference to `plugins.lsp.keymaps._keys` table in memory,
      --   thus it does not matter that this is executed before `nvim-lspconfig` config-function,
      --   which is where autocmd is set up that creates key bindings from `plugins.lsp.keymaps._keys`.
      -- - NOTE: When keymap is defined on `lsp.keymaps`, `which-key` does not interpret keybinding as
      --         being from plugin `fzf-lua`, which is good because keybindings defined in `lsp.keymaps`
      --         get dynamic icon based on filetype, and not from `which-key` plugin rule for `fzf-lua`.
      local Keys = require("myvim.lsp.keymaps").get()

      ---------------------------------------------
      -- Built-in `gr<x>` commands, see: `:h vim-diff`, `:h lsp`.
      ---------------------------------------------
      -- - Normal mode:
      -- - `grn` : `vim.lsp.buf.rename()`
      -- - `gra` : `vim.lsp.buf.code_action()`, Normal | Visual mode.
      -- - `grr` : `vim.lsp.buf.references()`.
      -- - `gri` : `vim.lsp.buf.implementation()`.
      -- - `gO`  : `vim.lsp.buf.document_symbol()`.
      -- - `gq`  : Calls function in `opt.formatexpr()`, initially set to `vim.lsp.formatexpr()` by Neovim,
      --           but remapped to `util/format.lua` > `format()`.
      -- - `K`   : `vim.lsp.buf.hover()`.
      -- - CTRL-]: `vim.lsp.tagfunc()` > `textdocument/definition` < `vim.lsp.buf.defitition`.
      --
      -- - Insert mode:
      -- - CTRL-S: `vim.lsp.buf.signature_help()`.
      --
      -- Therefore, do not re-create above functionality in new shortcuts,
      -- except to use `plugins/fzf.lua` if command can return multiple hits, e.g. references.
      --
      -- These built-in bindings are remapped to same command, except using `fzf-lua`,
      -- instead of quickfix list, when language server returns multiple results:
      -- - `grr`.
      -- - `gri`.
      -- - `gO`.
      --
      -- These built-in bindings are remapped to same command:
      -- - `gd` : Built-in behaviour is to go to local declaration, mainly useful in `C`,
      --          thus remap similar functionality that works across languages,
      --          i.e. `vim.lsp.buf.definition()`.
      --
      -- These built-in bindings are not remapped:
      -- - `grn`: `vim.lsp.buf.rename()`, no remap needed, cannot return multiple results.
      -- - `gra`: `vim.lsp.buf.code_action()`, no remap needed, just calls `vim.ui.select`,
      --          which is overwritten with `fzf-lua` picker.
      --
      -- These new bindings are created, following built-in `gr<x>` format, as no built-in binding exists:
      -- - `grd`: Go to definintion, same as built-in `ctrl-]`.
      -- - `gry`: Go to type definintion.
      ---------------------------------------------

      ---------------------------------------------
      -- Symbols and tags.
      ---------------------------------------------
      -- - Tags are defined in tag files, created with `ctags`, `gutentags`, etc.
      -- - Alternatively, tags can be created on demand, for `{name}` in `:tag {name}`
      --   or for word under cursor when using `gd` or `ctrl-]`.
      -- - Tags are created on demand with function defined in `opt.tagfunc`.
      -- - `opt.tagfunc` is set to `vim.lsp.tagfunc()`, when Neovim's built-in LSP client starts.
      -- - `vim.lsp.tagfunc()` invokes `textdocument/definition` LSP method when used with Normal mode
      --   commands, e.g. `gd` or `ctrl-]`, and "workspace/symbol" when used with other tag commands,
      --   e.g. `:tag` | `:tjump` | `tselect`.
      -- - Thus, tags are set by LSP response, enabling navigation to function definition.
      --   - `ctrl-]` : Go to definition.
      --   - `:tag`   : Go to symbol.
      -- - Potential ways to continousely update tags, so symbol search is fast:
      --   - Regularly calling `ctags`.
      --   - Storing `symbols` for file in table, based on `vim.lsp.buf.document_symbols()`,
      --     updating it on `InsertLeave`.
      ---------------------------------------------

      -- stylua: ignore
      vim.list_extend(Keys, {
        -- `grr`: Built-in key binding for `vim.lsp.buf.references()`, here overwriting it with same behaviour,
        --        except using `fzf-lua` instead of default quickfix list when multiple results.
        { "grr", "<cmd>FzfLua lsp_references jump1 ignore_current_line=true<cr>", desc = "References", nowait = true },

        -- `gri`: Built-in key binding for `vim.lsp.buf.implementation()`, here overwriting it with same behaviour,
        --        except using `fzf-lua` instead of default quickfix list when multiple results.
        { "gri", "<cmd>FzfLua lsp_implementations jump1 ignore_current_line=true<cr>", desc = "Goto Implementation" },

        -- `gO` : Built-in key binding for `vim.lsp.buf.document_symbol()`, here overwriting it with same behaviour,
        --        except using `fzf-lua` instead of default quickfix list.
        -- `regex_filter`: Filters symbols based on list defined in: `config/init.lua` > `options.<lang>|default`.
        { "gO", function() require("fzf-lua").lsp_document_symbols({ regex_filter = symbols_filter, }) end, desc = "Goto Symbol" },

        -- `gd` : Built-in key binding to go to local declaration, mostly useful in `C`,
        --        here overwriting it with almost same behaviour, i.e. `vim.lsp.buf.definition()`.
        { "gd", "<cmd>FzfLua lsp_definitions jump1 ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },

        -- `gry`: Not built-in key binding, thus no overwriting.
        { "gry", "<cmd>FzfLua lsp_typedefs jump1 ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },

      -- LSP symbols, set on `lsp.keymaps` so `which-key` uses dynamic icon based on filetype.
      { "<leader>ss", function() require("fzf-lua").lsp_document_symbols({ regex_filter = symbols_filter, }) end, desc = "LSP Symbols", has = "documentSymbol" },
      { "<leader>sS", function() require("fzf-lua").lsp_live_workspace_symbols({ regex_filter = symbols_filter, }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
      })
    end,
    keys = {
      ---------------------------------------------
      -- Unsure what these do.
      ---------------------------------------------
      -- { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
      -- { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },

      ----------------------------------------------------------------
      -- Top-level.
      ----------------------------------------------------------------
      {
        "<leader>,",
        "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Buffers",
      },
      { "<leader>/", MyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      -- Opens file picker from root directory of current file,
      -- but when root directory cannot be determined from file,
      -- e.g. at `dashboard`, file picker is opened from current working directory.
      { "<leader><space>", MyVim.pick("files"), desc = "Find Files (Root Dir)" },

      ----------------------------------------------------------------
      -- Find.
      -- Recent: Only updates list when Neovim restarts.
      ----------------------------------------------------------------
      { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fc", MyVim.pick.config_files(), desc = "Find Config File" },
      { "<leader>ff", MyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", MyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      -- { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent (All)" },
      { "<leader>fr", MyVim.pick("oldfiles"), desc = "Recent (Root Dir)" },
      -- { "<leader>fR", MyVim.pick("oldfiles"), desc = "Recent (Root Dir)" },
      { "<leader>fR", MyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },

      ----------------------------------------------------------------
      -- Git.
      ----------------------------------------------------------------
      -- Use `gl` for `git log`.
      -- { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
      { "<leader>gl", "<cmd>FzfLua git_commits<CR>", desc = "Git Log (all)" },
      { "<leader>gL", "<cmd>FzfLua git_bcommits<CR>", desc = "Git Log (open buffers)" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },

      ----------------------------------------------------------------
      -- Search.
      ----------------------------------------------------------------
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", MyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", MyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Highlight Groups" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },

      ----------------------------------------------------------------
      -- Grep.
      ----------------------------------------------------------------
      { "<leader>sw", MyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
      {
        "<leader>sW",
        MyVim.pick("grep_word", { root = false }),
        desc = "Visual selection or word (cwd)",
        mode = { "n", "x" },
      },
      { "<leader>sw", MyVim.pick("grep_visual"), mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", MyVim.pick("grep_visual", { root = false }), mode = "v", desc = "Selection (cwd)" },

      ----------------------------------------------------------------
      -- UI.
      ----------------------------------------------------------------
      { "<leader>uC", MyVim.pick("colorschemes"), desc = "Colorscheme with Preview" },
    },
  },

  -- Keybindings for todo-comments.
  -- Set directly in `editor.lua`, using Snacks.picker.
  -- {
  --   "folke/todo-comments.nvim",
  --   -- Overwrites Telescope key bingings in `plugins/editor.lua`.
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>st", function() require("todo-comments.fzf").todo() end, desc = "Todo" },
  --     { "<leader>sT", function () require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
  --   },
  -- },
}
