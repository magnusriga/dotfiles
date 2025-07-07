#!/usr/bin/env bash

echo "Running bootstrap.sh as $(whoami), with HOME $HOME and USER $USER."

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
# Exit if not run from Bash, since script relies on
# environment variable `BASH_SOURCE`.
# ==========================================================
[[ -z ${BASH_SOURCE[0]} ]] && echo "Please re-run from bash, exiting..." && return

# ==========================================================
# Get Script Path.
# ==========================================================
# $0 only works when script is run with shell, e.g. bash foo.sh,
# not when script is sourced, e.g. source foo.sh.
# SCRIPT=$(realpath "$BASH_SOURCE || $0")
# SCRIPT_PATH=$(dirname "$SCRIPT")
# echo "SCRIPT_PATH is $SCRIPT_PATH."
SCRIPTPATH="$(
  cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || return
  pwd -P
)/"

# ==========================================================
# Change directory to path of current script,
# to execute other scripts with relative path.
# ==========================================================
echo "cd to SCRIPTPATH: $SCRIPTPATH"
cd "$SCRIPTPATH" || return

# ==========================================================
# Ensure `dotfiles` repo is up-to-date.
# ==========================================================
git pull origin main

function doIt() {
  # ==========================================================
  # Check if Scripts is Sourced or Executed.
  # ==========================================================
  # If $BASH_SOURCE is equal to $0,
  # script is executed directly from shell, i.e. executed in bash sub-process,
  # otherwise, if $0 is e.g. -bash, script is being sourced,
  # i.e. run in current shell's process.
  # [[ $BASH_SOURCE = $0 ]] && exit 1 || return

  # ==========================================================
  # Save top-level `dotfiles` path.
  # ==========================================================
  ROOTPATH="$(cd -- "$SCRIPTPATH/.." >/dev/null 2>&1 && pwd -P)"
  echo "ROOTPATH is $ROOTPATH."

  # ==========================================================
  # Setup manual symlinks needed during installation,
  # as `stow` is not yet installed.
  # ==========================================================
  # Link `pacman.conf`, used by `pacman`.
  sudo rm -f /etc/pacman.conf
  sudo ln -s "${ROOTPATH}/etc/pacman.conf" /etc

  # Link `.stow-global-ignore`, used by `stow`.
  rm -f "$HOME/.stow-global-ignore"
  ln -s "${ROOTPATH}/stow/.stow-global-ignore" "$HOME"

  # ==========================================================
  # Set locale.
  # ==========================================================
  # Skip locale setup in Docker build, as it is already configured.
  if [ ! -f /.dockerenv ]; then
    sudo localectl set-locale LANG=en_US.UTF-8
    unset LANG
    source /etc/profile.d/locale.sh
  fi

  # ==========================================================
  # Setup user if it doesn't exist.
  # ==========================================================
  if ! id "nfu" &>/dev/null && [ -f "./setup_user.sh" ]; then
    echo "Running: . ./setup_user.sh."
    . ./setup_user.sh
    echo "New user created, restart shell as new user and re-run script."
    return
  fi

  # ==========================================================
  # Run remaining setup scripts as new user.
  # Switch manually to new user, before running this file again.
  # ==========================================================
  if [ "$(whoami)" = "nfu" ] && [ -f "./setup_main.sh" ]; then
    # Remove `/usr/local/share/man`, which symlinks to empty `/usr/local/man` on Arch Linux,
    # as it blocks `setup_packages_manual.sh` > `stow nvim`.
    sudo rm -f /usr/local/share/man

    echo "Running: . ./setup_main.sh."
    . ./setup_main.sh

    # ==========================================================
    # `stow` system-level files.
    # ==========================================================
    # `sshd_config`, used when ssh'ing into this machine.
    sudo rm -f /etc/ssh/sshd_config
    sudo stow --no-folding -vv -d "$SCRIPTPATH"/../etc -t /etc/ssh ssh

    # ==========================================================
    # `stow` user-level files.
    # - Run `stow -d "$HOME/dotfiles" -t "$HOME"` after installing packages,
    #   to avoid symlinked `.config` folders, e.g. $HOME/.config/eza,
    #   being overwritten by install scripts that create e.g. $HOME/.config/eza.
    # - Uses configuration `dotfiles/.stowrc`, which excludes certain directories.
    # - Stow is not ignoring top-level dotfiles, like `.git` because of this file,
    #   instead `stow *` expands to all files and directories in folder except hidden ones,
    #   i.e. those starting at `.`.
    # ==========================================================
    # Remove existing dotfiles, not created by `stow`.
    rm -rf ~/{.gitconfig,.bash*,.profile,.zshrc}

    echo "Running: stow -vv -d $SCRIPTPATH/../stow -t $HOME *"
    cd "$SCRIPTPATH/../stow" || return
    # shellcheck disable=SC2035
    stow -vv -d "$SCRIPTPATH"/../stow -t "$HOME" *

    # ==========================================================
    # Set ZSH as default shell.
    # ==========================================================
    # Force ZSH verison from pacman.
    local which_zsh="/usr/bin/zsh"
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$current_shell" != "$which_zsh" ]; then
      echo 'Setting ZSH as default shell for current user...'
      if ! sudo cat /etc/shells | grep -q "${which_zsh}"; then
        echo "Adding ${which_zsh} to /etc/shells."
        echo "${which_zsh}" | sudo tee -a /etc/shells 1>/dev/null
      fi
      sudo chsh -s "${which_zsh}" "$USER"
    else
      echo "ZSH is already the default shell for current user."
    fi
    unset which_zsh current_shell

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

    # ==========================================================
    # Success messages and changing directory to $HOME.
    # ==========================================================
    echo "Installations and setup now done, restart shell to start using ZSH."
    echo "Manually delete existing user and its home folder, if desired."
    cd "$HOME" || return
  fi
}

if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
  doIt
else
  read -r -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi

unset doIt
