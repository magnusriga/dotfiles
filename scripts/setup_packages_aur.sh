#!/usr/bin/env bash

echo "Running setup_packages_aur.sh as $(whoami), with HOME $HOME and USER $USER."

# ==================================
# Detect Docker environment
# ==================================
IS_DOCKER=false
if [ -f /.dockerenv ] || [ -n "$DOCKER_BUILD" ]; then
  IS_DOCKER=true
  echo "Docker environment detected - using makepkg directly"
else
  echo "Host environment detected - using makechrootpkg"
fi

# ==================================
# Stow `makepkg` configuration into correct folder
# where `makepkg` will pick it up.
# ==================================
stow --no-folding -vv -d "$HOME/dotfiles/stow" -t "$HOME" pacman

# ==================================
# Setup chroot and arch-nspawn (only for non-Docker environments).
# ==================================
if [ "$IS_DOCKER" = false ]; then
  export CHROOT=$HOME/chroot

  function makeCleanChroot() {
    sudo rm -rf "$CHROOT"
    mkdir "$CHROOT"
    LC_ALL=C.UTF-8 mkarchroot "$CHROOT/root" base-devel
  }

  # ==================================
  # Create clean root once.
  # ==================================
  makeCleanChroot

  # ==================================
  # Adjust mirrorlist in `$CHROOT/root/etc/pacman.d/mirrorlist`,
  # to allow `makechrootpkg` to install from those repositories.
  # Only necessary on `aarch64`, i.e. ARM, because on `x86_64`
  # `arch-nspawn` handles it automatically.
  # ==================================
  # shellcheck disable=SC2016
  [[ $(uname -m) == "aarch64" ]] && echo 'Server = http://mirror.archlinuxarm.org/$arch/$repo/' | sudo tee "$CHROOT/root/etc/pacman.d/mirrorlist" 1>/dev/null

  # ==================================
  # For ARM architecture, `stow` updated `arch-nspawn` that does not overwrite
  # `$CHROOT/root/etc/pacman.d/mirrorlist`
  # ==================================
  sudo rm -f "/usr/local/bin/arch-nspawn"
  [[ $(uname -m) == "aarch64" ]] && sudo stow --no-folding -vv -d "$HOME/dotfiles" -t /usr/local pacman

  # ==================================
  # Ensure base chroot ($CHROOT/root) is up to date.
  # ==================================
  arch-nspawn "$CHROOT/root" pacman -Syy
fi

# ==================================
# Build and Install Package.
# ==================================
# Pre-requisites:
# - Manually download `PKGBUILD` file, and other files needed for build.
#    - Done with `git clone <repo>`, using `<repo>` found in e.g. AUR.
#    - Use target directory: `$HOME/build/repositories/<package>`.
#    - Command : `git clone <url> $HOME/build/repositories/$PACKAGE`.
#
# Steps:
# For Docker: Use `makepkg -si --noconfirm` (Docker provides isolation)
# For Host: Use `makechrootpkg -c -r $CHROOT -- -sc --noconfirm` (requires chroot)
#
# ==================================
# Build function that chooses appropriate method
# ==================================
function build_and_install_package() {
  local package_name="$1"

  if [ "$IS_DOCKER" = true ]; then
    echo "Building $package_name with makepkg (Docker environment)"
    makepkg -si --noconfirm
  else
    echo "Building $package_name with makechrootpkg (Host environment)"
    makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
    cd "$BUILD_HOME/packages" || exit
    sudo pacman -U --noconfirm "$package_name"-[0-9]*
    cd "$BUILD_REPOS/$package_name" || exit
  fi
}
#
# ==================================
# Update Package.
# ==================================
# 1) `git pull`.
# 2) Repeat above steps: Build, install, clean.
#
# ==================================
# `makepkg` flags.
# ==================================
# `-s/--syncdeps`: Automatically resolves and installs dependencies with pacman before building.
#                  If package depends on other AUR packages, you will need to manually install them first.
# `-i/--install` : Installs package if it is built successfully, making it unecessary to execute `makepkg -i | --install` or `pacman -U <pkgname-pkgver>.pkg.tar.zst`.
# `-r/--rmdeps`  : Removes build-time dependencies after build, as no longer needed. May need to be reinstalled next time package is updated.
# `-c/--clean`   : Cleans up temporary build files after build, as no longer needed. Usually only needed when debugging build process.
# `--packagelist`: Get list of package filenames that would be produced without building.
#
# ==================================
# Full `makepkg` command.
# ==================================
# - `makepkg -srci`.
# - Installs dependencies, cleans up unecessary build-and-dependency files after build,
#   and installs resulting package.
#
# ==================================
# Build commands (Docker vs Host).
# ==================================
# Docker: `makepkg -si --noconfirm`
# - `-s`: Install build dependencies automatically.
# - `-i`: Install package after building.
# - `--noconfirm`: Skip confirmations.
#
# Host: `makechrootpkg -c -r $CHROOT -- -sc --noconfirm`
# - `-c`: Clean working chroot before building.
# - `-r`: Chroot directory to use.
# - `--`: Arguments passed to makepkg.
# - `-sc`: Sync dependencies and clean up after build.
#
# ==================================
# Configuration Notes: `makepkg`.
# ==================================
# - PKGDEST — directory for storing resulting packages, i.e. `.pkg.tar.zst` created by `makepkg` from `PKGBUILD` files.
# - SRCDEST — directory for storing source data (symbolic links will be placed to src/ if it points elsewhere),
#   i.e. intermediate directory where `makepkg` downloads actual software source files into.
# - SRCPKGDEST — directory for storing resulting source packages (built with makepkg -S).
#
# ==================================
# Other notes.
# ==================================
# - `git clean -dfx`               : Remove all files not tracked by git, used to remove all build files after `makebuild`,
#                                    if git cloning `PKGBUILD` into same folder as `SRCDEST`.
# - `paccache -c ~/build/packages/`: Clean up `PKGDEST` directory.

