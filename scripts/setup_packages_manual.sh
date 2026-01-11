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

echo "Running setup_packages_manual.sh as $(whoami), with HOME $HOME and USER $USER."

# ================================================
# Detect system architecture and Ubuntu version
# ================================================
ARCH=$(uname -m)
case $ARCH in
x86_64)
  ARCH_TODOCHECK="x86_64"
  ARCH_7ZIP="x64"
  ARCH_GRPCURL="x86_64"
  ARCH_VAULT="amd64"
  ARCH_NEOVIM="x86_64"
  ARCH_ZIG="x86_64"
  ARCH_TECTONIC="x86_64"
  ARCH_KUBECTL="amd64"
  ARCH_LAZYGIT="x86_64"
  ;;
aarch64 | arm64)
  ARCH_TODOCHECK="arm64"
  ARCH_7ZIP="arm64"
  ARCH_GRPCURL="arm64"
  ARCH_VAULT="arm64"
  ARCH_NEOVIM="arm64"
  ARCH_ZIG="aarch64"
  ARCH_TECTONIC="aarch64"
  ARCH_KUBECTL="arm64"
  ARCH_LAZYGIT="arm64"
  ;;
*)
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

# Detect Ubuntu version if on Ubuntu
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "ubuntu" ]; then
    UBUNTU_VERSION="$VERSION_ID"
    echo "Detected Ubuntu version: $UBUNTU_VERSION"
  fi
fi

echo "Detected architecture: $ARCH"
echo "Architecture mappings - todocheck: $ARCH_TODOCHECK, 7zip: $ARCH_7ZIP, grpcurl: $ARCH_GRPCURL, vault: $ARCH_VAULT, neovim: $ARCH_NEOVIM, zig: $ARCH_ZIG, tectonic: $ARCH_TECTONIC, lazygit: $ARCH_LAZYGIT"

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
# Setup packages not relating to specific repos.
# ================================================

# Install `github-cli` extension: `Copilot`.
if command -v gh &>/dev/null; then
  gh extension install github/gh-copilot
fi

# Install luasocket.
if command -v luarocks &>/dev/null; then
  sudo luarocks install luasocket
fi

# ================================================
# Install eza theme.
# ================================================
# eza uses the theme.yml file stored in $EZA_CONFIG_DIR, or if that is not defined then in $XDG_CONFIG_HOME/eza.
# Download theme repo as reference, but do not symlink $EZA_CONFIG_DIR/theme to it,
# instead just keep own theme from dotfiles sync.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"
git clone https://github.com/eza-community/eza-themes.git "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"

# ================================================
# Install eza completions.
# ================================================
# `eza` software itself is installed with `cargo`.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza"
git clone https://github.com/eza-community/eza.git "${EZA_HOME:-$HOME/.local/share/eza}/eza"

# ================================================
# Manually install tmux plugins, including tmux plugin manager.
# ================================================
rm -rf "${TMUX_HOME:-$HOME/.config/tmux}/plugins"
git clone https://github.com/tmux-plugins/tpm "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tpm"
git clone -b v2.1.1 https://github.com/catppuccin/tmux.git "${TMUX_HOME:-$HOME/.config/tmux}/plugins/catppuccin/tmux"
git clone https://github.com/tmux-plugins/tmux-battery "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-battery"
git clone https://github.com/tmux-plugins/tmux-cpu "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-cpu"

