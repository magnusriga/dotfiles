#!/usr/bin/env bash

echo "Running setup_cargo_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Install packages (requires rust toolchain).
cargo install jless
cargo install ripgrep
cargo install ast-grep --locked
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