# ==================================
# Environment Variables.
# ==================================
# Current working directory before running script.
CWD=$(pwd)

# Where final packages are placed by `makepkg` | `makechrootpkg`
# Docker: installed automatically with `makepkg -si`
# Host: built to `$BUILD_HOME/packages` and installed with `pacman -U`
export BUILD_HOME="${BUILD_HOME:-$HOME/build}"

# Where `PKGBUILD` files are manually placed with `git clone`.
export BUILD_REPOS="${BUILD_HOME:-$HOME/build}/repositories"

# Default: Put built package and cached source in build directory.
# Below `makepkg` configuration variables are set in `$HOME/.config/pacman/makepkg.conf`,
# thus not needed here.

#-- Destination: Specify a fixed directory where all packages will be placed.
# PKGDEST=/home/packages
# PKGDEST="$HOME/build/packages"

#-- Source cache: Specify a fixed directory where source files will be cached.
# SRCDEST=/home/sources
# SRCDEST="$HOME/build/sources"

#-- Source packages: Specify a fixed directory where all src packages will be placed.
# SRCPKGDEST=/home/srcpackages
# SRCPKGDEST="$HOME/build/srcpackages"

#-- Log files: Specify a fixed directory where all log files will be placed.
# LOGDEST=/home/makepkglogs
# LOGDEST="$HOME/build/makepkglogs"

#-- Packager: Name/email of the person or organization building packages.
# PACKAGER="John Doe <john@doe.com>"
# PACKAGER="Magnus G <john@doe.com>"

#-- Specify a key to use for package signing
# GPGKEY=""

# ==================================
# yay.
# ==================================
PACKAGE="yay"
echo "Installing $PACKAGE"
echo "$BUILD_REPOS/$PACKAGE"
rm -rf "${BUILD_REPOS:?}/$PACKAGE"
rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
ls -la "$BUILD_REPOS/$PACKAGE"
ls -la "$BUILD_REPOS/$PACKAGE"
cd "$BUILD_REPOS/$PACKAGE" || exit
build_and_install_package "$PACKAGE"
echo "Installed $PACKAGE version: $($PACKAGE --version)"
cd "$CWD" || exit

