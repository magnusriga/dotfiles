#!/usr/bin/env bash

echo "Running setup_git_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Paths for stow.
TARGETDIR="/usr/local"
STOWDIR="/usr/local/stow"
sudo chown $USER:$USER $STOWDIR

# Other variables.
TMPDIR="/tmp"

# Create directories.
mkdir -p "usr/local/stow" 

# Install fzf.
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install lazygit (note the architecture).
PACKAGE="lazygit"
VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo $TMPDIR/$PACKAGE.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_arm64.tar.gz"
tar xf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR
sudo install $TMPDIR/$PACKAGE -D -t $STOWDIR/$PACKAGE/bin

# Install Stow (needs autoconf package pre-installed).
PACKAGE="stow"
VERSION=$(curl -s "https://api.github.com/repos/aspiers/stow/tags" | \grep -Po '"name": *"v\K[^"]*' | head -n 1)
sudo rm -rf $STOWDIR/$PACKAGE 
rm -rf "$TMPDIR/$PACKAGE-$VERSION" 
mkdir -p "$STOWDIR/$PACKAGE"
mkdir -p "$TMPDIR/$PACKAGE-$VERSION"
curl -Lo $TMPDIR/$PACKAGE.tar.gz "https://github.com/aspiers/stow/archive/refs/tags/v${VERSION}.tar.gz"
tar xf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR
cd "$TMPDIR/$PACKAGE-$VERSION"
[[ ! -f "$TMPDIR/$PACKAGE-$VERSION/configure" ]] && autoreconf -iv
./configure --prefix=$TARGETDIR && sudo make install prefix=$STOWDIR/$PACKAGE
