#!/usr/bin/env bash

echo "Running setup_git_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install fzf.
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
