return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          root_dir = MyVim.root(),
        },
      },
    },
  },
}
