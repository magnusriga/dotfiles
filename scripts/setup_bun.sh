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
    @playwright/test@latest \
    @mixedbread/mgrep \
    lighthouse
}

echo "Installing global packages with bun."
install_global_packages

echo "Trusting all global bun dependencies with scripts."
bun pm -g trust --all

# Gemini CLI requires npm (not compatible with bun)
echo "Installing Gemini CLI with npm."
npm install -g @google/gemini-cli

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

# Install mgrep plugins for AI coding assistants.
mgrep install-claude-code  # Claude Code
mgrep install-opencode     # OpenCode
mgrep install-codex        # Codex

# Install Playwright browsers - handle dependencies differently per distro
if [ -f /etc/arch-release ]; then
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
