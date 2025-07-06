#!/usr/bin/env bash

echo "Running setup_packages_cargo.sh as $(whoami), with HOME $HOME and USER $USER."

# Install packages (requires rust toolchain).
cargo install ast-grep --locked
cargo install eza
cargo install --locked tree-sitter-cli

# - Only build `jless` from source on Debian-based systems.
# - Installed with `pacman` on Arch Linux.
[ -f /etc/debian_version ] && cargo install jless

# Build viu from source.
if ! command -v viu &>/dev/null; then
  VIU_BUILD_DIR="${BUILD_HOME:-$HOME/build}/repositories/viu"
  rm -rf "$VIU_BUILD_DIR"
  git clone https://github.com/atanunq/viu.git "$VIU_BUILD_DIR"
  cd "$VIU_BUILD_DIR" || exit
  cargo install --path .
  cd - || exit
fi

# Installed with pacman instead.
# cargo install ripgrep
# cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
