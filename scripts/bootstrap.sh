#!/usr/bin/env bash

echo "Running bootstrap.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ==========================================================
# Setup Script Overview.
# ==========================================================
# ----------------------------------------------------------
# Files not needing any user.
# ----------------------------------------------------------
# print_versions
# setup_brew
# 
# ----------------------------------------------------------
# Files needing sudo.
# ----------------------------------------------------------
# bootstrap
# setup_apt-get_packages
# setup_docker
# setup_entry
# 
# ----------------------------------------------------------
# Files needing to be run by new user,
# because it uses $HOME, $USERNAME,
# or otherwise populates new user's home directory.
# ----------------------------------------------------------
# - bootstrap (also nees sudo)
# - setup_main
# - setup_eza (also needs sudo, add new user to sudoers.d/[username])
# - setup_directories
# - setup_git_credentials
# - setup_fonts
# - setup_nvm
# - setup_pnpm
# - setup_symlinks
# - setup_tmux
# - setup_yazi
# - setup_zsh
#
# ==========================================================

# ==========================================================
# Get Script Path.
# ==========================================================
# $0 only works when script is run with shell, e.g. bash foo.sh,
# not when script is sourced, e.g. source foo.sh.
# SCRIPT=$(realpath "$BASH_SOURCE || $0")
# SCRIPT_PATH=$(dirname "$SCRIPT")
# echo "SCRIPT_PATH is $SCRIPT_PATH."
SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE")" >/dev/null 2>&1 ; pwd -P )/"

# ==========================================================
# Change directory to path of current script,
# to execute other scripts with relative path.
# ==========================================================
echo "cd to SCRIPTPATH: $SCRIPTPATH"
# cd "$(dirname "${BASH_SOURCE}")"
cd $SCRIPTPATH

# ==========================================================
# Ensure `dotfiles` repo is up-to-date.
# ==========================================================
git pull origin main

function doIt() {
#  echo 'About to rsync files...'
#  rsync --exclude ".git/" \
#    --exclude ".DS_Store" \
#    --exclude ".osx" \
#    --exclude "bootstrap.sh" \
#    --exclude "README.md" \
#    --exclude "LICENSE-MIT.txt" \
#    -avh --no-perms . ~

  # ==========================================================
  # Check if Scripts is Sourced or Executed.
  # ==========================================================
  # If $BASH_SOURCE is equal to $0,
  # script is executed directly from shell, i.e. executed in bash sub-process,
  # otherwise, if $0 is e.g. -bash, script is being sourced,
  # i.e. run in current shell's process.
  # [[ $BASH_SOURCE = $0 ]] && exit 1 || return
  
  # ==========================================================
  # Create new user, if it does not already exist.
  # ==========================================================
  if [ -f "./setup_user.sh" ]; then
    . ./setup_user.sh
  fi
  
  # ==========================================================
  # Run remaining setup scripts as new user.
  # Switch manually to new user, before running this file again.
  # ==========================================================
  if [ $(whoami) == "nfu" ] && [ -f "./setup_main.sh" ]; then
    echo "Running: . ./setup_main.sh."
    . ./setup_main.sh
  fi

  # ==========================================================
  # `stow`: Place selected dotfiles into $HOME.
  # - Run `stow -d "$HOME/dotfiles" -t "$HOME"` after installing packages,
  #   to avoid symlinked `.config` folders, e.g. $HOME/.config/eza,
  #   being overwritten by install scripts that create e.g. $HOME/.config/eza.
  # - Uses configuration `dotfiles/.stowrc`, which excludes certain directories.
  # ==========================================================
  echo "Running: stow -vv -d $HOME/dotfiles -t $HOME *"
  stow -vv -d "$HOME/dotfiles" -t "$HOME" *

  # ==========================================================
  # Set ZSH as default shell.
  # ==========================================================
  echo 'Setting ZSH as default shell for current user...'
  sudo chsh -s "$(which zsh)" "$USER"
  
  # ==========================================================
  # Delete old user.
  # ==========================================================
  # if [[ -n "$(id -un $CURRENT_USER)" && "$(id -un $CURRENT_USER)" != $USERNAME && "$(id -un $CURRENT_USER)" != 'root' ]]; then
    # sudo userdel $CURRENT_USER
    # rm -rf /home/$CURRENT_USER 
  # fi

  # ==========================================================
  # Do not run zsh scripts from here, as the Zsh commands are
  # not reccognized by bash.
  # ==========================================================
  echo "Installations and setup now done, restart shell to start using ZSH."
  echo "Manually delete existing user and its home folder, if desired."
}

# ==========================================================
# Ensure sudo.
# Not needed, as new, i.e. current, user is added to `/etc/sudoers.d/<username>`,
# which ensures user can run `sudo` command,
# and user does not need to type password for any command.
# ==========================================================
# if [ "$EUID" -ne 0 ]; then
#   echo "Please run as root"
#   exit
# fi

if [ "$1" = "--force" -o "$1" = "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi
unset doIt
