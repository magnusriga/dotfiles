#!/usr/bin/env bash

echo "Running setup_nvm.sh."

# Only used on Ubuntu, Arch installs `nodejs`, `npm` and `pnpm` with `pacman` (`setup_packages.sh`).
NVM_DIR=${NVM_DIR:-$HOME/.nvm}

# Shared helpers (`github_latest_tag`).
. "$(dirname "${BASH_SOURCE[0]}")/setup_helpers.sh"

# Download and install nvm, node, npm.
# 1) Clone the nvm repository to ~/.nvm.
# 2) Run $NVM_DIR/nvm.sh, which copies a snippet that starts nmv insto the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).
# 3) Install node.
# All nvm commands must have .nvm.sh run in same RUN command,
# otherwise it won't find the binaries it needs.
# NVM install should have been done by NVM script from curl,
# but for some reason it does not, so we must do it manually.
# "node" is an alias for the latest version, however we must use an actual version number for the addition to PATH to work.
# NODE_VERSION="22.14.0"
NODE_VERSION="node"
# Latest nvm release tag, resolved at run time.
NVM_VERSION=$(github_latest_tag nvm-sh/nvm)
if [ -z "$NVM_VERSION" ]; then
  echo "ERROR: Could not resolve latest nvm release tag, skipping nvm, node, npm and pnpm install." >&2
  return 1
fi
# `PROFILE=/dev/null`: skip profile edits, `.shrc` already loads nvm.
# Re-running the installer also updates an existing nvm to this version.
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE=/dev/null bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default
# Node bundles an older npm, upgrade to latest npm supported by this Node.
nvm install-latest-npm
# `pnpm`, installed as plain tool next to `node` (Arch: `pacman`).
npm install -g pnpm@latest
