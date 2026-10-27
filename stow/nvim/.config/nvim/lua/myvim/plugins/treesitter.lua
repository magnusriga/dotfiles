return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "latex",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "scss",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      ts.setup()
      -- The JSON grammar includes comments; there is no separate jsonc parser.
      vim.treesitter.language.register("json", "jsonc")

      local function attach(buf)
        if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
          return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if lang and vim.treesitter.language.add(lang) then
          vim.treesitter.start(buf, lang)
          if vim.treesitter.query.get(lang, "indents") then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("MyVimTreesitter", { clear = true }),
        callback = function(event)
          attach(event.buf)
        end,
      })
      -- Install missing parsers on a fresh machine and attach buffers opened
      -- before their asynchronous installation finished.
      ts.install(MyVim.dedup(opts.ensure_installed)):await(function(err, installed)
        vim.schedule(function()
          if err or not installed then
            vim.notify(
              "Treesitter parser installation failed: " .. tostring(err or "see :messages"),
              vim.log.levels.ERROR
            )
            return
          end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            attach(buf)
          end
        end)
      end)

      -- Native node selection replaces the retired incremental-selection module.
      vim.keymap.set("n", "<C-Space>", "van", { remap = true, desc = "Increment Selection" })
      vim.keymap.set("x", "<C-Space>", "an", { remap = true, desc = "Increment Selection" })
      vim.keymap.set("x", "<BS>", "in", { remap = true, desc = "Decrement Selection" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    opts = { move = { set_jumps = true } },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      local move = require("nvim-treesitter-textobjects.move")
      local mappings = {
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
      }
      for method, mappings_by_key in pairs(mappings) do
        for key, query in pairs(mappings_by_key) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            -- Keep Vim's built-in change navigation in diff windows.
            if vim.wo.diff and key:find("[cC]") then
              vim.cmd.normal({ key, bang = true })
            else
              move[method](query, "textobjects")
            end
          end, { desc = method:gsub("_", " ") .. " " .. query })
        end
      end
    end,
  },

  -- Automatically add closing tags for HTML and JSX.
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
