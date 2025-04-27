return {
  -- Auto pairs, so inserting | deleting bracket | quote will
  -- insert | delete corresponding bracket | quote automaitcally.
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      -- In which modes mappings from this `config` should be created.
      modes = { insert = true, command = false, terminal = false },

      -- Skip autopair when next character is one of these.
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],

      -- Skip autopair when the cursor is inside `string` treesitter nodes,
      -- effectively disabling autopairs inside non-comment strings.
      skip_ts = { "string" },

      -- Skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs.
      skip_unbalanced = true,

      -- Better deal with markdown code blocks.
      -- If opening pair is ` in markdown file,
      -- and pair is added at start of line, not counting whitespace,
      -- and `` already appears right before pair,
      -- then add newline before pair, and move cursor back up one line.
      markdown = true,
    },
    config = function(_, opts)
      -- `util/mini.lua` > `pairs(opts)`:
      -- 1. Add keybinding to toggle on|off `mini.pairs`,
      --    whose state is stored in: `vim.g.miniparis_disable`.
      -- 2. Load `mini.pairs` plugin by executing `require("mini.pairs").setup(opts)`,
      --    passing in `opts` defined above, and replacing `pairs.open` to account for
      --    edge cases specified in `opts` above.
      MyVim.mini.pairs(opts)
    end,
  },

  -- Override comment string inserted with `gc[c]` for given treesitter language,
  -- thus fixing wrong comment style being inserted in e.g. React.
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- (( *a (bb) ))
  -- "*a" " bb "
  -- <x>*</x><y>b</y>
  -- Some text * more text * more.

  -- - Adds to built-in and custom motions:
  --   - Dot-repeat: `.` to repeat last motion.
  --   - v:count: `v2a"` applies motion to 2nd match.
  --   - Consecutive application: `vi(i(i(..` repeats selection outwards, without leaving visual mode.
  --   - Aliases for textobjects.
  -- - Adds motions for edge jumping:
  --   - `g[<obj>`: Jump to left edge of `<obj>`.
  --   - `g]<obj>`: Jump to right edge of `<obj>`.
  -- - Creates new textobjects:
  --   - `af`: Function call, not function declaration, e.g. `vafaf` from inside callback to select whole function call.
  --   - `a?<op>`: Manually specify operator, e.g. `di?eo...` to delete between `e` and `o`, and repeat three times.
  --   - `i[n|p]a`: Argument, e.g. `cina` to change next argument, then `<Esc>.` to repeat.
  --   - `at`: Tag, e.g. `vat` selects full HTML tag and code inside, instead of next single closing|opening `<>`.
  --   - `a*`:
  --   - Digits, punctuation, whitespace:
  --     - `va<digit>`: Select from cursor to next <digit>.
  --     - `va<space>`: Select from cursor to next space.
  --     - `va_`: Select from cursor to next underscore.
  --     - `va*`: Select from cursor to next star.
  -- - Prevent `i` and `a` from including surrounding space.
  -- - Allows creating own textobjects, based on e.g. treesitter.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          -- Code block.
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),

          -- Function definition, via treesitter objects.
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),

          -- Class definition, via treesitter objects.
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class

          -- Enhanced tags, overwriting `t`.
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },

          -- Digits, with `d`.
          d = { "%f[%d]%d+" },

          -- Words with case, with `e`.
          e = {
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },

          -- Entire buffer.
          g = MyVim.mini.ai_buffer,

          -- Alias for function call.
          u = ai.gen_spec.function_call(),

          -- Function call, but only matching functions with name containing
          -- any alphanumeric character and underscore, e.g. without dot.
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      MyVim.on_load("which-key.nvim", function()
        vim.schedule(function()
          MyVim.mini.ai_whichkey(opts)
        end)
      end)
    end,
  },

  -- - Add, delete, replace punctuation / brackets around text.
  -- - Action are dot-repeatable.
  -- - Actions:
  --   - `sa`  : Add.
  --   - `sd`  : Delete.
  --   - `sr`  : Replace.
  --   - `sf|F`: Find next|previous surrounding.
  --   - `sh`  : Briefly highlight surrounding.
  --   - `sn`  : Change number of neighbour lines searched for match, default 20.
  -- - Surroundings:
  --   - `f`   : Function call.
  --   - `t`   : Find tag with given name, change tag name.
  --   - `()`  : Find balanced brackets, change brackets, including: `()`, `[]`, `{}`, `<>`.
  --   - `?`   : snteractive, prompt for left and right parts.
  --   - All   : All other characters also supported, with idenitcal left and right parts.
  -- - Suffix:
  --   - Instead of operating on surrounding items, operate on last|next pair.
  --   - Applies to all actions except "Add".
  --   - `l`   : Last method: `gsrl"' ...`.
  --   - `n`   : Next method: `gsan"'`.
  -- - Search method, first applies to current line then to neighborhood:
  --   - `cover`: Use only covering match, not previous | next, report if not found.
  --   - `cover_or_next`: Use covering match, if not found use next.
  --   - `cover_or_prev`: Use covering match, if not found use previous.
  --   - `cover_or_nearest`: Use covering match, if not found use nearest.
  --   - `next`: Use next match.
  --   - `prev`: Use previous match.
  --   - `nearest`: Use nearest match.
  -- - Note:
  --   - Does use whatever is around cursor, without understanding of pairs.
  {
    "echasnovski/mini.surround",

    -- `keys` are merged with `keys` from other `mini.surround` specs, just like `opts`.
    keys = function(_, keys)
      -- `opts` merged from all `mini.surround` specs, including `opts` below.
      local opts = MyVim.opts("mini.surround")

      -- `rhs` is nil, so mapping is created in `nvim.surround` config.
      -- Purpose of below is to add `which-key` descriptions.
      local mappings = {
        { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete Surrounding" },
        { opts.mappings.find, desc = "Find Right Surrounding" },
        { opts.mappings.find_left, desc = "Find Left Surrounding" },
        { opts.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.mappings.replace, desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }

      -- Only include mappings above that are actually defined in `opts`.
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)

      return vim.list_extend(mappings, keys)
    end,

    opts = {
      custom_surroundings = {
        -- Add custom surrounding for `h` keyword, to add highlighting in markdown files.
        ["h"] = { output = { left = "==", right = "==" } },
      },
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes.
        delete = "gsd", -- Delete surrounding.
        find = "gsf", -- Find surrounding (to the right).
        find_left = "gsF", -- Find surrounding (to the left).
        highlight = "gsh", -- Highlight surrounding.
        replace = "gsr", -- Replace surrounding.
        update_n_lines = "gsn", -- Update `n_lines`.
      },

      -- See above and `:h MiniSurround.config`.
      search_method = "cover_or_next",
    },
  },

  -- `lazydev` ensures LuaLS does not load, i.e. run, all libraries,
  -- i.e. all `.lua` files inside `~/.config/nvim` directory,
  -- to provide completion suggestions and diagnostics based on available types,
  -- only those `require(..)`ed in open `.lua` files.
  --
  -- To make LuaLS provide completion suggestions and see types of libraries, i.e. `.lua` files,
  -- that are not `require()'ed in open `.lua` files, pre-load these libraries by adding them to
  --
  -- Results:
  -- - Autocompletion, e.g. with `blink.cmp` is faster, as LSP only has to search through required files.
  -- - If using `lazydev` without preloading e.g. `snacks.nvim`, global `Snacks` variable would not
  --   be seen by LuaLS and diagnostic warning would show.
  --
  -- Note: Adding completion suggestions from `lazydev` to `blink.cmp`, in `plugins/coding.lua`.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      -- Pre-load certain libraries, so LuaLS provides autocompletion suggestions from them,
      -- and recognizes their types, even if no open `.lua` files `require()` them.
      library = {
        -- Library paths can be absolute.
        -- "~/projects/my-awesome-lib",

        -- "lua",
        -- "$VIMRUNTIME",
        -- "lazy.nvim",
        -- "nvim-lspconfig",

        -- Or relative, which means they will be resolved from the plugin dir.
        -- "lazy.nvim",

        -- It can also be a table with trigger words / mods:

        -- { path = "LazyVim", words = { "LazyVim" } },

        -- Load lazy.nvim when file has MyVim, because `MyVim` inherits from `lazy.nvim`.
        { path = "lazy.nvim", words = { "MyVim", "LazyVim", "LazySpec" } },

        -- Only yazi.nvim types when `YaziConfig` word is found.
        { path = "yazi.nvim", words = { "YaziConfig" } },

        -- Only load luvit types when the `vim.uv` word is found.
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },

        -- Only load `snacks.nvim` types when `Snacks` word is found.
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
