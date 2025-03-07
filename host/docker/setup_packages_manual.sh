#!/usr/bin/env bash

# ========================================================
# NOTES
# ========================================================
# - Binaries downloaded manually are first compiled or downloaded into /tmp/<package>.
# - If the file is downloaded with curl, checksums are verified.
# - The package is then installed into `/usr/local/stow/<package>`,
#   or, if it was a downloaded binary, moved into: `/usr/local/stow/<package>/bin/<binary>`.
# - `stow` is later run, to symlink packages into target directory, i.e. `/usr/local`,
#   resuling in binary files appearing to be present in `/usr/local/bin/<binary>`,
#   man pages in `/usr/local/man/<manfolders>`, etc.
# - With stow it is easier to update and delete packages,
#   i.e. it is not necessary to remember which files belong to which package,
#   which would be necessary if all bin files were placed directly in `usr/local/bin`,
#   all man pages in `/usr/local/man`, etc.
# - When package in stow folder is update or deleted, and stow runs again,
#   stow updates target directory, i.e. `/usr/local`, accordingly.
#   resuling in the binary appearing to be present here: `/usr/local/bin/<binary>`.
# - Remember: Add `/usr/local/bin` to PATH.
# ========================================================

# ========================================================
# NOTE: configure, make, make install
# ========================================================
# - Guide: https://thoughtbot.com/blog/the-magic-behind-configure-make-make-install
# - `configure.ac`: File executed with `autoconf`, to generate `configure` script.
# - `Makefile.am`: File executed with `automake`, to generate `Makefile.in` template,
#   which in turn is used by both `configure` script and `make` command.
# - `configure` script: Reads `Makefile.in` and system information, to ready software,
#   including checking all dependencies are installed (like C compiler `gcc`).
# - `make`: Reads `Makefile.in` to build software, often into `build` folder in current directory,
#   meaning compile source code into byte code, and download, build, and link in dependencies.
# - `make install`: Copies package files (bin, lib, share, ...) into install location,
#   often set when running `configure` or `make`,
#   including copying binary to directory in PATH (e.g. `/usr/local/bin`),
#   man pages to directory in MANPATH, etc.
# - Typical steps to build and install (i.e. copy) software:
#   1) autoconf     : Creates `configure` script, from `configure.ac`.
#   2) automake     : Creates `Makefile.in` template, from `Makefile.am`.
#   3) configure    : Readies software for install. <-- Sometimes skipped, if done by `make`.
#   4) make         : Builds software, i.e. compile program and link dependencies.
#   5) make install : Copies program files to appropriate locations,
#                     often set in `configure` or `make` steps,
#                     e.g. binary to directory from PATH,
#                     man pages to directory from MANPATH.
# ========================================================

echo "Running setup_git_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ================================================
# Setup directories and variables needed for
# manual package builds.
# ================================================
# Store the current directory, restored at end of script.
CURRENTDIR=$(pwd)

# Paths for stow.
TARGETDIR="/usr/local"
STOWDIR="/usr/local/stow"

# Where to download build files, like git repositories.
# TMPDIR="/tmp"
TMPDIR="$HOME/build"

# Create directories.
sudo mkdir -p $STOWDIR

# Set permissions.
sudo chown -R "$USER":"$USER" $TARGETDIR $STOWDIR
sudo chmod -R 755 $TARGETDIR

