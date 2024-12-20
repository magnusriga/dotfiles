#!/usr/bin/env bash

echo "Running setup_entry.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Files not needing any user
# print_versions
# setup_brew
# 
# Files needing sudo
# bootstrap
# setup_apt-get_packages
# setup_docker
# setup_entry
# 
# Files needing to be run by new user,
# because it uses $HOME, $USERNAME,
# or otherwise populates new user's home directory.
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

# $0 only works when script is run with shell, e.g. bash foo.sh,
# not when script is sourced, e.g. source foo.sh.
# SCRIPT=$(realpath "$BASH_SOURCE || $0")
# SCRIPT_PATH=$(dirname "$SCRIPT")
# echo "SCRIPT_PATH is $SCRIPT_PATH."
SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE")" >/dev/null 2>&1 ; pwd -P )/"

echo "SCRIPTPATH is $SCRIPTPATH."

# Note:
# If $BASH_SOURCE is equal to $0,
# script is executed directly from shell, i.e. executed in bash sub-process,
# otherwise, if $0 is e.g. -bash, script is being sourced,
# i.e. run in current shell's process.
# [[ $BASH_SOURCE = $0 ]] && exit 1 || return

# Create new user if it does not already exist.
if [ -f "$SCRIPTPATH/setup_user.sh" ]; then
  sudo -E -u $USERNAME ${SCRIPTPATH:-./}setup_user.sh
fi

# Run remaining setup scripts as new user.
if [ -f "$SCRIPTPATH/setup_main.sh" ]; then
  echo "Running sudo -u $USERNAME ${SCRIPTPATH:-./}setup_main.sh."
  sudo -E -u $USERNAME ${SCRIPTPATH:-./}setup_main.sh
fi

# Add ZSH to `/etc/shells`.
# Note: Must be done after `setup_brew.sh`, which installs ZSH.
# if ! grep -iFq ".linuxbrew/bin/zsh" "/etc/shells"; then
#   echo 'Adding zsh to /etc/shells...'
#   which zsh | sudo tee -a /etc/shells 1> /dev/null
# fi

# Run stow after installing packages,
# to avoid symlinked .config folders, e.g. $HOME/.config/eza,
# being overwritten by install scripts that create e.g. $HOME/.config/eza.
# echo 'Running `stow .`.'
# sudo -u $USERNAME stow .

# Set ZSH as default shell.
# echo 'Setting ZSH as default shell...'
# sudo -u $USERNAME chsh -s "$(which zsh)"

# Delete old user.
# if [[ -n "$(id -un $CURRENT_USER)" && "$(id -un $CURRENT_USER)" != $USERNAME && "$(id -un $CURRENT_USER)" != 'root' ]]; then
  # sudo userdel $CURRENT_USER
  # rm -rf /home/$CURRENT_USER 
# fi
