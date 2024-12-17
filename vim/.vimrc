# ================================================================================================
# Due to how vscode and the vim extension works, this file must be place on the
# host machine, .e.g. under C://Users/<username>/.vimrc
# ================================================================================================

" Use the Solarized Dark theme
set background=dark
colorscheme solarized
let g:solarized_termtrans=1

" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=" "
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Make tabs as wide as two spaces
set tabstop=2
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace function.
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction

" Strip trailing whitespace.
noremap <leader>ss :call StripWhitespace()<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" noremap <leader>w :w<CR> <-- Clashed with camelCaseMotion

" noremap <leader>vs :vsplit<CR>

" Tab movement.
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>
nnoremap <leader>j :tabnext<CR>
nnoremap <leader>k :tabprevious<CR>

" Go to last active tab.
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>

" Show list of open buffers, i.e. tabs.
noremap <leader>l :ls<CR>

" New tab.
noremap <leader>t :tabnew<CR>

" noremap <leader>e :Explore<CR> <-- Clashed with camelCaseMotion

" Close tab.
noremap <leader>q :q<CR>

" Close tab without saving.
noremap <leader>Q :q!<CR>

" Remove search highlighting.
noremap <leader>h :set hlsearch!<CR>

" Make Y behave like C and D, i.e. yank to end of line.
map Y y$

" Delete without overwriting the yank register.
noremap <leader>d "_d
noremap <leader>dd "_dd
noremap <leader>D "_D
" noremap <leader>p "+p
" noremap <leader>P "+P
" noremap <leader>p "0p (used in vim vscode extension, to open quickMenu)

" noremap <leader>o o<Esc>
" noremap <leader>O O<Esc>

" Remove search highlighting (until next search)
noremap <C-n> :nohl<CR>

" On this approach 'x' acts like classic 'delete' key
" nnoremap x "_x
" vnoremap x "_d
" noremap X "_X
" On this approach 'c' does not copy to working registers
" vnoremap c "_c
" noremap C "_C
" On this approach 'd' acts like classic 'cut' (i.e. copies to working registers)
" vnoremap d "*d:let @+=@*<CR>
" noremap dd "*dd:let @+=@*<CR>
" noremap D "*D:let @+=@*<CR>
" noremap y "*y:let @+=@*<CR>
" noremap yw "*yw:let @+=@*<CR>
" noremap yiw "*yiw:let @+=@*<CR>
" noremap yy "*yy:let @+=@*<CR>
" nnoremap Y "*Y:let @+=@*<CR>
" vnoremap Y "*y`>:let @+=@*<CR>
" Re-yank what just got pasted in visual mode
" vnoremap p pgvy


" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif
