--===========================================
-- Built-in functions.
--===========================================
-- Activate LSP debug mode.
-- vim.lsp.set_log_level 'debug'

--===========================================
-- Variables.
--===========================================
---------------------------------------------
-- File-related variables.
---------------------------------------------
-- Fix markdown indentation settings.
vim.g.markdown_recommended_style = 0

-- Toggle symbols cache.
vim.g.symbols_cache = false

-- Set default browser for markdown preview.
-- vim.g.mkdp_browser = "firefox"
vim.g.mkdp_browser = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

---------------------------------------------
-- Helper functions.
---------------------------------------------
-- Helper function that allows applying code action fix,
-- if there is only one code action with the specified title.
-- local apply_code_action_fix = function()
--   vim.lsp.buf.code_action({
--     filter = function(code_action)
--       if vim.startswith(code_action.title, "Apply suggested fix") then
--         return true
--       end
--       return false
--     end,
--     apply = true,
--   })
-- end

---------------------------------------------
-- Mapleader.
---------------------------------------------
-- Set `<space>` as leader key.
-- See: `:help mapleader`.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

---------------------------------------------
-- AI variables.
---------------------------------------------
-- CodeCompanion.
---------------------------------------------
-- `vim.g.codecompanion_auto_tool_mode`
-- - Automatically approves any tool use, instead of prompting user.
-- - Disables diffs.
-- - Automatically saves buffers agent has edited.
-- - `gta`: Toggles same feature in chat buffer.
vim.g.codecompanion_auto_tool_mode = true

---------------------------------------------
-- MCPHub.
---------------------------------------------
-- Auto approve MCPHub commands, e.g. file CRUD commands.
vim.g.mcphub_auto_approve = true

---------------------------------------------
-- Miscellaneous variables.
---------------------------------------------
-- Disable auto format on save.
-- vim.g.autoformat = false

-- Change picker from default `fzf-lua`:
-- - `fzf-lua`.
-- - `telescope`.
-- vim.g.lazyvim_picker = "telescope"

-- Change completion engine from default `blink.cmp`:
-- - `blink.cmp`.
-- - `nvim-cmp`.
-- vim.g.lazyvim_cmp = "auto"

-- Determine if Copilot suggestions | completion menu entries should show as ghost text.
-- - `true`:
--   - Copilot suggestions (`plugins/addons/ai.lua`):
--     - NOT ghost text.
--     - ONLY completion menu, including documentation window.
--     - ALSO ghost text when selected in completion menu.
--   - Completion menu entries (`plugins/blink.lua`):
--     - BOTH ghost text, of first entry in menu.
--     - AND completion menu, including documentation window.
-- - `false`:
--   - Copilot suggestions (`plugins/addons/ai.lua`):
--     - ONLY ghost text.
--     - NOT completion menu.
--   - Completion menu entries (`plugins/blink.lua`):
--     - NOT ghost text, of first entry in menu.
--     - ONLY completion menu (documentation window).
-- vim.g.ai_cmp = true
vim.g.ai_cmp = false

-- - `root_spec`: Used by `MyVim.root.get()` to change MyVim root directory detection.
-- - Options:
--   - Name of detector function, e.g. `lsp` | `cwd`.
--     - `lsp` : Detect root from LSP server.
--   - Pattern or array of patterns, e.g. `.git` | `lua`.
--     - `.git`: Use folder containing first `.git` folder above current buffer.
--   - Function with signature `function(buf) -> string|string[]`.
-- - If `root_spec` is not set here:
--   - Default from `MyVim.root.spec` is used.
--   - `{ "lsp", { ".git", "lua" }, "cwd" }`.
-- - `MyVim.root.get()` used by:
--   - `fzf.lua`: Determine root of project, when opening picker from buffer root.
--   - `lualine.lua`: Show path to current file, relative to root.
-- - Prefer:
--   - Leave default from `MyVim.root.spec`.
--   - Set `root_dir` for `vtsls` to `.git`, to ensure `fzf.lua` uses `.git` as buffer root,
--     since `fzf.lua` picker uses `lsp` as root detector by default.
--   - Set `root_lsp_ignore` list below, so only `vtsls` is used for TS files,
--     since e.g. `copilot` uses `cwd` as root.
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- - `root_lsp_ignore`: Used by `MyVim.root.get()`, to exclude given LSP servers
--   when using `lsp` as root detector, which is default root detector used when
--   calling `MyVim.root.get()`.
-- - Important to exclude `copilot`, which uses `cwd` as root.
vim.g.root_lsp_ignore = { "biome", "eslint", "tailwindcss", "copilot" }

