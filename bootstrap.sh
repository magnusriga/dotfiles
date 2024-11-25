#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin main

function doIt() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "bootstrap.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    -avh --no-perms . ~
  # .bash_profile runs .profile, but not .bash_rc,
  # since this will not be an interactive shell.
  # .profile adds the environment variables and
  # other login-time settings (e.g. ssh-agent) to the shell.
  # Do not run zsh scripts from here, as the Zsh commands are
  # not reccognized by bash.
  source ~/.bash_profile
  # .bashrc runs when a non-login interactive shell is opened,
  # and runs .shrc, which contains prompt settings, aliases, etc.
  source ~/.bashrc

  # Set zsh as default shell.
  if [ -z "$(which zsh)" ]; then
    brew update
    brew install zsh
    sh -c "echo $(which zsh) >> /etc/shells"
  fi
  chsh -s "$(which zsh)"

  # Run install script(s).
  source install.sh

  # Customizations.
  mv -f ./.config/eza/theme.yml ~/.config/eza/theme.yml
}

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
