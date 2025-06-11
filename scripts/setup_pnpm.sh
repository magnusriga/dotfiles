#!/usr/bin/env bash

echo "Running setup_pnpm.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Add pnpm to PATH.
export PNPM_HOME="/home/nfu/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

pnpm --allow-build=spawn-sync \
  --allow-build=tree-sitter \
  --allow-build=@mistweaverco/tree-sitter-graphql \
  --allow-build=@mistweaverco/tree-sitter-kulala \
  --allow-build=contentful-cli \
  --allow-build=puppeteer \
  --allow-build=vue-demi \
  --allow-build=@anthropic-ai/claude-code \
  --allow-build=yarn \
  add -g \
  contentful-cli \
  neonctl \
  @mistweaverco/kulala-ls \
  node-gyp node-gyp-build \
  neovim \
  yarn \
  mcp-hub@latest \
  @mermaid-js/mermaid-cli \
  @anthropic-ai/claude-code

# pnpm --allow-build=tree-node-cli add -g tree-node-cli
# pnpm --allow-build=contentful-cli add -g contentful-cli
# pnpm --allow-build=neonctl add -g neonctl
# pnpm --allow-build=@mistweaverco/kulala-ls add -g @mistweaverco/kulala-ls
