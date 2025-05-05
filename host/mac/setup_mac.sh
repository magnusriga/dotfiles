#!/usr/bin/env bash

echo "Running setup_mac.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."
echo "This must run on mac, not inside Linux VM or docker container."

# Fixes for aerospace.
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

# Install Homebrew packages.
brew update
brew upgrade
brew install git fd ripgrep zoxide lazygit bat fzf infisical

# --------------------------------------
# Download and install nvm and npm.
# --------------------------------------
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v     # Should print "v22.15.0".
nvm current # Should print "v22.15.0".

# Verify npm version:
npm -v # Should print "10.9.2".
# --------------------------------------

# --------------------------------------
# Rust, e.g. cargo ++.
# --------------------------------------
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
