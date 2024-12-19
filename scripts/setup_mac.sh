#!/usr/bin/env bash

echo "Running setup_mac.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."
echo "This must run on mac, not inside Linux VM or docker container."

# Fixes for aerospace.
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
