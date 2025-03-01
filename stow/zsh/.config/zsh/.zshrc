# ================================================================
# Notes
# ================================================================
# Five profile scripts gets executed (in the below order) when an zsh shell is launched and closed.
# Place code in .zshenv, .zshrc, and .zprofile.
#
# (1) .zshenv
# Always sourced when any zsh shell lauches, regardless if the shell is a login shell or not, or an interactive shell or not.
# Used to:
# * Set (export) variables that should be available to other programs (e.g. $PATH, $EDITOR, $PAGER, etc.).
# * Set $ZDOTDIR, to specify an alternative location for the rest of the zsh configuration files.
#
# (2) .zprofile
# The Same as .zlogin, except that it's sourced before .zshrc.
# An alternative to .zlogin, for ksh fans. The two are not intended to be used together.
# Used to:
# * Set PATH.
# * Set other exported shell vairables.
# * Note: All exported shell variables, aka. environment variables, are inherited by non-login
#   shells from login shell, beause non-login shells are subshells of parent login shell.
#
# (3) .zshrc
# Only runs when an interactive shell is opened, both for login shell or non-login shells,
# i.e. subshells of login shells.
# Used to:
# * Set options for interactive shells, e.g. with the setopt and unsetopt commands.
# * Set up prompt, alias, and other settings not inherited by subshells from parent shells.
# * Load shell modules, set history options, set up zle and completion, etc.
# * Set variables only used in nteractive shells (e.g. $LS_COLORS).
#
# (4) .zlogin
# Only runs when a login shell is opened (i.e. the first zsh terminal opened after starting vscdoe).
# Runs after .zshrc, if the login shell is also interactive.
# Used to:
# * Start X using startx. Some systems start X on boot, so this file is not always very useful.
#
# (5).zlogout
# Executed when closing a zsh shell.
# Used to clear and reset the terminal.
#
# * Information:
#   - https://unix.stackexchange.com/questions/462663/purpose-of-n-ps1-in-bashrc
#   - https://unix.stackexchange.com/questions/3052/is-there-a-bashrc-equivalent-file-read-by-all-shells
# * Do NOT source .[..]profile from .[..]rc.
#   - .profile, .bash_profile, .zprofile, etc, are login-time scripts, i.e. meant to run ONCE when the first shell session Launches.
#   - As such, they might run programs intended to execute only once per session.
#   - Running .[..]profile every time a shell session launches might override environment variables set by the user manually.
#   - Thus, ideally, one should not run .[..]profile files every time an (interactive) shell opens, only when first parent shell,
#   - aka. login shell, opens.
#   - Login shells are launched when new terminal window is opened.
#   - Non-login shells are launched when login shell spawns a subshell, by running script | subshell command | launching new shell: `zsh`.
#   - Remember to make the dotfiles executable, otherwise they will not run and the setup will not work.
# * Add all environment variables and non-graphical programs (ssh-agent, etc.) to .profile, which is run by other shell's profile files.
#   - .profile is run automatically by bash, sh, dash, and perhaps others, when they are login shells (interactive or not).
#   - Environment variables, i.e. exported shell variables, are visible to subshells because they are exported.
#   - Thus, .profile is ideal for code that should only run once, when the first shell opens.
#   - Zsh does not run .profile directly, instead it runs .zprofile, which in turn runs .profile.
#   - That way, all needed environment variables are sourced in one place, and only once.
# * Add other code, related to interactive shells, to .shrc.
#   - Prompt settings, aliases, non-exported functions, etc.
#   - This file is not sourced automatically by any shell, so source manually in other shell's rc files (.bashrc, .zshrc, etc.).
# * Do NOT source .[..]rc from .[..]profile.
#   - When login shell runs, i.e. when terminal window is first opened, both .[..]profile and .[..]rc runs.
#   - Note: .[..]rc only runs if shell is interactive, which it is when new terminal is opened.
#   - Moreover, shell variables exported in login shell, aka. environment variables, are also set in non-login shells,
#     because they are subshells of login shell.
#   - Thus, since both .[..]rc and .[..]profile are called when new terminal is opened,
#     and .[..]rc runs again in new interactive subshells which inherits environment from parent shell that ran .[..]profile,
#     it is NOT nececcary to source .[..]rc from .[..]profile.
#   - In fact, sourcing .[..]rc from .[..]profile will cause profile to run twice, when new login shell is launched, i.e. when new terminal window is opened.
#   - .[..]profile > .profile && .[..]profile > .[..]rc > .shrc
#
# * Result:
#   - .[..]profile > .profile and .[..]rc > .shrc all run when new terminal is opened, because termianl launches an interactive login shell.
#   - When subshells, i.e. non-login shells, are launched from login shell, .[..]rc > .shrc runs again.
#   - Subshell inherits environment, i.e. all exported shell variables, from parent login shell.
#   - .[..]rc > .shrc sets up aliases and prompt, which are not inherited by subshell from parent login shell, so should run again.
# ================================================================

