#!/usr/bin/env bash

# ========================================================
# NOTES
# ========================================================
# - Binaries downloaded manually are first compiled or downloaded into /tmp/<package>,
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

echo "Running setup_git_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Store the current directory, restored at end of script.
CURRENTDIR=$(pwd)

# Paths for stow.
TARGETDIR="/usr/local"
STOWDIR="/usr/local/stow"

# Other variables.
TMPDIR="/tmp"

# Create directories.
mkdir -p $STOWDIR 

# Set permissions.
sudo chown -R $USER:$USER $TARGETDIR
sudo chmod -R 755 $TARGETDIR

# Install Stow (needs `autoconf` pre-installed).
PACKAGE="stow"
# VERSION works, but not needed when using git curl.
# VERSION=$(curl -s "https://api.github.com/repos/aspiers/stow/tags" | \grep -Po '"name": *"v\K[^"]*' | head -n 1)
sudo rm -rf "$TMPDIR/$PACKAGE" 
sudo rm -rf $STOWDIR/$PACKAGE 
rm /usr/local/bin/stow /usr/local/bin/chkstow 
mkdir -p "$STOWDIR/$PACKAGE"
cpan install Test::Output
cpan install Test::More
git clone https://github.com/aspiers/stow.git $TMPDIR/$PACKAGE
cd "$TMPDIR/$PACKAGE"
[[ ! -f "$TMPDIR/$PACKAGE/configure" ]] && autoreconf -iv
./configure --prefix=$TARGETDIR && make install prefix=$STOWDIR/$PACKAGE
# By defualt, stow uses current directory as stow directory,
# and parent of current directory as target directory,
# thus change to pre-set stow directory berore running stow command
# without any command options.
# Alternatively, use options: `stow -d <stow_dir> -t <target_dir>`.
cd $STOWDIR
# stow is not yet added to PATH, thus to stow stow itself,
# use perl to run stow binary on the `stow` package.
perl stow/bin/stow -vv stow
# Revert current directory.
cd $CURRENTDIR
# Rebuild shell's command hash table, in case shell has wrong path to stow.
# https://superuser.com/a/1016137/618317
hash -r

# Install lazygit (note the architecture).
PACKAGE="lazygit"
VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE" 
sudo rm -rf "$STOWDIR/$PACKAGE" 
curl -Lo $TMPDIR/$PACKAGE.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_arm64.tar.gz"
# tar'ed file is called lazygit.
tar xf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR
sudo install $TMPDIR/$PACKAGE -D -t $STOWDIR/$PACKAGE/bin
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# Install todocheck.
PACKAGE="todocheck"
VERSION=$(curl -s "https://api.github.com/repos/preslavmihaylov/todocheck/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE" 
sudo rm -rf "$STOWDIR/$PACKAGE" 
mkdir $TMPDIR/$PACKAGE
mkdir -p $STOWDIR/$PACKAGE/bin
curl -L --output $TMPDIR/$PACKAGE/$PACKAGE https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64 --output $TMPDIR/$PACKAGE/$PACKAGE.sha256 https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64.sha256
if echo "$(cat $TMPDIR/$PACKAGE/$PACKAGE.sha256)" | echo "$(awk '{print $1}') $TMPDIR/$PACKAGE/$PACKAGE" | sha256sum --check --status ; then
  sudo mv $TMPDIR/$PACKAGE/$PACKAGE $STOWDIR/$PACKAGE/bin
  chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
  stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
fi

# Install fzf.
rm -rf $HOME/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install

# Install zoxide.
# Does not use stow, thus places binary in `$HOME/.local/bin`,
# and man pages in `$HOME/.local/share/man`.
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install cmake (needed by e.g. ffmpegthumbnailer).
# Using apt-get instead.
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

# Install ffmpegthumbnailer (for yazi).
PACKAGE="ffmpegthumbnailer"
sudo rm -rf "$TMPDIR/$PACKAGE" 
git clone https://github.com/dirkvdb/ffmpegthumbnailer.git $TMPDIR/$PACKAGE
cd "$TMPDIR/$PACKAGE"
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_GIO=ON -DENABLE_THUMBNAILER=ON .
cd $CURRENTDIR
