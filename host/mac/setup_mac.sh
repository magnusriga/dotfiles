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
nvm install node

# Verify the Node.js version:
node -v
nvm current

# Verify npm version:
npm -v

# --------------------------------------
# Rust, e.g. cargo ++.
# --------------------------------------
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# --------------------------------------
# Symlink clipboard services
# --------------------------------------
mkdir -p ~/Library/LaunchAgents
mkdir -p /usr/local/bin

# Copy clipboard scripts to system location
cp ~/dotfiles/usr/local/bin/pbpaste-service /usr/local/bin/pbpaste-service
chmod +x /usr/local/bin/pbpaste-service

# Symlink LaunchAgent plists
ln -sf ~/dotfiles/host/mac/Library/LaunchAgents/pbcopy.plist ~/Library/LaunchAgents/pbcopy.plist
launchctl load ~/Library/LaunchAgents/pbcopy.plist

ln -sf ~/dotfiles/host/mac/Library/LaunchAgents/pbpaste.plist ~/Library/LaunchAgents/pbpaste.plist
launchctl load ~/Library/LaunchAgents/pbpaste.plist
