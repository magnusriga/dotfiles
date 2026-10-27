#!/usr/bin/env bash

echo "Running setup_bun.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# `BUN_INSTALL` holds bun's global packages (`$BUN_INSTALL/install/global`)
# and their binaries (`$BUN_INSTALL/bin`), on every distro.
export BUN_INSTALL="$HOME/.bun"
mkdir -p "$BUN_INSTALL"

# Install bun.
# - Arch: `pacman` (`setup_packages.sh`).
# - Ubuntu: Official installer, places binary in `$BUN_INSTALL/bin`.
if [ "$DISTRO" != "arch" ]; then
  curl -fsSL https://bun.sh/install | bash
fi

# Add bun global binaries to PATH.
case ":$PATH:" in
*":$BUN_INSTALL/bin:"*) ;;
*) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# Install, or upgrade to latest, global packages.
# `@latest` makes re-runs re-resolve every package instead of keeping the installed version.
function install_global_packages() {
  bun add -g \
    contentful-cli@latest \
    neonctl@latest \
    @mistweaverco/kulala-ls@latest \
    node-gyp@latest node-gyp-build@latest \
    yarn@latest \
    mcp-hub@latest \
    @mermaid-js/mermaid-cli@latest \
    @openai/codex@latest \
    @playwright/test@latest \
    lighthouse@latest
}

echo "Installing global packages with bun."
install_global_packages

echo "Trusting all global bun dependencies with scripts."
bun pm -g trust --all

# Gemini CLI requires npm (not compatible with bun).
# - Arch: `pacman` (`setup_packages.sh`).
# - Ubuntu: `npm` from `nvm` (`setup_nvm.sh`).
if [ "$DISTRO" != "arch" ]; then
  echo "Installing Gemini CLI with npm."
  npm install -g @google/gemini-cli@latest
fi

echo "Installing Gemini CLI extensions..."
gemini extensions install https://github.com/ChromeDevTools/chrome-devtools-mcp --consent
# gemini extensions install https://github.com/github/github-mcp-server --consent
gemini extensions install https://github.com/upstash/context7 --consent
# gemini extensions install https://github.com/stripe/ai --consent
gemini extensions install https://github.com/hashicorp/terraform-mcp-server --consent
# gemini extensions install https://github.com/elevenlabs/elevenlabs-mcp --consent
gemini extensions install https://github.com/gemini-cli-extensions/nanobanana --consent
gemini extensions install https://github.com/redis/mcp-redis --consent
gemini extensions install https://github.com/gemini-cli-extensions/security --consent
gemini extensions install https://github.com/gemini-cli-extensions/code-review --consent
gemini extensions install https://github.com/gemini-cli-extensions/jules --consent
gemini extensions install https://github.com/gemini-cli-extensions/workspace --consent
gemini extensions install https://github.com/googleapis/genai-toolbox --consent

# Clean up function
unset install_global_packages

# Install Playwright browsers - handle dependencies differently per distro
if [ "$DISTRO" = "arch" ]; then
  echo "Installing Playwright browsers on Arch (Chromium + Firefox only, WebKit not supported)..."
  # Arch is not officially supported by Playwright. Chromium and Firefox work fine,
  # but WebKit fails due to missing Ubuntu-specific library versions (libflite1, libvpx9, libicu74).
  # See: https://github.com/microsoft/playwright/issues/8100
  bunx playwright install chromium firefox
else
  echo "Installing Playwright system dependencies on Ubuntu/Debian..."
  bunx playwright install-deps
  echo "Installing Playwright browsers..."
  bunx playwright install
fi

# Migrate to local `claude` installation.
# Note: Run 'claude migrate-installer' manually if needed
