#!/usr/bin/env bash

echo "Running setup_bun.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

export BUN_INSTALL="$HOME/.bun"
mkdir -p "$BUN_INSTALL"

# Install bun.
curl -fsSL https://bun.sh/install | bash

# Add bun to PATH.
case ":$PATH:" in
*":$BUN_INSTALL/bin:"*) ;;
*) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

function install_global_packages() {
  bun add -g \
    contentful-cli \
    neonctl \
    @mistweaverco/kulala-ls \
    node-gyp node-gyp-build \
    neovim \
    yarn \
    mcp-hub@latest \
    @mermaid-js/mermaid-cli \
    @anthropic-ai/claude-code \
    @openai/codex \
    @playwright/test@latest
}

echo "Installing global packages with bun."
install_global_packages

# Clean up function
unset install_global_packages

# Install Playwright browsers - handle dependencies differently per distro
if [ -f /etc/arch-release ]; then
  echo "Installing Playwright browsers on Arch (system deps should be installed via pacman)..."
  # On Arch, system deps like chromium libs should be installed via pacman
  # Just install the browser binaries without system deps
  bunx playwright install
else
  echo "Installing Playwright browsers with system dependencies on Ubuntu/Debian..."
  # On Ubuntu/Debian, let Playwright install system deps via apt
  bunx playwright install --with-deps
fi

# Migrate to local `claude` installation.
# Note: Run 'claude migrate-installer' manually if needed
