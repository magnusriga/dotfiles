#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
  # .bash_profile runs .profile, but not .bash_rc,
  # since this will not be an interactive shell.
  # .profile adds the environment variables and
  # other login-time settings (e.g. ssh-agent) to the shell.
  # Do not run zsh scripts from here, as the Zsh commands are
  # not reccognized by bash.
	source ~/.bash_profile;
  # .bashrc runs when a non-login interactive shell is opened,
  # and runs .shrc, which contains prompt settings, aliases, etc.
	source ~/.bashrc;

  # Run install script(s).
  source install.sh;
}

if [ "$1" = "--force" -o "$1" = "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
