-- Disable spellcapcheck for markdown and similar files
vim.api.nvim_create_autocmd({ "FileType" }, {
  -- pattern = { "markdown", "markdown.mdx", "text", "tex", "asciidoc", "rst" },
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.spellcapcheck = ""
  end,
  desc = "Disable spellcapcheck for content files",
})
