#!/usr/bin/env bash

echo "Running setup_eza.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install eza.
# Use `pacman` instead.
# mkdir -p /etc/apt/keyrings
# wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
# echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
# sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
# sudo apt-get update
# sudo apt-get install -y eza

# Install eza theme.
# eza uses the theme.yml file stored in $EZA_CONFIG_DIR, or if that is not defined then in $XDG_CONFIG_HOME/eza.
# Download theme repo as reference, but do not symlink $EZA_CONFIG_DIR/theme to it,
# instead just keep own theme from dotfiles sync.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"
git clone https://github.com/eza-community/eza-themes.git "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"

# Setup eza completions.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza"
git clone https://github.com/eza-community/eza.git "${EZA_HOME:-$HOME/.local/share/eza}/eza"
