#!/usr/bin/env bash

echo "Running setup_packages_cargo.sh as $(whoami), with HOME $HOME and USER $USER."

# - Arch: All tools below are installed with `pacman` or AUR
#   (`setup_packages.sh` / `setup_packages_aur.sh`), only the rust toolchain itself comes from `rustup`.
# - Ubuntu: Install with `cargo` (requires rust toolchain).
if [ "$DISTRO" != "arch" ]; then
  cargo install ast-grep --locked
  cargo install eza
  cargo install --locked tree-sitter-cli
  cargo install ripdrag
  cargo install resvg
  cargo install vtracer
  cargo install jless

  # Build viu from source.
  if ! command -v viu &>/dev/null; then
    VIU_BUILD_DIR="${BUILD_HOME:-$HOME/build}/repositories/viu"
    rm -rf "$VIU_BUILD_DIR"
    git clone https://github.com/atanunq/viu.git "$VIU_BUILD_DIR"
    cd "$VIU_BUILD_DIR" || exit
    cargo install --path .
    cd - || exit
  fi
fi
