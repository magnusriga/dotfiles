#!/usr/bin/env bash

echo "Running setup_pnpm.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Add pnpm to PATH.
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

function install_global_packages() {
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
}

# Necessary?
# source "$HOME"/.bashrc

# Install packages before fixing tree-sitter.
echo "Installing global packages with pnpm, error expected from @mistweaverco/tree-sitter, might take time."
install_global_packages

# Fix tree-sitter binding.gyp to use C++20 instead of C++17
# NOTE: Necessary, until https://github.com/tree-sitter/node-tree-sitter/issues/238 is fixed.
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "On MacOS, replacing c++17 with c++20 in tree-sitter's binding.gyp, to be able to install it with Node 20+."
  sed -i '' 's/c++17/c++20/g' "$PNPM_HOME"/global/5/.pnpm/tree-sitter@*/node_modules/tree-sitter/binding.gyp
else
  echo "Not on MacOS, replacing c++17 with c++20 in tree-sitter's binding.gyp, to be able to install it with Node 20+."
  sed -i 's/c++17/c++20/g' "$PNPM_HOME"/global/5/.pnpm/tree-sitter@*/node_modules/tree-sitter/binding.gyp
fi

# Install packages again after fixing tree-sitter.
echo "Re-installing global packages with pnpm, after fixing tree-sitter."
install_global_packages

# Clean up function
unset install_global_packages

# Migrate to local `claude` installation.
# Note: Run 'claude migrate-installer' manually if needed

# pnpm --allow-build=tree-node-cli add -g tree-node-cli
# pnpm --allow-build=contentful-cli add -g contentful-cli
# pnpm --allow-build=neonctl add -g neonctl
# pnpm --allow-build=@mistweaverco/kulala-ls add -g @mistweaverco/kulala-ls
