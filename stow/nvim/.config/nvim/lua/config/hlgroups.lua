-- Lazygit.
vim.cmd([[
  highlight LazygitMain guifg=#2ac3de
  highlight LazygitActiveBorderColor cterm=bold gui=bold guifg=#ff9e64
  highlight LazygitCherryPickedCommitBgColor guifg=#bb9af7
  highlight LazygitCherryPickedCommitFgColor guifg=#7aa2f7
  highlight LazygitDefaultFgColor guifg=#c0caf5 guibg=#1a1b26
  highlight LazygitInactiveBorderColor guifg=#27a1b9 guibg=#16161e

  highlight link LazygitOptionsTextColor LazygitCherryPickedCommitFgColor
  highlight link LazygitSearchingActiveBorderColor LazygitActiveBorderColor

  highlight LazygitSelectedLineBgColor guibg=#283457
  highlight LazygitUnstagedChangesColor guifg=#db4b4b
]])

-- Vimdiff, from onehalf dark, inspired by signify.
-- `https://github.com/BBaoVanC/onehalf/blob/diff-highlighting/vim/colors/onehalfdark.vim`.
vim.cmd([[
  highlight DiffAdd guifg=#282c34 guibg=#98c379
  highlight DiffChange guifg=#282c34 guibg=#e5c07b
  highlight DiffDelete guifg=#282c34 guibg=#e06c75
  highlight DiffText guifg=#282c34 guibg=#61afef
]])
