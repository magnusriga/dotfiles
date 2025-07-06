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
ya pkg -a yazi-rs/plugins:full-border
ya pkg -a yazi-rs/plugins:max-preview
ya pkg -a dedukun/relative-motions
ya pkg -a Reledia/glow
ya pkg -a yazi-rs/plugins:jump-to-char
ya pkg -a dedukun/bookmarks
ya pkg -a yazi-rs/plugins:chmod
ya pkg -a Lil-Dank/lazygit
ya pkg -a yazi-rs/plugins:smart-filter
ya pkg -a yazi-rs/plugins:git
ya pkg -a Rolv-Apneseth/starship
ya pkg -a yazi-rs/plugins:diff