-- Show current document symbols location from Trouble in `lualine`.
-- Disable for buffer: `vim.b.trouble_lualine = false`.
vim.g.trouble_lualine = true

-- Template directory for new markdown files, created with `:MarkdownNewTemplate`.
vim.g.template_dir = MyVim.root() .. "/templates"

-- Used to determine icons in `Lazy` ui.
vim.g.have_nerd_font = true

-- - Optionally set built-in Neovim terminal to use, including configuration.
-- - If not used, built-in Neovim terminal defaults to `$SHELL`.
-- - In addition to setting which shell Neovim should use for built-in terminal,
--   `MyVim.terminal.setup("pwsh")` also does additional configuration for:
--   * pwsh
--   * powershell
-- MyVim.terminal.setup("pwsh")

--===========================================
-- Options.
--===========================================
local opt = vim.opt

-- Write modified file on:
-- - `:next`, `:rewind`, `:last`, `:first`, `:previous`.
-- - `:stop`, `:suspend`, `:tag`, `:!`, `:make`.
-- - CTRL-], CTRL-^.
-- - `:buffer`, CTRL-O, CTRL-I, `{A-Z0-9}`, `{A-Z0-9}`.
opt.autowrite = true

-- Ensure wrapped lines continue visually indented, same amount as beginning of line,
-- thus preserving horizontal blocks of text.
opt.breakindent = true

-- Sync with system clipboard if not in SSH,
-- to make sure OSC 52 integration works automatically.
-- opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "myClipboard",
  copy = {
    ["+"] = { "pbcopy", "-" },
    ["*"] = { "pbcopy", "-" },
  },
  paste = {
    ["+"] = { "pbpaste" },
    ["*"] = { "pbpaste" },
  },
  cache_enabled = 1,
}

-- vim.g.clipboard = [[{
--           \   'name': 'myClipboard',
--           \   'copy': {
--           \      '+': ['tmux', 'load-buffer', '-'],
--           \      '*': ['tmux', 'load-buffer', '-'],
--           \    },
--           \   'paste': {
--           \      '+': ['tmux', 'save-buffer', '-'],
--           \      '*': ['tmux', 'save-buffer', '-'],
--           \   },
--           \   'cache_enabled': 1,
--           \ }]]

-- Insert mode completion options (default: `menu,preview`):
-- - `menu`    : Popup menu to show completions.
-- - `menuone` : Popup menu also when only one completion option.
-- - `noselect`: Only insert match text if selected, no preselection.
opt.completeopt = "menu,menuone,noselect"

-- Hide text with `conceal` syntax attribute,
-- unless text contains replacement character `*`.
opt.conceallevel = 2

-- Confirm saving changes, before exiting modified buffer.
opt.confirm = true

-- Highlight current line.
-- opt.cursorline = true
opt.cursorline = false

-- Make vim diff windows vertical by default.
opt.diffopt:append({ "vertical" })

-- Convert typed tab character to spaces, following `opt.tabstop`.
opt.expandtab = true

opt.fillchars = {
  -- Fold fill characters.
  -- Ignored if using own `statuscolum` implementation: `util/statuscolumn.lua`.
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",

  -- Fill character in `vimdiff`, for deleted lines.
  diff = "╱",

  -- Fill characters below last line of buffer.
  eob = " ",
}