# ================================================================
# About Login Shells.
# ================================================================
# Information: https://unix.stackexchange.com/questions/38175/difference-between-login-shell-and-non-login-shell
# * A login shell is a shell given to a user upon login into a Unix system.
# * A login shell is the first process that executes under the user's ID, when logging in for an interactive session.
# * A login shell is the shell that executes the commands in the user's .profile file.
# * Terminal emulators start login shell when new terminal window is started.
# * Login process tells shell to behave as login shell by passing argument 0- (0 is normally the name of the shell executable), e.g. -bash instead of bash.
# * Login shells (Bourne shells like sh and bash, but not zsh) read /etc/profile and ~/.profile.
# * If ~/.bash_profile is present, bash only reads that and not ~/.profile.
# * All interactive shells read .[..]rc files, including login shells.
# * When you log in on a text console, or through SSH, or with su -, you get an interactive login shell.
# * When you log in in graphical mode (on an X display manager), you don't get a login shell, instead you get a session manager or a window manager.
# * It's rare to run a non-interactive login shell, but some X settings do that when you log in with a display manager, so as to arrange to read the profile files.
# * Another way to get a non-interactive login shell is to log in remotely with a command passed through standard input which is not a terminal.
#   - For example: ssh example.com script-stored-locally
#   - As opposed to: ssh example.com script-on-remote-machine, which runs non-interactive, login shell.
# * Interactive, non-login shell:
#   - An interactive, non-login shell is launched whenever an interactive shell is started in a terminal in an existing session.
#   - For example by launching shell inside another shell, e.g. with `bash`.
#   - All interactive shells run ~/.[..]rc
#   - By default, there is no ~/.shrc, files that automatically run are ~/bashrc, ~/.zshrc, etc.
#   - $ENV, if set, is also invoked by POSIX/XSI-compliant shells such as dash, ksh, and bash when invoked as `sh`.
# * Non-interactive, non-login shells:
#   - A non-interactive, non-login shell is used whenever shell runs script or command (unless script is executed with exec, which replaces current shell).
#   - Some shells read a startup file in this case.
#   - Bash runs the file indicated by the BASH_ENV variable, zsh runs /etc/zshenv and ~/.zshenv
#   - Using these startup files is risky, as the shell can be invoked in all sorts of contexts and there's hardly anything you can do that might not break something.
# ================================================================

# ================================================================
# .[..]rc should generally only run if shell is interactive,
# but double check here and only procede if shell is interactive.
# ================================================================
[[ $- == *i* ]] || [ -n "$PS1" ] || return

# ================================================================
# Ghostty Shell Integration for ZSH.
# Must be Placed at Top of `.zshrc`.
# ================================================================
# WARNING: Adds small delay, slightly more than `zoxide`.
if [[ -f "${GHOSTTY_RESOURCES_DIR:-$HOME/.local/share/ghostty}/shell-integration/zsh/ghostty-integration" && \
${TERM} == xterm-ghostty ]]; then
  echo "Sourcing Ghostty shell integration..."
  builtin source "${GHOSTTY_RESOURCES_DIR:-$HOME/.local/share/ghostty}/shell-integration/zsh/ghostty-integration"
fi

# ================================================================
# iTerm2 Shell Integration for ZSH.
# ================================================================
if [[ -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && \
${TERM} == xterm-256color ]]; then
  echo "Sourcing iTerm shell integration..."
  source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
fi

# ================================================================
# Run Generic Interactive Shell Configuration.
# ================================================================
echo "Running .zshrc, about to source .shrc..."
source "$HOME/.shrc"

# ================================================================
# ZSH Options.
# ================================================================
# History file for ZSH, overwrites bash default which is sset to
# `/commandhistory/.shell_hisotry` in `.shrc`.
HISTFILE=/commandhistory/.zsh_history
# Turn off `INC_APPEND_HISTORY` when `SHARE_HISTORY` is set,
# as `SHARE_HISTORY` also makes ZSH append every command to history file,
# when command is typed, just like `INC_APPEND_HISTORY`.
setopt SHARE_HISTORY
# For some reason, when exiting `tmux` with `EOF` on stdin,
# i.e. `ctrl+d`, history timing was deleted and it was not possible
# to read history without restarting shell.
# `EXTENDED_HISTORY` fixes it, by keeping timing information in history.
# Note: It is necessary to hit ENTER, or run any other command,
# for history file to be read again, SIGINT, i.e. `ctrl-c`, is insufficient.
setopt EXTENDED_HISTORY

# ================================================================
# Autoload Own and Built-In Functions.
# ================================================================
fpath=(${ZDOTDIR:-$HOME}/.zfunc $fpath)
autoload -U rgf