# ================================================
# Install todocheck (Note: Architecture).
# ================================================
PACKAGE="todocheck"
VERSION=$(curl -s "https://api.github.com/repos/preslavmihaylov/todocheck/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p $STOWDIR/$PACKAGE/bin
curl -L --output "$TMPDIR/$PACKAGE/$PACKAGE" "https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64" --output "$TMPDIR/$PACKAGE/$PACKAGE.sha256" "https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64.sha256"
if echo "$(cat "$TMPDIR/$PACKAGE/$PACKAGE.sha256" | awk '{print $1}') $TMPDIR/$PACKAGE/$PACKAGE" | sha256sum --check --status; then
  sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
  chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
  stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
fi

# ================================================
# Install 7zip (Note: Architecture and Version).
# ================================================
PACKAGE="7z"
VERSION=$(curl -s "https://api.github.com/repos/ip7z/7zip/releases/latest" | \grep -Po '"tag_name": *"\K[^"]*')
VERSION_NO_DOT=$(echo "$VERSION" | tr -d '.')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE/bin"
curl -Lo "$TMPDIR/$PACKAGE.tar.xz" "https://github.com/ip7z/7zip/releases/download/${VERSION}/7z${VERSION_NO_DOT}-linux-arm64.tar.xz"
tar xzf "$TMPDIR/$PACKAGE.tar.xz" -C "$TMPDIR/$PACKAGE"
sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
chmod 755 "$STOWDIR/$PACKAGE/bin/$PACKAGE"
stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"

# ================================================
# Install grpcurl (Note: Architecture).
# ================================================
PACKAGE="grpcurl"
VERSION=$(curl -s "https://api.github.com/repos/fullstorydev/grpcurl/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE/bin"
curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://github.com/fullstorydev/grpcurl/releases/download/v${VERSION}/grpcurl_${VERSION}_linux_arm64.tar.gz"
# tar'ed file name: grpcurl.
tar xzf "$TMPDIR/$PACKAGE.tar.gz" -C "$TMPDIR/$PACKAGE"
sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
chmod 755 "$STOWDIR/$PACKAGE/bin/$PACKAGE"
stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"

# ================================================
# Install HashiCorp vault (Note: Architecture).
# ================================================
PACKAGE="vault"
# `grep -P`: Use perl-compatible regex (PCRE).
# `grep -o`: Output match only, not whole line.
# `\K`     : Start match from this position.
# `[^/]*`  : Zero or more off all characters except `/`.
# Thus, match ends when first slash is encountered, and match is printed.
VERSION=$(curl -s "https://releases.hashicorp.com/vault/" | \grep -Po '"/vault/\K[^/]*' | grep -v '[-+]' | head -n 1)
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p $STOWDIR/$PACKAGE/bin
curl -L --output "$TMPDIR/$PACKAGE/$PACKAGE.zip" "https://releases.hashicorp.com/${PACKAGE}/${VERSION}/${PACKAGE}_${VERSION}_linux_arm64.zip" --output "$TMPDIR/$PACKAGE/$PACKAGE.sha256" "https://releases.hashicorp.com/${PACKAGE}/${VERSION}/${PACKAGE}_${VERSION}_SHA256SUMS"
if echo "$(cat "$TMPDIR/$PACKAGE/$PACKAGE.sha256" | grep 'linux_arm64' | awk '{print $1}') $TMPDIR/$PACKAGE/$PACKAGE.zip" | sha256sum --check --status; then
  unzip "$TMPDIR/$PACKAGE/$PACKAGE.zip" -d "$TMPDIR/$PACKAGE"
  sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
  chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
  stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
fi

# ================================================
# Install neovim.
# Use `pacman -Syu neovim` instead.
# ================================================
PACKAGE=neovim
BUILD_TYPE=Release
# `$TMPDIR/$PACKAGE/build` holds CMake cache,
# which must be cleared before rebuilding.
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir "$STOWDIR/$PACKAGE"
git clone https://github.com/neovim/neovim "$TMPDIR/$PACKAGE"
cd "$TMPDIR/$PACKAGE" || exit
# make: Downloads and builds dependencies,
# and puts nvim executable in `build/nvim`.
make CMAKE_BUILD_TYPE=$BUILD_TYPE CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$STOWDIR/$PACKAGE"
# After building, nvim executable can be run with
# `VIMRUNTIME=runtime ./build/bin/nvim`.
# Instead, run `make install`, to copy package files (bin, lib, share, ...),
# to install location, set with flag in `make` step,
# including copying binary to directory in PATH (e.g. `/usr/local/bin`),
# man pages to directory in MANPATH, etc.
make install
cd "$CURRENTDIR" || exit
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install ghostty from source.
# Use manual build instead of `pacman -Syu ghostty`.
# ================================================
# # - Prefix sets ghostty's install directory,
# #   including where `theme`, `shell-integration`, etc. is stored,
# #   e.g. `$prefix/share/ghostty/shell-integration`.
# # - Use `PREFIX=/usr/local/stow/ghostty`,
# #   which is symlinked to `/usr/local/ghostty`,
# #   meaning `shell-integration` folder.
# # - Ghostty install adds several directories directly into `$PREFIX/share`,
# #   i.e. not only into `$PREFIX/share/ghostty`,
# #   containing various application configurations for ghostty,
# #   e.g. `bat` folder contains syntax highlighting file for ghostty.
# # - Thus, as always, stow dotfiles into home directory after this file has run,
# #   to ensure symlinks are not overwritten.
# PACKAGE=ghostty
# PREFIX=$STOWDIR/$PACKAGE
# sudo rm -rf "$TMPDIR/$PACKAGE"
# sudo rm -rf "$STOWDIR/$PACKAGE"
# sudo rm -rf "$HOME/.config/$PACKAGE"
# mkdir "$TMPDIR/$PACKAGE"
# mkdir "$STOWDIR/$PACKAGE"
# mkdir "$HOME/.config/$PACKAGE"
# git clone https://github.com/ghostty-org/ghostty.git "$TMPDIR/$PACKAGE"
# cd "$TMPDIR/$PACKAGE"
# zig build --prefix $STOWDIR/$PACKAGE -Doptimize=ReleaseFast
# cd -- "$(dirname "$BASH_SOURCE")"
# cp ~{/dotfiles,}/.stow-global-ignore
# cd $CURRENTDIR
# stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install Stow (needs `autoconf` pre-installed).
# Use `pacman -Syu stow` instead.
# ================================================
# # VERSION works, but not needed when using git curl.
# # VERSION=$(curl -s "https://api.github.com/repos/aspiers/stow/tags" | \grep -Po '"name": *"v\K[^"]*' | head -n 1)
# PACKAGE="stow"
# sudo rm -rf "$TMPDIR/$PACKAGE"
# sudo rm -rf $STOWDIR/$PACKAGE
# rm /usr/local/bin/stow /usr/local/bin/chkstow
# mkdir -p "$STOWDIR/$PACKAGE"
# cpan install CPAN
# cpan install Test::Output
# cpan install Test::More
# git clone https://github.com/aspiers/stow.git $TMPDIR/$PACKAGE
# cd "$TMPDIR/$PACKAGE"
# [[ ! -f "$TMPDIR/$PACKAGE/configure" ]] && autoreconf -iv
# ./configure --prefix=$TARGETDIR && make install prefix=$STOWDIR/$PACKAGE
# # By defualt, stow uses current directory as stow directory,
# # and parent of current directory as target directory,
# # thus change to pre-set stow directory berore running stow command
# # without any command options.
# # Alternatively, use options: `stow -d <stow_dir> -t <target_dir>`.
# cd $STOWDIR
# # stow is not yet added to PATH, thus to stow stow itself,
# # use perl to run stow binary on the `stow` package.
# perl stow/bin/stow -vv stow
# # Revert current directory.
# cd $CURRENTDIR
# # Rebuild shell's command hash table, in case shell has wrong path to stow.
# # https://superuser.com/a/1016137/618317
# hash -r

# ================================================
# Install lazygit (Note: Architecture).
# Use `pacman -Syu stow` instead.
# ================================================
# PACKAGE="lazygit"
# VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
# sudo rm -rf "$TMPDIR/$PACKAGE"
# sudo rm -rf "$STOWDIR/$PACKAGE"
# curl -Lo $TMPDIR/$PACKAGE.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_arm64.tar.gz"
# # tar'ed file name: lazygit.
# tar xzf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR
# sudo install $TMPDIR/$PACKAGE -D -t $STOWDIR/$PACKAGE/bin
# stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install fzf.
# Use `pacman -Syu fzf` instead.
# ================================================
# PACKAGE="fzf"
# sudo rm -rf $TMPDIR/$PACKAGE
# mkdir $TMPDIR/$PACKAGE
# git clone --depth 1 https://github.com/junegunn/fzf.git $TMPDIR/$PACKAGE
# $TMPDIR/$PACKAGE/.fzf/install

# ================================================
# Install zoxide.
# Use `pacman -Syu zoxide` instead.
# ================================================
# Does not use stow, thus places binary in `$HOME/.local/bin`,
# and man pages in `$HOME/.local/share/man`.
# curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# ================================================
# Install cmake (needed by e.g. ffmpegthumbnailer).
# Use `pacman -Syu cmake` instead.
# ================================================
# PACKAGE="cmake"
# VERSION=$(curl -s "https://api.github.com/repos/Kitware/CMake/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
# sudo rm -rf "$TMPDIR/$PACKAGE-$VERSION"
# sudo rm -rf "$STOWDIR/$PACKAGE"
# mkdir $TMPDIR/$PACKAGE-$VERSION
# curl -Lo $TMPDIR/$PACKAGE.tar.gz "https://github.com/Kitware/CMake/releases/download/v${VERSION}/cmake-${VERSION}.tar.gz"
# tar xzf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR
# cd "$TMPDIR/$PACKAGE-$VERSION"
# ./bootstrap
# make
# sudo make install
# cd $CURRENTDIR

# ================================================
# Install ffmpegthumbnailer (for yazi).
# Use `pacman -Syu ffmpeg` instead.
# ================================================
# PACKAGE="ffmpegthumbnailer"
# sudo rm -rf "$TMPDIR/$PACKAGE"
# git clone https://github.com/dirkvdb/ffmpegthumbnailer.git $TMPDIR/$PACKAGE
# cd "$TMPDIR/$PACKAGE"
# cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_GIO=ON -DENABLE_THUMBNAILER=ON .
# cd $CURRENTDIR

# ================================================
# Install 7zip (Note: Architecture).
# Use `pacman -Syu 7zip` instead.
# ================================================
# PACKAGE="7zip"
# sudo rm -rf "$TMPDIR/$PACKAGE"
# sudo rm -rf "$STOWDIR/$PACKAGE"
# mkdir "$TMPDIR/$PACKAGE"
# mkdir -p "$STOWDIR/$PACKAGE/bin"
# curl -LO --output-dir $TMPDIR "https://www.7-zip.org/a/7z2409-linux-arm64.tar.xz"
# tar xf $TMPDIR/7z2409-linux-arm64.tar.xz -C $TMPDIR/$PACKAGE
# sudo mv $TMPDIR/$PACKAGE/7zz $TMPDIR/$PACKAGE/7zzs $STOWDIR/$PACKAGE/bin
# chmod 755 $STOWDIR/$PACKAGE/bin/7zz $STOWDIR/$PACKAGE/bin/7zzs
# stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install luarocks, needed by lazyvim.
# Use `pacman -Syu luarocks` instead.
# ================================================
# PACKAGE="luarocks"
# VERSION=$(curl -L "https://luarocks.org/releases" | grep -Po '(?<=luarocks-)(\d+\.\d+\.\d+)' | head -n 1)
# sudo rm -rf "$STOWDIR/$PACKAGE"
# mkdir "$STOWDIR/$PACKAGE"
# curl -LO --output-dir $TMPDIR "https://luarocks.org/releases/$PACKAGE-$VERSION.tar.gz"
# tar xzpf $TMPDIR/$PACKAGE-$VERSION.tar.gz -C $TMPDIR
# cd $TMPDIR/$PACKAGE-$VERSION
# ./configure --prefix=$STOWDIR/$PACKAGE
# make
# sudo make install
# stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
# cd $CURRENTDIR
# sudo luarocks install luasocket
# lua require "socket"
# stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