-- Use treesitter to create folds.
opt.foldexpr = "v:lua.require'myvim.util'.ui.foldexpr()"
opt.foldmethod = "expr"

-- Start with all folds open.
opt.foldlevel = 99

-- Use custom foldtext, with treesitter syntax highlighting
-- and additonal information appended.
opt.foldtext = "v:lua.require'myvim.util.ui'.foldtext()"

-- Function used for `gq` operator.
opt.formatexpr = "v:lua.require'myvim.util.format'.formatexpr()"

-- `formatoptions` determines which lines these apply to:
-- - `opt.textwidth`.
-- - `gq` command.
-- Prefer `wrap`|`linebreak` over `textwidth`, former do NOT insert EOL, just visually drops text to next line.
-- - Default: `tcqj`.
-- - Note: Filtype plugins, e.g. `vim.vim` and `typescript.vim`, append `croql` and remove `t`,
--   to avoid inserting EOL in source code.
-- Good: `opt.textwidth = 90`, `formatoptions = "jcroqln"`, alt. inc. `t`.
-- Exclude `t`, to avoid inserting EOL in source code, since `textwidth` is set.
-- `opt.formatoptions` options (`:h fo-table`):
-- `t`: Autowrap text, i.e. code, using `textwidth`.
-- `c`: Autowrap comments, using `textwidth`.
-- `q`: Allow formatting of comments with `gq`.
-- `j`: Remove comment leader when joining lines.
-- `r`: Automatically insert comment leader when hitting Enter in Insert mode.
-- `o`: Automatically insert comment leader when hitting `o` or `O` in Normal mode.
-- `l`: Lines are not broken when cursor gets to end of `textwidth`,
--      when they are already longer than `textwidth` when starting Insert mode.
-- `n`: When formatting text (also comments), lists are recognized using `opt.formatlistpat`,
--      so indent is applied to next list matching indent of text on first list line.
opt.formatoptions = "jncroql"

-- Substitute all matches on each line, not just first, wihout having to specify /g.
-- `%/replaceMe/newText/c` will consider all matches in each line.
opt.gdefault = true

-- Format of ":grep" output, default `%f:%l:%m,%f:%l%m,%f  %l%m`.
-- When `grepprg` set to `ripgrep|rg`, default: `%f:%l:%c:%m`.
-- Set to same value s default, to be safe.
-- - `%f`: File name.
-- - `%l`: Line number.
-- - `%c`: Column number.
-- - `%m`: Error message.
opt.grepformat = "%f:%l:%c:%m"

-- Program to use for `:grep`.
opt.grepprg = "rg --vimgrep -uu"

-- Case-insensitive searching, see `opt.smartcase`.
-- unless \C or search term has one or more capital letters.
opt.ignorecase = true

-- Preview substitutions live, as typing.
opt.inccommand = "nosplit"

-- Behavior of jumplist, default: `clean`.
-- - `clean`: Remove unloaded buffers from jumplist.
-- - `view`: When moving through jumplist, changelist, alternate-file,
--           or using mark-motions, restore mark-view in which jump occurred.
opt.jumpoptions = "view"

-- `statusline` on last window only, not one per window, i.e. global `statusline`.
-- Needed, as views can only be fully collapsed with global `statusline`.
opt.laststatus = 3

-- Visually wrap long lines at character in `opt.breakat`, e.g. on whitespace,
-- i.e. ` ^I!@*-+;:,./?`, rather than at last character that fits on screen,
-- which would have been default if `wrap` was set without `linebreak`.
-- Unlike `wrapmargin` and `textwidth`, `linebreak` does not insert <EOL>s in file,
-- it only affects way file is displayed, not its contents.
-- Note: <Tab> after <EOL> is not displayed with correct white space.
-- Note: `opt.linebreak` is not used if `opt.wrap` is off.
opt.linebreak = true