# ================================================================
# ZSH Completetions.
# ================================================================
# `zsh-completions`.
# - Manually cloned into ZSH_HOME, not installed with pacman.
fpath=("${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions/src" $fpath)

# `eza` completions`.
# - `eza` itself is installed with `cargo`.
# - `eza` completions are enabled by cloning `eza` git repo
#   into `EZA_HOME/eza` then adding it to `fpath` below.
export FPATH="${EZA_HOME:-$HOME/.local/share/eza}/eza/completions/zsh:$FPATH"

# Activate ZSH completion engine.
autoload -Uz compinit

# Force rebuild of `.zcompdump`.
rm -f "${ZDOTDIR}/.zcompdump"; compinit

# ================================================================
# Enable vi mode in zsh (at end of zshrc).
# ZSH_HOME: ZSH plugin directory.
# ================================================================
# - ZLE comes with several sets of key bindings, called keymaps.
#   - `emacs`.
#   - `viins`.
#   - `vicmd`.
#   - `viopp`.
#   - `visual`.
# - These keymaps determine what different keys do in ZSH.
# - `main`.
#   - Name which holds either `emacs` or `viins`, used as keymap when `ZLE` starts.
#   - When `EDITOR` | `VISUAL` is set to string containing `vi`, which it is,
#     `main` is automatically set to `viins`.
#   - Thus, `bindkey -v` not needed, vi mode is used by default,
#     since `EDITOR` and `VISUAL` is `nvim`.
# - Since `main` is `viins`, ZLE starts in Vim Insert mode, not Normal mode.
# - To start in `vicmd` mode, call `zle -K vicmd` inside `zle-line-init`,
#   alongside `zle -N zle-line-init`, see docs for example.
# - `bindkey -lL main`: See which mode is linked to `main`, i.e. now used.
# - `bindkey [key]`: List key bindings in `main` keymap, i.e. `viins`, for <key>.
#   - Omit <key> to show all bindings in current keymap.
# - `bindkey -a [key]`: List key binding in `vicmd` keymap, for <key>.
#   - Omit <key> to show all bindings in `vimcmd` keymap.
#   - Neither `bindkey -e` for `emacs`, nor `bindkey -v` for `viins`
#     works to show their bindings, use `-M <keymap>` instead.
# - `bindkey -M <keymap>`: List key bindings for <keymap>.
# - When no keymap is given to `bindkey` command, e.g. with options
#   like `-v` or `-M vicmd`, `main` is used by default.
# - `KEYTIMEOUT`: Parameter specifying time to wait for another keypress,
#   when one key is prefix for another. Default: 40 centi-seconds, i.e. 400 ms.
# - `^[`: ESC, which by default is bound to `vi-cmd-mode`, will undo everyting done in
#   last insert mode.
# bindkey -v
# Alternative, with more key bindings than default built-in:
# source ${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode/zsh-vi-mode.plugin.zsh

# ================================================================
# Set up fzf key bindings, e.g. <C-T>, <C-R>, <A-C>, and fuzzy completion.
# Must be done after fzf has been added to PATH,
# and after the vi mode settings above.
# ================================================================
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi
source <(fzf --zsh)

# ================================================================
# Start Zoxide, at end of zshrc, AFTER compinit.
# Docker desktop should run to avoid error message form compinit.
# ================================================================
# WARNING: Ads tiny delay.
eval "$(zoxide init zsh)"

# ================================================================
# Enable zsh-autocomplete.
# ================================================================
# Do not use this, implement own completions.
# source "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# ================================================================
# Enable zsh-autosuggestions (end of zshrc).
# ================================================================
# No delay introduced.
# Set suggestion strategy.
# - `history`: Most recent match from history.
# - `completion`: Uses tab-completion suggestion.
# - Can be combined in array, in which case next entry is tried if no match in first entry.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Set suggestion highlight style.
# - Can be 256-color ANSII escape sequence digit, e.g. `fg=8`,
#   or hexadecimal value.
# - See: `man zshzle` > Character Highlighting.
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=243"

# Activate `zsh-autosuggestions`.
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Use key bindings similar to Neovim completion mode,
# where `^y` is accept match, and `^e` is stop completion and
# go back to old text.
bindkey '^ ' autosuggest-accept
bindkey '^y' autosuggest-execute
bindkey '^e' autosuggest-clear

