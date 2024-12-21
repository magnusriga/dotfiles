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

STOWDIR="/usr/local/stow"
TMPDIR="/tmp"

# Install todocheck.
PACKAGE="todocheck"
VERSION=$(curl -s "https://api.github.com/repos/preslavmihaylov/todocheck/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
mkdir $TMPDIR/$PACKAGE
sudo mkdir -p $STOWDIR/$PACKAGE/bin
curl -L --output $TMPDIR/$PACKAGE/$PACKAGE https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64 --output $TMPDIR/$PACKAGE/$PACKAGE.sha256 https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-arm64.sha256
if echo "$(cat $TMPDIR/$PACKAGE/$PACKAGE.sha256)" | echo "$(awk '{print $1}') $TMPDIR/$PACKAGE/$PACKAGE" | sha256sum --check --status ; then
  sudo mv $TMPDIR/$PACKAGE/$PACKAGE $STOWDIR/$PACKAGE/bin
fi

# Install stow.
PACKAGE="stow"
rm -rf $TMPDIR/$PACKAGE
mkdir $TMPDIR/$PACKAGE
cpan install Test::Output
cpan install Test::More
curl -Lo $TMPDIR/$PACKAGE.tar.gz https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
tar xf $TMPDIR/$PACKAGE.tar.gz -C $TMPDIR/$PACKAGE
cd $TMPDIR/$PACKAGE/stow-2.4.1
sudo ./configure && sudo make install
