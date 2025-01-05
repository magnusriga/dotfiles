#!/usr/bin/env bash

echo "Running setup_packages_aur.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ==================================
# Build and Intstall Package.
# ==================================
# Pre-requisite:
# - Manually download `PKGBUILD` file, and other files needed for build.
# - Done with `git clone <repo>`, using `<repo>` found in e.g. AUR.
# - Use target directory: `$HOME/build/repositories/<package>`.
# - Command : `git clone <url> $HOME/build/repositories/$PACKAGE`.
#
# 1) Build with `makepkg -srci`:
#    IMPORTANT: `makepkg` must be run as normal user, NOT as root, i.e. not with `sudo`.
#    a) `makekpkg` reads `PKGBUILD` to identify url of source files.
#    b) `makekpkg` downloads source files into `SRCDEST`.
#    c) `makekpkg` compiles source files into installable `.pkg.tar.zst` package.
#
# 2) Install:
#    - Install package with: `makepkg -i | --install` OR `pacman -U <pkgname-pkgver>.pkg.tar.zst`.
#    - Which moves executable files, man pages, etc., to specific directory.
#    - Alternatively, to skip this step, call `makepkg` with `-i` flag initially.
#
# 3) Clean:
#    - `makepkg -c | --clean` cleans up `$srcdest` directory
#    - `$srcdest` stores temporary files needed during build.
#    - `$srcdest` often defined in `PKGBUILD` file.
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

# Where `PKGBUILD` files are manually placed with `git clone`.
export BUILD_REPOSITORY="${BUILD_HOME:-$HOME/build}/repository"

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
# snapd.
# ==================================
PACKAGE="snapd"
rm -rf $BUILD_REPOSITORY/$PACKAGE
git clone https://aur.archlinux.org/$PACKAGE.git $BUILD_REPOSITORY/$PACKAGE
cd $BUILD_REPOSITORY/$PACKAGE
makepkg -sci --noconfirm
# Enable systemd unit that manages main snap communication socket.
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service
sudo ln -s /var/lib/snapd/snap /snap
cd $CWD

