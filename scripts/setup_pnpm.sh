#!/usr/bin/env bash

echo "Running setup_pnpm.sh."

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" sh -

# Install global pnpm packages.
pnpm install -g tree-node-cli
pnpm install -g contentful-cli
pnpm install -g neonctl
