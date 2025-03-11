#!/usr/bin/env bash

echo "Running setup_packages_cargo.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install packages (requires rust toolchain).
cargo install ast-grep --locked
cargo install eza
cargo install --locked tree-sitter-cli

# Installed with pacman instead.
# cargo install jless
# cargo install ripgrep
# cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
