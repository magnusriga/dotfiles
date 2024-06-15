# ================================================================
# Notes
# ================================================================
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
# Add the Global pnpm Store (CAS) to Path.
# ================================================================
export PNPM_HOME="$HOME/.local/share/pnpm"
if [ -d "$HOME/.local/share/pnpm" ]; then
  PATH="$HOME/.local/share/pnpm:$PATH"
fi

# ================================================================
# Set Default Shell to Zsh
# ================================================================
SHELL=$(which zsh)

# ================================================================
# Add Bun to Path
# ================================================================
export BUN_INSTALL="$HOME/.bun"
if [ -d "$BUN_INSTALL" ]; then
  PATH="$BUN_INSTALL/bin:$PATH"
fi

# ================================================================
# Add Homebrew to Path
# ================================================================
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

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
