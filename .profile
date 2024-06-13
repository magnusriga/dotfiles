# ================================================================
# Notes
# ================================================================
# * Information:
#   - https://unix.stackexchange.com/questions/462663/purpose-of-n-ps1-in-bashrc
#   - https://unix.stackexchange.com/questions/3052/is-there-a-bashrc-equivalent-file-read-by-all-shells
# * Do NOT run .[..]profile from .[..]rc files.
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
# * Result:
#   - Code in .profile runs when the first shell is openend, so environment variables and ssh-agents, etc. are available to all shells from the start.
#   - Code in .shrc runs whenever an interactive shell is opened.
#
# ================================================================

# ================================================================
# Add User's Private Bin (`~/bin`) to `$PATH`
# ================================================================
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# ================================================================
# Add User's Private .local Bin to Path
# ================================================================
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# ================================================================
# Add Node Version Manager (NVM) to Path.
# Needed for NVM, node, npm to Work in Docker.
# Make Sure It Maches Path Set for .nvm in Dockerfile.
# ================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# ================================================================
# Set Default Shell to Zsh
# ================================================================
SHELL=$(which zsh)

# ================================================================
# Add Bun to Path
# ================================================================
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# ================================================================
# Make Google Chrome Default Browser
# ================================================================
export BROWSER=google-chrome

# ================================================================
# Start SSH agent to Avoid Typing Github Password
# ================================================================
env=~/.ssh/agent.env

agent_load_env() { test -f "$env" && . "$env" >|/dev/null; }

agent_start() {
  (
    umask 077
    ssh-agent >|"$env"
  )
  . "$env" >|/dev/null
}

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(
  ssh-add -l >|/dev/null 2>&1
  echo $?
)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
  agent_start
  ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
  ssh-add
fi

unset env
