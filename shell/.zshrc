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
# Ghostty shell integration for Bash.
# Must be placed at top of bashrc.
# ================================================================
if [ -n "${GHOSTTY_RESOURCES_DIR:-/usr/share/ghostty}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR:-/usr/share/ghostty}/shell-integration/zsh/ghostty-integration"
fi

# ================================================================
# Run Generic Interactive Shell Configuration.
# ================================================================
echo "Running .zshrc, about to source .shrc..."
source ~/.shrc

# ================================================================
# ZSH Options.
# ================================================================
# History file for ZSH, overwrites bash default which is sset to
# `/commandhistory/.shell_hisotry` in `.shrc`.
HISTFILE=/commandhistory/.zsh_history
# setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
# setopt SHARE_HISTORY

# ================================================================
# Autoload functions.
# ================================================================
fpath=($HOME/.zfunc $fpath)
autoload -U rgf
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# ================================================================
# Export zsh-syntax-highlighting shell variables here instead of
# in .zprofile, because they only apply to interactive shells.
# ================================================================
source ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Declare the variable
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

# ================================================================
# Completetions.
# ================================================================
source "$HOME/zsh/completion.zsh"
export EZA_HOME="$HOME/.local/share/eza/eza"
export FPATH="$EZA_HOME/completions/zsh:$FPATH"

eval "$(register-python-argcomplete pipx)"

# ================================================================
# Enable vi mode in zsh (at end of zshrc).
# ZSH_HOME: ZSH plugin directory.
# ================================================================
# bindkey -v
# Alternative, more bindings:
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
eval "$(zoxide init zsh)"

# ================================================================
# Enable zsh-autocomplete.
# ================================================================
# Do not use this, implement own completions.
# source "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# ================================================================
# Enable zsh-autosuggestions (end of zshrc).
# ================================================================
source ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autosuggestions/zsh-autosuggestions.zsh

# ================================================================
# Keybindings.
# ================================================================
bindkey '^w' autosuggest-execute
bindkey '^y' autosuggest-accept
bindkey '^u' autosuggest-toggle
# bindkey '^L' vi-forward-word

bindkey '^j' up-line-or-search
bindkey '^k' down-line-or-search

bindkey '^[[A' up-line-or-beginning-search # Up
bindkey '^[[B' down-line-or-beginning-search # Down

# ================================================================
# Run Starship Prompt Configuration.
# ===============================================================
eval "$(starship init zsh)"

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
