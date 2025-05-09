return {
  -- Add `luasnip`.
  -- NOTE: Built-in snippet engine normally enough, but add `luasnip` to use
  -- `filetype_extend` and thus use `javascript` snippets in `typescript` files.
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (not MyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

          -- Add to `typescript` files, snippets for:
          -- - `javascript`
          -- - `javascriptreact`
          -- - `typescriptreact`
          -- require("luasnip").filetype_extend("typescript", { "javascript", "javascriptreact", "typescriptreact" })
          require("luasnip").filetype_extend("typescript", { "javascript" })

          -- Add to `javascript` files, snippets for:
          -- - `javascriptreact`
          -- require("luasnip").filetype_extend("javascript", { "javascriptreact" })
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  -- Add `snippet_forward` action.
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      MyVim.cmp.actions.snippet_forward = function()
        if require("luasnip").jumpable(1) then
          vim.schedule(function()
            require("luasnip").jump(1)
          end)
          return true
        end
      end
      MyVim.cmp.actions.snippet_stop = function()
        if require("luasnip").expand_or_jumpable() then -- or just jumpable(1) is fine?
          require("luasnip").unlink_current()
          return true
        end
      end
    end,
  },

  -- `blink.cmp` integration.
  {
    "saghen/blink.cmp",
    opts = {
      snippets = {
        preset = "luasnip",
      },
    },
  },
}
