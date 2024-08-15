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
#
# (3) .zshrc
# Only runs when an interactive shell is opened.
# Used to:
# * Set options for interactive shells, with the setopt and unsetopt commands.
# * Load shell modules, set history options, change the prompt, set up zle and completion, et cetera.
# * Set variables that are only used in the interactive shell (e.g. $LS_COLORS).
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
# * Do NOT source .[..]profile from .[..]rc files.
#   - .profile, .bash_profile, .zprofile, etc, are login-time scripts, i.e. meant to run ONCE when the first terminal instance Launches.
#   - As such, they might run programs intended to execute only once per session.
#   - Running .[..]profile every time a terminal launches might override environment variables set by the user manually.
#   - Thus, ideally, one should not run .[..]profile files every time an (interactive) shell opens.
#   - To keep it simple, however, both WSL and vscode starts a login shell when a new terminal window opens, which means relevant .[..]profile files run.j
#   - WSL starts every new terminal window as a login shell.
#   - vscode first runs a login shell when it starts, which runs .profile and potentiallly the .[..]profile of the default shell (not sure).
#   - vscode then runs another login shell when the integrated terminal is opened, which in turn spins up a sub-shell (non-login shell) used for the integrated terminal.
#   - Thus, WSL will show each terminal window as a login shell, whereas vscode will not, but both have run the .[..]profile files when the terminal launched.
#   - Thus, in both WSL and vscode, when a new terminal is opened the .[..]profile files run.
#   - Remember to make the dotfiles executable, otherwise they will not run and the setup will not work.
# * Add all environment variables and non-graphical programs (ssh-agent, etc.) to .profile, which is run by the other shell's profile files.
#   - .profile is run automatically by bash, sh, dash, and perhaps others, when they are login shells (interactive or not).
#   - Thus, .profile is ideal for code that should only run once, when the first shell opens.
#   - Zsh does not run .profile by default, instead it runs .zprofile, so run .profile from .zprofile.
#   - That way, all needed environment variables are sourced in one place, and only once.
# * Add all other code, related to interactive shells, to .shrc.
#   - Prompt settings, aliases, functions, etc.
#   - This file is not sourced automatically by any shell, so we source it manually in other shell's rc files (.bashrc, .zshrc, etc.).
# * Source .[..]rc from .[..]profile.
#   - rc files do not run when the first shell, aka. the login shell, launches.
#   - profile files always run when the first shell, aka. the login shell, launches, regardless if it is an interactive shell or not.
#   - Therefore, run the rc file belonging to the profile file from the profile file, if the shell (which is a login shell) is interactive.
#   - That ensures setup code for interactive shells run both for the first shell, aka. the login shell (if interactive), and for subserquent (non-login) shells.
#   - .[..]profile > .profile && .[..]profile > .[..]rc > .shrc
# * Result:
#   - code in .[..]profile and .profile runs when the first shell is openend, so environment variables and ssh-agents, etc. are available to all shells from the start.
#   - code in .shrc, .[..]profile, and .profile also run whenever an interactive shell is opened, whether it is the first shell, aka. the login shell, or not.
# * IMPORTANT:
#   - In WSL, every new terminal window is a login shell, so .[..]profile files are sourced.
#   - In vscode, every new terminal window launches a login shell, which in turn spins up a sub-shell (non-login shell) used as the shell for the integrated terminal.
#   - Thus, WSL will show each terminal window as a login shell, whereas vscode will not.
#   - Thus, both WSL and vscode runs the .[..]profile files when a new terminal window is opened.
#   - Remember to make the dotfiles executable, otherwise they will not run and the setup will not work.
#
# ================================================================

# ================================================================
# About Login Shells.
# ================================================================
# Information: https://unix.stackexchange.com/questions/38175/difference-between-login-shell-and-non-login-shell
# * A login shell is a shell given to a user upon login into a Unix system.
# * A login shell is the first process that executes under the user's ID, when logging in for an interactive session.
# * A login shell is the shell that executes the commands in the user's .profile file.
# * The login process tells the shell to behave as a login shell by passing argument 0- (0 is normally the name of the shell executable), e.g. -bash instead of bash.
# * Login shells (Bourne shells like sh and bash, but not zsh) read /etc/profile and ~/.profile.
# * If ~/.bash_profile is present, bash only reads that and not ~/.profile.
# * A login shell does not read .[..]rc files.
# * When you log in on a text console, or through SSH, or with su -, you get an interactive login shell.
# * When you log in in graphical mode (on an X display manager), you don't get a login shell, instead you get a session manager or a window manager.
# * It's rare to run a non-interactive login shell, but some X settings do that when you log in with a display manager, so as to arrange to read the profile files.
# * Another way to get a non-interactive login shell is to log in remotely with a command passed through standard input which is not a terminal.
#   - For example: ssh example.com <my-script-which-is-stored-locally
#   - As opposed to: ssh example.com my-script-which-is-on-the-remote-machine, which runs a non-interactive, non-login shell.
# * Interactive, non-login shell:
#   - An interactive, non-login shell is launched whenever an interactive shell is started in a terminal in an existing session.
#   - For example by launching a shell inside another shell with e.g. `bash`.
#   - Interactive, non-login shells read ~/.[..]rc
#   - By default, there is no ~/.shrc, so the files that automatically run are ~/bashrc, ~/.zshrc, etc.
#   - $ENV, if set, is also invoked by POSIX/XSI-compliant shells such as dash, ksh, and bash when invoked as `sh`.
# * Non-interactive, non-login shells:
#   - A non-interactive, non-login shell is used whenever a shell runs a script or a command runs (unless script is executed with exec, which replaces the current shell).
#   - Some shells read a startup file in this case
#   - Bash runs the file indicated by the BASH_ENV variable, zsh runs /etc/zshenv and ~/.zshenv
#   - Using these startup files is risky, as the shell can be invoked in all sorts of contexts and there's hardly anything you can do that might not break something.
#
# ================================================================

# ================================================================
# Source the .zprofile here, since vscode seems to be tricky,
# when it comes to running the login shell first.
# ================================================================
source ~/.zprofile

# ================================================================
# Only Proceed if the Shell is an Interactive Shell.
# Other Setup Code, Meant to Apply to All Shells, Should Be Placed
# In .[..]profile -> .profile (path additions, ssh-agent, etc.)
# ================================================================
[[ $- == *i* ]] || [ -n "$PS1" ] || return

# ================================================================
# Run Generic Interactive Shell Configuration.
# ================================================================
source ~/.shrc

# ================================================================
# Run Starship Prompt Configuration.
# ================================================================
eval "$(starship init zsh)"

# ================================================================
# Source Zsh Plugins Near Top of .zshrc.
# zsh-syntax-highlighting.zsh must be sourced at the end of the .zshrc file.
# ================================================================
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-z/zsh-z.plugin.zsh
# source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# ================================================================
# Change Syntax Highlighting Colors.
# ================================================================
# Source: https://github.com/zsh-users/zsh-syntax-highlighting/tree/master/highlighters/main

# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'

# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

# To disable highlighting of globbing expressions
ZSH_HIGHLIGHT_STYLES[globbing]='none'

# Command color (git etc.)
ZSH_HIGHLIGHT_STYLES[command]='fg=yellow'

# Quoted argument color
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# ================================================================
# Enable vi Mode and Activate Vim Plugin for oh-my-zsh.
# ================================================================
bindkey -v
plugins=(... vi-mode)
zle-line-init() { zle -K vicmd; }
zle -N zle-line-init
