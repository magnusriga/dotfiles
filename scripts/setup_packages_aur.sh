#!/usr/bin/env bash

echo "Running setup_packages_aur.sh as $(whoami), with HOME $HOME and USER $USER."

# ==================================
# Set chroot path.
# ==================================
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
# Stow `makepkg` configuration into correct folder
# where `makepkg` will pick it up.
# ==================================
stow --no-folding -vv -d "$HOME/dotfiles/stow" -t "$HOME" pacman

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

# ==================================
# Build and Intstall Package.
# ==================================
# Pre-requisites:
# - Manually download `PKGBUILD` file, and other files needed for build.
#    - Done with `git clone <repo>`, using `<repo>` found in e.g. AUR.
#    - Use target directory: `$HOME/build/repositories/<package>`.
#    - Command : `git clone <url> $HOME/build/repositories/$PACKAGE`.
# - Create clean chroot.
#    - Run `makeCleanChroot`, defined above.
#    - Only run once, as `makechrootpkg -c` will automatically clean chroot folder before building.
#
# Steps:
# 1) Build inside clean chroot: `makechrootpkg -c -r $CHROOT -- -sc --noconfirm`.
#    IMPORTANT: `makechrootpkg` must be run as normal user, NOT as root, i.e. not with `sudo`.
#    a) `makechrootpkg` reads `PKGBUILD` to identify url of source files.
#    b) `makechrootpkg` downloads source files into `SRCDEST`.
#    c) `makechrootpkg` compiles source files into installable `.pkg.tar.zst` package.
#
# 2) Install:
#    - Install package with: `pacman -U <pkgname-pkgver>.pkg.tar.zst` OR `makepkg -i | --install`.
#    - Prefer `pacman`, because it does not install all packages in directory, only those explicitly specified.
#    - Moves executable files, man pages, etc., to specific directory.
#    - Alternatively, to skip this step, call `makepkg` with `-i` flag initially.
#
# 3) Clean:
#    - `makepkg -c | --clean` cleans up `$srcdest` directory
#    - `$srcdest` stores temporary files needed during build.
#    - `$srcdest` often defined in `PKGBUILD` file.
#
# Alternative step (1):
# 1) Build in current directory: `makepkg -srci`
#    - Avoid, use clean chroot approach instead.
#    - IMPORTANT: `makepkg` must be run as normal user, NOT as root, i.e. not with `sudo`.
#    a) `makekpkg` reads `PKGBUILD` to identify url of source files.
#    b) `makekpkg` downloads source files into `SRCDEST`.
#    c) `makekpkg` compiles source files into installable `.pkg.tar.zst` package.
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
# `makechrootpkg` command.
# ==================================
# - Run `makechrootpkg` script in directory containing PKGBUILD, to build a package inside a clean chroot.
# - Arguments passed to this script after end-of-options marker (--) will be passed to makepkg.
# - This script reads {SRC,SRCPKG,PKG,LOG}DEST, MAKEFLAGS and PACKAGER from makepkg.conf(5),
#   if those variables are not part of the environment.
# - Common `makechrootpkg` options:
#   - `-c`: Working chroot ($CHROOT/$USER) is cleaned before building, thus no need to recreate $CHROOT directory each time.
#   - `-r`: Chroot directory to use.
# - Default arguments passed to `makepkg`:
#   - `--syncdeps`.
#   - `--noconfirm`.
#   - `--log`.
#   - `--holdver`.
#   - `--skipinteg`.
# - Suggested full command: `makechrootpkg -c -r $CHROOT -- -sc --noconfirm`.
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
# to be installed by `pacman -U <pkg>` | `makepkg -i`.
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
makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
cd "$BUILD_HOME/packages" || exit
sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
echo "Installed $PACKAGE version: $($PACKAGE --version)"
cd "$CWD" || exit

# ==================================
# paru.
# ==================================
PACKAGE="paru-git"
echo "Installing $PACKAGE"
rm -rf "${BUILD_REPOS:?}/$PACKAGE"
rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
cd "$BUILD_REPOS/$PACKAGE" || exit
makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
cd "$BUILD_HOME/packages" || exit
sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
echo "Installed $PACKAGE version: $(paru --version)"
cd "$CWD" || exit

# ==================================
# snapd.
# ==================================
PACKAGE="snapd"
echo "Installing $PACKAGE"
rm -rf "${BUILD_REPOS:?}/$PACKAGE"
rm -f "$BUILD_HOME/packages/$PACKAGE"-[0-9]*
git clone https://aur.archlinux.org/$PACKAGE.git "$BUILD_REPOS/$PACKAGE"
cd "$BUILD_REPOS/$PACKAGE" || exit
makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
cd "$BUILD_HOME/packages" || exit
sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
echo "Installed snap version: $(snap --version)"
# Enable systemd unit that manages main snap communication socket.
if [ ! -f /.dockerenv ]; then
  sudo systemctl enable --now snapd.socket
  sudo systemctl enable --now snapd.apparmor.service
else
  echo "Skipping systemd commands for snapd in container environment"
fi
sudo ln -fs /var/lib/snapd/snap /snap
cd "$CWD" || exit

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
# makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
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
makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
cd "$BUILD_HOME/packages" || exit
sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
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
makechrootpkg -c -r "$CHROOT" -- -sc --noconfirm
cd "$BUILD_HOME/packages" || exit
sudo pacman -U --noconfirm "$PACKAGE"-[0-9]*
echo "Installed hcp CLI version: $(hcp version)"
cd "$CWD" || exit

# ==================================
# `yay`: Install AUR packages.
# ==================================
# NOTE: Do not use `sudo` with `yay`.
# `-u`: Ugrade all installed packages, both from official repositories and AUR.
# `-a`: Ugrade only AUR packages.
echo 'Done with aur installs.'
# echo 'done with aur installs, executing: yay -Sua'
# yay -Sua

# ==================================
# `paru`: Install AUR packages.
# ==================================
