#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin main

function doIt() {
  echo 'About to rsync files...'
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    -avh --no-perms . ~

  # Set zsh as default shell.
  if [ -z "$(which zsh)" ]; then
    echo 'Installing zsh...'
    brew update
    brew install zsh
  fi
  if ! grep -iFq "/bin/zsh" "/etc/shells"; then
    echo 'Adding zsh to /etc/shells...'
    which zsh | sudo tee -a /etc/shells
  fi
  echo 'Setting zsh as default shell...'
  chsh -s "$(which zsh)"

  # Run install script(s).
  echo 'Sourcing install.sh...'
  source install.sh

  # .[.]profile runs .profile, but not .[.]sh_rc,
  # since this will not be an interactive shell.
  # .profile adds the environment variables and
  # other login-time settings (e.g. ssh-agent) to the shell.
  # Do not run zsh scripts from here, as the Zsh commands are
  # not reccognized by bash.
  source ~/.bash_profile

  # .[.]shrc runs when a non-login interactive shell is opened,
  # and runs .shrc, which contains prompt settings, aliases, etc.
  source ~/.bashrc

  # Customizations.
  # Should be synced above.
  # mv -f ./.config/eza/theme.yml ~/.config/eza/theme.yml
}

# Ensure sudo.
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