# ==================================
# paru:
# Use 'yay' instead.
# Also, needs rust to install, with two options,
# `rust` and `rustup`, with `rust` chosen as default,
# which clashes with later `rustup` installation.
# ==================================
# PACKAGE="paru-git"
# echo "Installing $PACKAGE"
# rm -rf "${BUILD_REPOS:?}/$PACKAGE"
# rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
# git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
# cd "$BUILD_REPOS/$PACKAGE" || exit
# build_and_install_package "$PACKAGE"
# echo "Installed $PACKAGE version: $(paru --version)"
# cd "$CWD" || exit

# ==================================
# snap(d):
# - Ubuntu: `snap` already pre-installed, not re-installed here.
# - Arch: `snap` only installed, below, outside Docker.
# - `dog`:
#   - Only package installed with `snap`.
#   - Only installed outside Docker.
#   - Thus, `dog` available everywhere, except in Docker.
# ==================================
if [ ! -f /.dockerenv ] && [ -z "$DOCKER_BUILD" ]; then
  PACKAGE="snapd"
  echo "Installing $PACKAGE"
  rm -rf "${BUILD_REPOS:?}/$PACKAGE"
  rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
  git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
  cd "$BUILD_REPOS/$PACKAGE" || exit
  build_and_install_package "$PACKAGE"
  # Enable systemd unit that manages main snap communication socket.
  sudo systemctl enable --now snapd.socket
  sudo systemctl enable --now snapd.apparmor.service
  sudo ln -fs /var/lib/snapd/snap /snap
  # Reload all service files and update its internal configuration.
  sudo systemctl daemon-reload
  echo "Installed snap version: $(snap --version)"
  cd "$CWD" || exit
else
  echo "In container, skipping install of snapd."
fi

# ==================================
# zig-bin.
# ==================================
# - Ubuntu: `setup_main.sh` > `snap`.
# - Arch: `pacman`.
# PACKAGE="zig-bin"
# echo "Installing $PACKAGE"
# rm -rf "${BUILD_REPOS:?}/$PACKAGE"
# rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
# git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
# cd "$BUILD_REPOS/$PACKAGE" || exit
# makepkg -si --noconfirm
# cd "$BUILD_HOME/packages" || exit
# sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
# echo "Installed zig CLI version: $(zig version)"
# cd "$CWD" || exit

# ==================================
# infisical-bin.
# ==================================
PACKAGE="infisical-bin"
echo "Installing $PACKAGE"
rm -rf "${BUILD_REPOS:?}/$PACKAGE"
rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
cd "$BUILD_REPOS/$PACKAGE" || exit
build_and_install_package "$PACKAGE"
echo "Installed infisical CLI version: $(infisical --version)"
cd "$CWD" || exit

# ==================================
# hcp-bin.
# ==================================
PACKAGE="hcp-bin"
echo "Installing $PACKAGE"
rm -rf "${BUILD_REPOS:?}/$PACKAGE"
rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
cd "$BUILD_REPOS/$PACKAGE" || exit
build_and_install_package "$PACKAGE"
echo "Installed hcp CLI version: $(hcp version)"
cd "$CWD" || exit

# ==================================
# `yay`: Install AUR packages.
# ==================================
# NOTE: Do not use `sudo` with `yay`.
# `-u`: Ugrade all installed packages, both from official repositories and AUR.
# `-a`: Ugrade only AUR packages.
echo 'Done with aur installs, proceding with yay.'
# echo 'done with aur installs, executing: yay -Sua'
# yay -Sua

# Set yay options.
yay --save --answerclean=None --answerdiff=None --cleanafter

# General packages.
yay -Syu --noconfirm \
  catppuccin-gtk-theme-mocha \
  zen-browser-bin \
  google-chrome \
  hyprshade \
  wlogout \
  waypaper \
  sddm-sugar-candy-git \
  python-screeninfo \
  python-pywalfox \
  bibata-cursor-theme \
  matugen-bin \
  xdg-desktop-portal-hyprland-git \
  xdg-desktop-portal-termfilechooser-hunkyburrito-git \
  zoom \
  whispering-bin

# Ensure right permissions for `gpg-agent`, then restart it.
killall gpg-agent dirmngr 2>/dev/null
chmod 700 "$GNUPGHOME"/crls.d/
gpg-agent --daemon 2>/dev/null

# Packages for development.
yay -Syu --noconfirm \
  doppler-cli-bin

# ==================================
# `paru`: Install AUR packages.
# ==================================
