# Runs when shell is opened for the FIRST time.
# Also called by bashrc (if using magnus' dotfiles),
# which means it runs EVERY TIME ANY BASH SHELL IS OPENED.
# It does not run when other, non-bash shells, open.

# CONCLUSION: Only use this file, as it runs EVERY TIME a shell opens (.bashrc runs when second shell or later opens).
# CONCLUSION: We do not have a file that ONLY runs when first shell opens.

# Do not not run this file when non-interactive shells open (only for interactive shells).
case $- in
    *i*) ;;
      *) return;;
esac

# Add `~/bin` to the `$PATH`
# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

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
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# ================================================================

# ----------------------------------------------------------------
# Needed for NVM, node, npm to work in docker.
# Make sure it maches path set for .nvm in Dockerfile.
# ----------------------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# ================================================================

# ----------------------------------------------------------------
# Needed to ensure pnpm binary is added to PATH.
# ----------------------------------------------------------------
SHELL='/bin/bash'

# PNPM NOTES:
# PNPM_HOME is path to pnpm executable file (i.e. bin file).
# Below we add binary location (as set by pnpm curl install script) to path.
# We could install pnpm with corepack, in which case it is installed in nvm folder which is already in PATH.
# Thus, using corepack, adding PNPM_HOME to path is not needed.
# It is anyways needed to set PNPM_HOME env, because we use it to set virtual store path.
# If we set it below, and use corepack to install pnpm binary, binary location and PNPM_HOME would not match.
# Thus, install pnpm with curl, but remember to delete entry it makes to .bashrc,
# since that automatic entry sets PNPM_HOME with hardcoded username then adds that to path: PNPM_HOME="/home/<username>/.local/share/pnpm".
# Instead, we make set PNPM_HOME below, using USER env.
# PS: No crisis if we forget to delet bashrc entry made by pnpm install script, as it should use the correct username.
# Below only adds PNPM_HOME to path is it does not already exist in PATH.
export PNPM_HOME="/home/${USER}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ================================================================

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# ================================================================

# ----------------------------------------------------------------
# Start ssh agent to avoid typing GitHub password.
# ----------------------------------------------------------------

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
