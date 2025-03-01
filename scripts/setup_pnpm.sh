#!/usr/bin/env bash

echo "Running setup_pnpm.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | sh -
# wget -qO- https://get.pnpm.io/install.sh | sh -

# Add pnpm to PATH.
export PNPM_HOME="/home/nfu/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Install global pnpm packages.
pnpm add -g \
  tree-node-cli \
  contentful-cli \
  neonctl \
  @mistweaverco/kulala-ls

# pnpm --allow-build=tree-node-cli add -g tree-node-cli
# pnpm --allow-build=contentful-cli add -g contentful-cli
# pnpm --allow-build=neonctl add -g neonctl
# pnpm --allow-build=@mistweaverco/kulala-ls add -g @mistweaverco/kulala-ls
