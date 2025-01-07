#!/usr/bin/env bash

echo "Running setup_pnpm.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" sh -

# Add pnpm to PATH.
export PNPM_HOME="/home/nfu/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Install global pnpm packages.
pnpm install -g tree-node-cli
pnpm install -g contentful-cli
pnpm install -g neonctl
