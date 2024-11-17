#!/usr/bin/env bash

# Install Yazi plugins.
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

# Setup cron jobs.
(crontab -l ; echo "@daily $(which trash-empty) 30") | crontab -

# Create symlinks to programs, overwriting default programs.
ln -s $(which fdfind) ~/.local/bin/fd
ln -s $(which ast-grep) ~/.local/bin/sg