# ================================================================
# Keybindings: Built-In.
# ================================================================
# Note: Delay when typing `^[`, i.e. escape.
# - When key is prefix in any key binding, that key get `KEYTIMEOUT`
#   delay after typing, before its standalone binding is used.
# - Done to ensure enough time to type full sequence.
# - It is possible to remove all key bindings in `viins` keymap beginning
#   with `^[`, i.e. escape character, including most likely cursor keys,
#   but leaving binding for `^[` itself, which maps to `vi-cmd-mode` widget.
# - Result: No delay when typing `^[`.
# - BUT, these default keybindings are lost:
#   - "^[" vi-cmd-mode
#   - "^[," _history-complete-newer
#   - "^[/" _history-complete-older
#   - "^[OA" up-line-or-history
#   - "^[OB" down-line-or-history
#   - "^[OC" vi-forward-char
#   - "^[OD" vi-backward-char
#   - "^[[200~" bracketed-paste
#   - "^[[A" up-line-or-history <-- Up arrow.
#   - "^[[B" down-line-or-history <-- Down arrow.
#   - "^[[C" vi-forward-char <-- Right arrow.
#   - "^[[D" vi-backward-char <-- Left arrow.
#   - "^[c" fzf-cd-widget
#   - "^[~" _bash_complete-word
# - Accepting suggestions from `zsh-autosuggest` is done
#   with right arrow in `viins` or `vicmd` mode, or `l` in `vicmd` mode,
#   both mapping to `[vi-]forward-char`, and `$` in `vicmd` mode,
#   i.e. `[vi-]end-of-line`, thus loose default bindind to accept suggestion
#   from `viins` mode.
# - Since ghostty maps `Ctrl+[` to '^[[91;5u', and not to `^[`,
#   it is better to just map that to `vi-cmd-mode`, instead of forcing
#   ghostty to send `^[` and removing all key bindings that start with `^[`.

# ================================================================
# Set 10ms delay after pressing Escape or `^[`.
# ================================================================
# Better to remove all bindings starting with `^[`, as `KEYTIMEOUT`
# might be used for other bindings besides those starting with `Escape`,
# like all the motion commands.
# Set 10ms delay after pressing Escape or `^[`.
# export KEYTIMEOUT=1
bindkey -rpM viins '^['

# Bind sequence sent by terminal, when `fixterm` is enabled,
# for `Ctrl+[`, i.e. `^[[91;5u`,to `vi-cmd-mode`,
# with added benefit of no `KEYTIMEOUT` delay.
# ZSH deletes line if `Escape` is hit in `vicmd` mode,
# not sure why.
# Only for ghostty, as other terminals do not use `fixterm` by default.
# bindkey '^[' self-insert
[[ ${TERM} == xterm-ghostty && ! -n "$TMUX" ]] && bindkey '^[[91;5u' vi-cmd-mode

# bindkey -M viins '^[' self-insert
# bindkey -M viins '^1' self-insert
# bindkey -M viins '^2' self-insert
# bindkey -M viins '^i' self-insert
# bindkey -M viins '^m' self-insert

# Ensure `^w` and `^h` deletes past last insert.
bindkey -M viins '^h' backward-delete-char
bindkey -M viins '^w' backward-kill-word

# Search command history for line starting with current line up to cursor.
# If line is empty, moves to next/previous event in history list.
# Overwrites default `self-insert` in mode `viins`.
# Overwrites default `down-history` in mode `vicmd`.
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# bindkey '^k' up-line-or-search
# bindkey '^j' down-line-or-search
# bindkey '^[[A' up-line-or-search
# bindkey '^[[B' down-line-or-search

# bindkey '^[[A' up-line-or-beginning-search # Up
# bindkey '^[[B' down-line-or-beginning-search # Down

# ================================================================
# Source Script for Prompt Configuration.
# ===============================================================
. ${ZDOTDIR:-$HOME}/.zsh_prompt

# ================================================================
# Export zsh-syntax-highlighting shell variables here instead of
# in .zprofile, because they only apply to interactive shells.
# IMPORTANT: Sourcing must be done at end of `.zshrc`, even after
# bindkey statements.
# ================================================================
# Declare an associative array variable, to which values are added below.
typeset -A ZSH_HIGHLIGHT_STYLES

# To differentiate aliases from other command types
export ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'

# To have paths colored instead of underlined
export ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

# To disable highlighting of globbing expressions
export ZSH_HIGHLIGHT_STYLES[globbing]='none'

# Command color (git etc.)
export ZSH_HIGHLIGHT_STYLES[command]='fg=yellow'

# Quoted argument color
export ZSH_HIGHLIGHT_STYLES["single-quoted-argument"]='fg=green'
export ZSH_HIGHLIGHT_STYLES["double-quoted-argument"]='fg=green'

# Source script, installed with pacman, as last command in `.zshrc`.
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ================================================================
# oh-my-zsh settings.
# Not using oh-my-zsh, but keeping the settings here for reference.
# ================================================================
# Path to your Oh My Zsh installation.
# export ZSH="$ZSH_HOME/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)

# source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# pnpm
export PNPM_HOME="/home/nfu/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
