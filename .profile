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
# Source API Keys.
# ================================================================
if [ -f "$HOME/.env" ]; then
  set -a
  source $HOME/.env
  set +a
fi

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
# Add snap binary directory to PATH.
# ================================================================
if [ -d "/snap/bin" ]; then
  PATH="/snap/bin:$PATH"
fi

# ================================================================
# Export WEZTERM_HOME shell variable.
# Subshells, e.g. non-login shells, inherit login shell's environment.
# ================================================================
export WEZTERM_HOME="$HOME/.local/share/wezterm"

# ================================================================
# Export variables for shell history persistence.
# ================================================================
export PROMPT_COMMAND=(history -a)
export HISTFILE="/commandhistory/.shell_history"

# ================================================================
# Export CARGO_HOME shell variable.
# Subshells, e.g. non-login shells, inherit login shell's environment.
# ================================================================
export CARGO_HOME="$HOME/.cargo"

# ================================================================
# Add symlink to fd, since another program has taken fd name.
# Add ~/.local/bin, where symlink is placed, to path so fd is found.
# ================================================================
if [ ! -d "$HOME/.local/bin" ]; then
  mkdir "$HOME/.local/bin" ]
fi
if [ ! -L "$HOME/.local/bin/fd" ]; then
  ln -fs $(which fdfind) ~/.local/bin/fd
fi
PATH="$HOME/.local/bin:$PATH"

# ================================================================
# Make Google Chrome Default Browser
# ================================================================
export BROWSER=google-chrome

# ================================================================
# Set Ripgrep Configuration File
# ================================================================
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

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
