return {
  -- Auto pairs, so inserting | deleting bracket | quote will
  -- insert | delete corresponding bracket | quote automaitcally.
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      -- In which modes mappings from this `config` should be created.
      modes = { insert = true, command = true, terminal = false },

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
        { path = "lazy.nvim", words = { "MyVim" } },

        -- Only load luvit types when the `vim.uv` word is found.
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },

        -- Only load `snacks.nvim` types when `Snacks` word is found.
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
