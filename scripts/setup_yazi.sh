#!/usr/bin/env bash

echo "Running setup_yazi.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install Yazi plugins from source.
rm -rf $(find ~/.config/yazi/plugins -maxdepth 1 -type d | grep -v -e 'arrow.yazi' -e 'folder-rules.yazi' -e 'system-clipboard.yazi' -e 'plugins$' -)
rm "${YAZI_HOME:-$HOME/.config/yazi}/package.toml"
git clone https://github.com/sharklasers996/eza-preview.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/eza-preview.yazi"
git clone https://github.com/boydaihungst/restore.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/restore.yazi"
git clone https://github.com/BennyOe/onedark.yazi.git "${YAZI_HOME:-$HOME/.config/yazi}/flavors/onedark.yazi"

# Install Yazi plugins via cli.
ya pack -a yazi-rs/plugins:full-border
ya pack -a yazi-rs/plugins:max-preview
ya pack -a dedukun/relative-motions
ya pack -a Reledia/glow
ya pack -a yazi-rs/plugins:jump-to-char
ya pack -a dedukun/bookmarks
ya pack -a yazi-rs/plugins:chmod
ya pack -a Lil-Dank/lazygit
ya pack -a yazi-rs/plugins:smart-filter
ya pack -a yazi-rs/plugins:git
ya pack -a Rolv-Apneseth/starship
ya pack -a yazi-rs/plugins:diff
