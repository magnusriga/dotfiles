#!/usr/bin/env bash

echo "Running setup_nvm.sh."

# Download and install nvm, node, npm.
# 1) Clone the nvm repository to ~/.nvm.
# 2) Run $NVM_DIR/nvm.sh, which copies a snippet that starts nmv insto the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).
# 3) Install node.
# All nvm commands must have .nvm.sh run in same RUN command,
# otherwise it won't find the binaries it needs.
# NVM install should have been done by NVM script from curl,
# but for some reason it does not, so we must do it manually.
# "node" is an alias for the latest version, however we must use an actual version number for the addition to PATH to work.
# NODE_VERSION="22.11.0"
NODE_VERSION="node"
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default
