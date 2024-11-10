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

# Setup cron jobs.
RUN (crontab -l ; echo "@daily $(which trash-empty) 30") | crontab -
