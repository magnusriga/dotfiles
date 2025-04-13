#!/usr/bin/env bash

echo "Running setup_pip_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# pipx installs packages into `$HOME/.local/bin`, so add it to PATH.
pipx ensurepath

# Install packages.
pipx install vectorcode
