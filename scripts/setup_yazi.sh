#!/usr/bin/env bash

echo "Running setup_yazi.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Delete existing plugins and flavors before re-installing.
# - Not necessary to exclude the symlinked plugins `arrow.yazi`, etc.
# - Keep it as is in case changing from symlinks in future.
rm -rf $(find ~/.config/yazi/plugins -maxdepth 1 -type d | grep -v -e 'arrow.yazi' -e 'folder-rules.yazi' -e 'system-clipboard.yazi' -e 'plugins$' -)
rm -rf "${YAZI_HOME:-$HOME/.config/yazi}/flavors"
rm -f "${YAZI_HOME:-$HOME/.config/yazi}/package.toml"

# Install Yazi plugins from source.
git clone https://github.com/sharklasers996/eza-preview.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/eza-preview.yazi"
git clone https://github.com/boydaihungst/restore.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/restore.yazi"
git clone https://github.com/BennyOe/onedark.yazi.git "${YAZI_HOME:-$HOME/.config/yazi}/flavors/onedark.yazi"

# Install Yazi plugins via cli.
ya pkg add yazi-rs/plugins:full-border
ya pkg add dedukun/relative-motions
ya pkg add Reledia/glow
ya pkg add yazi-rs/plugins:jump-to-char
ya pkg add dedukun/bookmarks
ya pkg add yazi-rs/plugins:chmod
ya pkg add Lil-Dank/lazygit
ya pkg add yazi-rs/plugins:smart-filter
ya pkg add yazi-rs/plugins:smart-paste
ya pkg add yazi-rs/plugins:git
ya pkg add Rolv-Apneseth/starship
ya pkg add yazi-rs/plugins:diff
ya pkg add yazi-rs/plugins:toggle-pane
