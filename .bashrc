# ================================================================
# Notes
# ================================================================
# Five scripts gets executed (in the below order) when a bash shell is launched and closed.
# Place code in .bash_profile and .bashrc.
#
# (1) .bash_profile
# Runs when a login shell is launched, regardless if the shell is interactive or not.
# Threfore, .bash_profile, like other .[..]profile files, only runs once.
#
# (2) .bashrc
# Runs when a non-login interactive shell is opened.
# Runs when a remote non-login shell that is NOT interactive, launches after issuing a command to the remote shell with ssh.
# A remote shell is one that runs on a server with e.g. sshd.
# Example command to remote non-login non-interactive shell that will run .[..]rc files: ssh host echo 'foo'
# Used to:
# * Set options for interactive shells, with the setopt and unsetopt commands.
# * Load shell modules, set history options, change the prompt, set up zle and completion, et cetera.
# * Set variables that are only used in the interactive shell (e.g. $LS_COLORS).
#
# (3) There are two other scripts that run as well (login/logut), but those are not used here.
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
# Only Proceed if the Shell is an Interactive Shell.
# The Setup Code Below Should Only Apply to Interactive Shells.
# Other Setup Code, Meant to Apply to All Shells, Should Be Placed
# In .[..]profile -> .profile (path additions, ssh-agent, etc.)
# ================================================================
[[ $- == *i* ]] || [ -n "$PS1" ] || return

# ================================================================
# Run Generic Interactive Shell Configuration.
# ================================================================
source ~/.shrc

# ================================================================
# Load Bash-Specific Dotfiles.
# ================================================================
[ -r "~/.bash_prompt" ] && [ -f "~/.bash_prompt" ] && source ~/.bash_prompt

# ================================================================
# Bash-Specific Settings.
# ================================================================
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2>/dev/null
done

# ================================================================
# Bash-Specific Tab-Completion.
# ================================================================

# Add tab completion for many Bash commands
if which brew &>/dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &>/dev/null; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
