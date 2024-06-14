# ================================================================
# Notes
# ================================================================
# Five profile scripts gets executed (in the below order) when an zsh shell is launched and closed.
# Place code in .zshenv or .zshrc.
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
#   - Thus, do not run .[..]profile every time an (interactive) shell opens.
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
#   - Therefore, run the rc file belonging to the profile file, from the profile file, if the shell (which is a login shell) is interactive.
#   - This ensures that setup code for interactive shells run both for the first shell, aka. the login shell (if interactive), and for subserquent (non-login) shells.
#   - .[..]profile > .profile && .[..]profile > .[..]rc > .shrc
# * Result:
#   - code in .profile runs when the first shell is openend, so environment variables and ssh-agents, etc. are available to all shells from the start.
#   - code in .shrc also runs whenever an interactive shell is opened whether it is the first shell, aka. the login shell, or not.
#   - code in the specifc .[..]profile and .[..]rc also runs.
#
# ================================================================

# ================================================================
# Source the environment variables and other login-time settings (e.g. ssh-agent) from .profile.
# Only runs when a login shell is opened (i.e. the first zsh terminal opened after starting vscdoe).
# ================================================================
source ~/.profile

# ================================================================
# Source the .[..]rc File If the Current Shell, i.e. the Login
# Shell, is Interactive, Which Ensures Interactive Login Shells Get All the Setup They Need.
# ================================================================
[[ $- == *i* ]] && [ -n "$PS1" ] && source ~/.zshrc