-- Show invisible characters.
opt.list = true
opt.listchars = {
  tab = "!>",
  -- space = "·",
  -- trail = "·",
  nbsp = "␣",
  extends = "▶",
  precedes = "◀",
}

-- Enable mouse in Neovim, default: `nvi`.
-- - `n`: Normal mode.
-- - `v`: Visual mode.
-- - `i`: Insert mode.
-- - `c`: Command-line mode.
-- - `h`: All previous modes when editing help file.
-- - `a`: All previous modes.
-- - `r`: For hit-enter and more-prompt prompt.
opt.mouse = "a"

-- Show line numbers.
opt.number = true

-- `:find` will start its search from `path`.
-- Default `path` is `.,,`, which means folder of current file, and current working directory.
-- vim.opt.path:append { '**' }
opt.path = ".,,**"

-- Enables pseudo-transparency for popup-menu,
-- from 0 to 100, i.e. fully transparent.
opt.pumblend = 10

-- Maximum number of entries in popup.
opt.pumheight = 10

-- Show relative line numbers, needed for custom statuscolumn
-- to recalculate items on each cursor move.
opt.relativenumber = true

-- Disable default ruler, shown in stausline instead.
opt.ruler = false

-- Minimal number of screen lines to keep above and below cursor.
-- opt.scrolloff = 4
opt.scrolloff = 10

-- Set items saved|loaded with `:mksession`.
-- Default: `blank,buffers,curdir,folds,help,tabpages,winsize,terminal`.
-- - `blank`   : Empty windows.
-- - `curdir`  : Current directory.
-- - `folds`   : Manually created folds, opened/closed folds, local fold options.
-- - `globals` : Global Number|String variables starting with uppercase, containing at least one lowercase letter.
-- - `help`    : Help window.
-- - `skiprtp` : Exclude `runtimepath` and `packpath` from saved|loaded options.
-- - `tabpages`: All tabpages, wihout which only current tab is restored.
-- - `winsize` : Window size.
opt.sessionoptions = { "buffers", "curdir", "folds", "globals", "help", "skiprtp", "tabpages", "winsize" }

-- Round indent to multiple of shiftwidth.
opt.shiftround = true

-- Number of spaces to use for each step of (auto)indent.
-- Used for `cindent`, `>>`, `<<`, etc.
opt.shiftwidth = 2

-- Append options for file messages, e.g. from CTRL-G, default: `ltToOCF`.
-- - `l`: Use "999L, 888B" instead of "999 lines, 888 bytes".
-- - `t`: Truncate file message at start if too long to fit command-line.
-- - `T`: Truncate other messages in middle if too long to fit command-line.
-- - `o`: Overwrite message for writing file with subsequent message for reading file.
-- - `O`: Message for reading file overwrites any previous message.
-- - `F`: Do not give file info when editing file, `:silent` was used for command.
-- - `W`: Do not print "written" | "[w]" when writing file.
-- - `I`: Do not print intro message when starting Vim.
-- - `c`: Do not print ins-completion-menu messages, e.g. "match 1 of 2".
-- - `C`: Do not print messages while scanning for ins-completion items, e.g. "scanning tags".
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- Dont show mode, e.g. Insert|Normal, use custom `statusline` instead.
opt.showmode = false

-- Minimal number of screen columns to keep to left and right of cursor, if 'nowrap' is set.
opt.sidescrolloff = 8

-- Do not show signcolumn, if using own custom version.
-- Skip, using `snacks.statuscolumn`.
-- opt.signcolumn = "no"

-- Consider casing of search term when `\C` flag is used, or search term has capital letter(s).
opt.smartcase = true

-- Insert indents automatically.
opt.smartindent = true

-- Smoothscroll when scrolling with mouse, by scrolling with screen lines, not buffer lines.
opt.smoothscroll = true