# ================================================
# Install tectonic (Note: Architecture).
# ================================================
PACKAGE="tectonic"
VERSION=$(curl -s "https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest" | \grep -Po '"tag_name": *"tectonic@\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p $STOWDIR/$PACKAGE/bin
# Choose appropriate Linux variant based on architecture
if [ "$ARCH_TECTONIC" = "aarch64" ]; then
  LINUX_VARIANT="unknown-linux-musl"
else
  LINUX_VARIANT="unknown-linux-gnu"
fi
curl -L --output "$TMPDIR/$PACKAGE/$PACKAGE.tar.gz" "https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic@${VERSION}/tectonic-${VERSION}-${ARCH_TECTONIC}-${LINUX_VARIANT}.tar.gz"
tar xzf "$TMPDIR/$PACKAGE/$PACKAGE.tar.gz" -C "$TMPDIR/$PACKAGE"
sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install todocheck (Note: Architecture).
# ================================================
PACKAGE="todocheck"
VERSION=$(curl -s "https://api.github.com/repositories/280693435/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p $STOWDIR/$PACKAGE/bin
curl -L --output "$TMPDIR/$PACKAGE/$PACKAGE" "https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-${ARCH_TODOCHECK}" --output "$TMPDIR/$PACKAGE/$PACKAGE.sha256" "https://github.com/preslavmihaylov/todocheck/releases/download/v${VERSION}/todocheck-v${VERSION}-linux-${ARCH_TODOCHECK}.sha256"
if echo "$(awk '{print $1}' "$TMPDIR/$PACKAGE/$PACKAGE.sha256") $TMPDIR/$PACKAGE/$PACKAGE" | sha256sum --check --status; then
  echo "${PACKAGE} checksum verified, moving binary to stow directory, then stowing."
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
curl -Lo "$TMPDIR/$PACKAGE.tar.xz" "https://github.com/ip7z/7zip/releases/download/${VERSION}/7z${VERSION_NO_DOT}-linux-${ARCH_7ZIP}.tar.xz"
tar xf "$TMPDIR/$PACKAGE.tar.xz" -C "$TMPDIR/$PACKAGE"
sudo mv "$TMPDIR"/"$PACKAGE"/7zz{,s} "$STOWDIR/$PACKAGE/bin"
chmod 755 "$STOWDIR/$PACKAGE"/bin/7zz{,s}
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
curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://github.com/fullstorydev/grpcurl/releases/download/v${VERSION}/grpcurl_${VERSION}_linux_${ARCH_GRPCURL}.tar.gz"
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
curl -Lo "$TMPDIR/$PACKAGE/$PACKAGE.zip" "https://releases.hashicorp.com/${PACKAGE}/${VERSION}/${PACKAGE}_${VERSION}_linux_${ARCH_VAULT}.zip" --output "$TMPDIR/$PACKAGE/$PACKAGE.sha256" "https://releases.hashicorp.com/${PACKAGE}/${VERSION}/${PACKAGE}_${VERSION}_SHA256SUMS"
if echo "$(grep "linux_${ARCH_VAULT}" "$TMPDIR/$PACKAGE/$PACKAGE.sha256" | awk '{print $1}') $TMPDIR/$PACKAGE/$PACKAGE.zip" | sha256sum --check --status; then
  unzip "$TMPDIR/$PACKAGE/$PACKAGE.zip" -d "$TMPDIR/$PACKAGE"
  sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
  chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
  stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE
fi

# ================================================
# Install neovim (Note: Architecture).
# ================================================
PACKAGE="neovim"
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE"
# Stable release:
# curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH_NEOVIM}.tar.gz"
# Nightly release (0.12-dev) - needed for vim.lsp.inline_completion:
curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-${ARCH_NEOVIM}.tar.gz"
tar xzf "$TMPDIR/$PACKAGE.tar.gz" -C "$TMPDIR/$PACKAGE" --strip-components=1
# Copy the extracted files to stow directory
sudo cp -r "$TMPDIR/$PACKAGE"/* "$STOWDIR/$PACKAGE/"
sudo chmod 755 "$STOWDIR/$PACKAGE/bin/nvim"
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install zig (Note: Architecture).
# Needed for `ghostty`.
# ================================================
PACKAGE="zig"
# Use ziglang.org JSON index instead of GitHub API (which may lag behind actual releases).
VERSION=$(curl -s https://ziglang.org/download/index.json | \grep -oP '"[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | tr -d '"')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir -p "$TMPDIR/$PACKAGE/bin"
mkdir -p "$STOWDIR/$PACKAGE/bin"
curl -Lo "$TMPDIR/$PACKAGE.tar.xz" "https://ziglang.org/download/${VERSION}/zig-${ARCH_ZIG}-linux-${VERSION}.tar.xz"
tar xf "$TMPDIR/$PACKAGE.tar.xz" -C "$TMPDIR/$PACKAGE" --strip-components=1
sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$TMPDIR/$PACKAGE/bin/$PACKAGE"
sudo cp -r "$TMPDIR/$PACKAGE"/* "$STOWDIR/$PACKAGE/"
sudo chmod 755 "$STOWDIR/$PACKAGE/bin/$PACKAGE"
stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"

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
PACKAGE=ghostty
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
sudo rm -rf "$HOME/.config/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir "$STOWDIR/$PACKAGE"
mkdir "$HOME/.config/$PACKAGE"
git clone https://github.com/ghostty-org/ghostty.git "$TMPDIR/$PACKAGE"
cd "$TMPDIR/$PACKAGE" || exit
zig build --prefix $STOWDIR/$PACKAGE -Doptimize=ReleaseFast
cd "$CURRENTDIR" || exit
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

# ================================================
# Install Sequoia SDDM theme.
# ================================================
PACKAGE="sddm-sequoia"
sudo rm -rf "$TMPDIR/$PACKAGE"
git clone https://codeberg.org/minMelody/sddm-sequoia.git "$TMPDIR/$PACKAGE"
# Create themes directory if it doesn't exist
sudo mkdir -p /usr/share/sddm/themes
# Remove old installation if exists
sudo rm -rf /usr/share/sddm/themes/sequoia
# Move theme to final location
sudo cp -r "$TMPDIR/$PACKAGE" /usr/share/sddm/themes/sequoia
# Set permissions
sudo chmod -R 755 /usr/share/sddm/themes/sequoia
echo "Sequoia SDDM theme installed to /usr/share/sddm/themes/sequoia"
echo "Remember to:"
echo "  1. Install required packages: qt6 qt6-declarative qt6-5compat"
echo "  2. Install a Nerd Font (v3.0+) system-wide"
echo "  3. Edit SDDM config to set Current=sequoia under [Theme] section"

# ================================================
# Install yazi from source.
# Use manual build instead of `pacman -Syu yazi`.
# ================================================
# Update rustup, also done in `setup_main.sh`.
rustup update
PACKAGE=yazi
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE"/bin # Deviation.
git clone https://github.com/sxyazi/yazi.git "$TMPDIR/$PACKAGE"
cd "$TMPDIR/$PACKAGE" || exit
cargo build --release --locked
mv target/release/yazi target/release/ya $STOWDIR/$PACKAGE/bin
cd "$CURRENTDIR" || exit
stow -vv -d $STOWDIR -t $TARGETDIR $PACKAGE

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
# Arch: `pacman -Syu lazygit`.
# Ubuntu 25.10+: `sudo apt install lazygit`.
# Ubuntu 25.04 and earlier: Use manual build below.
# ================================================

# Function to compare version numbers
function version_compare() {
  if [ "$1" = "$2" ]; then
    return 0 # equal
  fi

  local IFS=.
  local i
  local -a ver1 ver2
  read -ra ver1 <<<"$1"
  read -ra ver2 <<<"$2"

  # fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1 # ver1 > ver2
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2 # ver1 < ver2
    fi
  done
  return 0 # equal
}

# Only install lazygit on Ubuntu 25.04 or earlier
INSTALL_LAZYGIT=false
if [ "$ID" = "ubuntu" ] && [ -n "$UBUNTU_VERSION" ]; then
  version_compare "$UBUNTU_VERSION" "25.04"
  version_result=$?
  if [ $version_result -eq 2 ] || [ $version_result -eq 0 ]; then # Ubuntu version <= 25.04
    INSTALL_LAZYGIT=true
    echo "Ubuntu $UBUNTU_VERSION detected - installing lazygit manually"
  else
    echo "Ubuntu $UBUNTU_VERSION detected - skipping manual lazygit install (use 'sudo apt install lazygit' instead)"
  fi
elif [ "$ID" != "ubuntu" ]; then
  # Not Ubuntu, install lazygit
  INSTALL_LAZYGIT=true
  echo "Non-Ubuntu system detected - install lazygit with package manager."
fi

if [ "$INSTALL_LAZYGIT" = true ]; then
  PACKAGE="lazygit"
  VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  sudo rm -rf "$TMPDIR/$PACKAGE"
  sudo rm -rf "$STOWDIR/$PACKAGE"
  curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_${ARCH_LAZYGIT}.tar.gz"
  # tar'ed file name: lazygit.
  tar xzf "$TMPDIR/$PACKAGE.tar.gz" -C "$TMPDIR"
  sudo install "$TMPDIR/$PACKAGE" -D -t "$STOWDIR/$PACKAGE/bin"
  stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"
fi
unset -f version_compare

# ================================================
# Install AWS CLI.
# ================================================
PACKAGE="awscliv2"
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$TMPDIR/$PACKAGE.zip"
curl -Lo "$TMPDIR/$PACKAGE.zip" "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip"
cat <<EOF >"$TMPDIR/${PACKAGE}_public_key.asc"
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
aGveYQUJDMpiLAAKCRCmMQrMRnJHXKBYD/9Ab0qQdGiO5hObchG8xh8Rpb4Mjyf6
0JrVo6m8GNjNj6BHkSc8fuTQJ/FaEhaQxj3pjZ3GXPrXjIIVChmICLlFuRXYzrXc
Pw0lniybypsZEVai5kO0tCNBCCFuMN9RsmmRG8mf7lC4FSTbUDmxG/QlYK+0IV/l
uJkzxWa+rySkdpm0JdqumjegNRgObdXHAQDWlubWQHWyZyIQ2B4U7AxqSpcdJp6I
S4Zds4wVLd1WE5pquYQ8vS2cNlDm4QNg8wTj58e3lKN47hXHMIb6CHxRnb947oJa
pg189LLPR5koh+EorNkA1wu5mAJtJvy5YMsppy2y/kIjp3lyY6AmPT1posgGk70Z
CmToEZ5rbd7ARExtlh76A0cabMDFlEHDIK8RNUOSRr7L64+KxOUegKBfQHb9dADY
qqiKqpCbKgvtWlds909Ms74JBgr2KwZCSY1HaOxnIr4CY43QRqAq5YHOay/mU+6w
hhmdF18vpyK0vfkvvGresWtSXbag7Hkt3XjaEw76BzxQH21EBDqU8WJVjHgU6ru+
DJTs+SxgJbaT3hb/vyjlw0lK+hFfhWKRwgOXH8vqducF95NRSUxtS4fpqxWVaw3Q
V2OWSjbne99A5EPEySzryFTKbMGwaTlAwMCwYevt4YT6eb7NmFhTx0Fis4TalUs+
j+c7Kg92pDx2uQ==
=OBAt
-----END PGP PUBLIC KEY BLOCK-----
EOF
chmod 600 "$HOME"/.gnupg/*
chmod 700 "$HOME"/.gnupg
gpg --import "$TMPDIR/${PACKAGE}_public_key.asc"
curl -Lo "$TMPDIR/$PACKAGE.zip.sig" "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip.sig"
if ! gpg --verify "$TMPDIR/$PACKAGE.zip.sig" "$TMPDIR/$PACKAGE.zip" >/dev/null 2>&1; then
  echo "AWS CLI signature verification failed, aborting installation."
else
  echo "AWS CLI signature verified, proceeding with installation."
  unzip "$TMPDIR/$PACKAGE.zip" -d "$TMPDIR/$PACKAGE"
  sudo "$TMPDIR/$PACKAGE/aws/install" --bin-dir "$TARGETDIR/bin" --install-dir "$STOWDIR/$PACKAGE"
  # Update: `sudo "$TMPDIR/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update`
  # Uninstall: `sudo /usr/local/aws-cli/v2/current/uninstall`
fi

# ================================================
# Install `kubectl`.
# ================================================
PACKAGE="kubectl"
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE/bin"
curl -Lo "$TMPDIR/$PACKAGE/$PACKAGE" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH_KUBECTL}/kubectl"
sudo mv "$TMPDIR/$PACKAGE/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
chmod 755 $STOWDIR/$PACKAGE/bin/$PACKAGE
curl -Lo "$TMPDIR/$PACKAGE/$PACKAGE.sha256" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH_KUBECTL}/kubectl.sha256"
echo "$(cat "$TMPDIR/$PACKAGE/$PACKAGE.sha256") $STOWDIR/$PACKAGE/bin/$PACKAGE" | sha256sum --check
stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"

# ================================================
# Install Helm CLI (Note: Architecture).
# ================================================
PACKAGE="helm"
VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | \grep -Po '"tag_name": *"\K[^"]*')
sudo rm -rf "$TMPDIR/$PACKAGE"
sudo rm -rf "$STOWDIR/$PACKAGE"
mkdir "$TMPDIR/$PACKAGE"
mkdir -p "$STOWDIR/$PACKAGE/bin"
curl -Lo "$TMPDIR/$PACKAGE.tar.gz" "https://get.helm.sh/helm-${VERSION}-linux-${ARCH_KUBECTL}.tar.gz"
tar xzf "$TMPDIR/$PACKAGE.tar.gz" -C "$TMPDIR/$PACKAGE"
sudo mv "$TMPDIR/$PACKAGE/linux-${ARCH_KUBECTL}/$PACKAGE" "$STOWDIR/$PACKAGE/bin"
chmod 755 "$STOWDIR/$PACKAGE/bin/$PACKAGE"
stow -vv -d "$STOWDIR" -t "$TARGETDIR" "$PACKAGE"

# ================================================
# Various installs via custom scripts.
# ================================================
# `uv`: Python package manager.
curl -LsSf https://astral.sh/uv/install.sh | sh
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
curl https://rclone.org/install.sh | sudo bash
curl -sL https://talos.dev/install | sh
sudo modprobe br_netfilter # Needed for Talos.
# `opencode`: AI-powered coding assistant.
curl -fsSL https://opencode.ai/install | bash
go install sigs.k8s.io/kind@latest

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
# Install lua-language-server from source.
# Guide: https://luals.github.io/wiki/build/
# Requires: ninja, C++17 support.
# Note: Must run in-place, add bin/ to PATH.
# ================================================
PACKAGE="lua-language-server"
LUALS_DIR="$HOME/.local/share/$PACKAGE"
rm -rf "$LUALS_DIR"
git clone https://github.com/LuaLS/lua-language-server.git "$LUALS_DIR"
cd "$LUALS_DIR" || exit
git submodule update --depth 1 --init --recursive
bash ./make.sh
cd "$CURRENTDIR" || exit
echo "lua-language-server installed to $LUALS_DIR"
echo "Ensure $LUALS_DIR/bin is in PATH."

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