-- When on, spell checking will be done.
-- Automatically set to true for markdown and text files, in `config/autocmd.lua`.
-- opt.spell = true

-- When `opt.spell` is on, spellchecking is done for these languages.
-- Example: `en_us,nl,medical`.
-- Default: `en`.
opt.spelllang = { "en" }

-- Set spellfile to use.
opt.spellfile = vim.fs.abspath("~/.config/nvim/spell/en.utf-8.add")

-- When horizontally splitting window, put new window below current window.
opt.splitbelow = true

-- Scroll behavior when opening, closing, or resizing horizontal splits.
-- Default: `cursor`.
-- `cursor`: Keep same relative cursor position.
-- `screen`: Keep text on same screen line.
opt.splitkeep = "screen"

-- When vertically splitting window, e.g. `vs`, put new window to right of current window.
opt.splitright = true

-- Using custom `statuscolumn`, i.e. margin to left containing:
-- Gitsigns (or other signs), diagnostics, todo-comments, line numbers, fold icons, border, etc.
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
-- opt.statuscolumn = [[%!v:lua.require'myvim.util.statuscolumn'.get()]]

-- Number of spaces tabs count for.
opt.tabstop = 2

-- True color support.
opt.termguicolors = true

-- Set absoute width of lines, similar to `wrapmargin`.
-- Prefer `wrap`|`linebreak` over `textwidth`, former do NOT insert EOL, just visually drops text to next line.
-- `wrapmargin` is relative to screen width, whereas `textwidth` is absolute.
-- `wrapmargin` is not used when `textwidth` is set.
-- `textwidth` only applies to newly inserted text, not existing text.
opt.textwidth = 80

-- Time in milliseconds to wait for mapped sequence to complete.
-- Lower than default, 1000, to quickly trigger which-key.
opt.timeoutlen = 300

-- Saves undo history to an undo file when writing buffer to file,
-- and restores undo history from the same file on buffer read.
opt.undofile = true

-- Maximum number of changes that can be undone, default `1000`.
opt.undolevels = 10000

-- If nothing types after this many milliseconds, write swap file to disk.
-- If cursor held this many milliseconds, trigger `CursorHold` autocmd.
-- Default: 4000.
opt.updatetime = 200

-- Allow cursor to move where there is no text in visual block mode.
opt.virtualedit = "block"

-- What to do each time <Tab> is pressed, default `full`:
-- - `full`   : Complete next full match on each <Tab> press.
--              After last match, original string is used,
--              and then first match again.
--              Will also start 'wildmenu' if enabled.
-- - `longest`: Complete till longest common string.
--              If this does not result in longer string, use next part.
-- - `list`   : When more than one match, list all matches.
-- Thus, `longest:full,full` will on first <Tab> complete sentence with longest common match,
-- then on next two <Tab>s complete next full matches.
-- opt.wildmode = 'list:full'
opt.wildmode = "longest:full,full"

-- Wildcards, e.g. `*` when used in {file}, should not expand into `node_moduels`.
-- `**/node_modules/**` works for all leves.
-- Dotfiles and folders are excluded from wildcard expansion list by default,
-- but will be auto-completed if file starts with dot: .<tab>.
opt.wildignore:append({ "**/node_modules/**" })

-- Ignore case when completing file names and directories.
-- Has no effect when 'fileignorecase' is set.
-- Does not apply when shell is used to expand wildcards, which happens when special characters.
opt.wildignorecase = true

-- Minimal column width of window, when not current window.
opt.winminwidth = 5

-- When off, lines longer than width of window will not visually wrap.
-- When off, `linebreak` has no effect.
-- Default: `on`, meaning lines visually wrap without inserting EOL,
-- either at last character that fits screen,
-- or at characters in `opt.breakat` if `opt.linebreak` is set.
-- Keep on to visually wrap source code, while `textwidth` inserts EOL into comments.
-- opt.wrap = false
