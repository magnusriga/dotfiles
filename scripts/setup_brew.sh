#!/usr/bin/env bash

# HOME=/home/magnus
USERNAME=nfu
HOME=/home/$USERNAME

echo "Running setup_brew.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Download and install Homebrew.
sudo rm -rf ${LINUXBREW_HOME:-/home/linuxbrew/.linuxbrew}
sudo rm -rf $HOME/.cache/Homebrew
sudo mkdir ${LINUXBREW_HOME:-/home/linuxbrew/.linuxbrew}
sudo chown -hR $USERNAME ${LINUXBREW_HOME:-/home/linuxbrew/.linuxbrew}
PATH=${LINUXBREW_HOME:-/home/linuxbrew/.linuxbrew}/bin:$PATH
if [ -z "$(brew --version 2> /dev/null)" ]; then
  echo "Installing Homebrew."
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
fi

# Add $LINUXBREW_HOME to PATH.
eval $(${LINUXBREW_HOME:-/home/linuxbrew/.linuxbrew}/bin/brew shellenv)

# Update Homebrew and upgrade its packages.
echo "Brew prefix is: $(brew --prefix)"
brew update-reset
brew update
brew upgrade

# Install ZSH shell.
if [ -z "$(which zsh)" ]; then
  echo 'Installing zsh...'
  brew install -vd zsh
fi

# Install Homebrew packages.
 brew install -vd preslavmihaylov/taps/todocheck
 brew install -vd pre-commit
 brew install -vd gh
 brew install -vd jless
 brew install -vd rg
 brew install -vd ast-grep
 brew install -vd tmux
brew install -vd jesseduffield/lazygit/lazygit
brew tap wez/wezterm-linuxbrew
brew install wezterm
brew install zoxide
brew install ffmpegthumbnailer sevenzip imagemagick
brew install yazi --HEAD
brew install zsh-vi-mode
brew install glow
brew install zsh-autosuggestions
brew install neovim

# These install node via linuxbrew, so do not install them with brew.
# brew install neonctl
# brew install contentful-cli

# Uninstall Homebrew packages that clash with below installations.
if [ -n "$(brew list --versions rust)" ]; then brew uninstall rust; fi
brew autoremove

# Remove outdated versions from the cellar.
brew cleanup

# =======================================
# OLD
# =======================================

# Save Homebrew’s installed location.
# BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# brew install coreutils
# ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
# brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
# brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
# brew install gnu-sed --with-default-names
# Install a modern version of Bash.
# brew install bash
# brew install bash-completion2

# Switch to using brew-installed bash as default shell
# if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
#   echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
#   chsh -s "${BREW_PREFIX}/bin/bash";
# fi;

# Install `wget` with IRI support.
# brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
# brew install gnupg

# Install more recent versions of some macOS tools.
# brew install vim --with-override-system-vi
# brew install grep
# brew install openssh
# brew install screen
# brew install php
# brew install gmp

# Install font tools.
# brew tap bramstein/webfonttools
# brew install sfnt2woff
# brew install sfnt2woff-zopfli
# brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
# brew install aircrack-ng
# brew install bfg
# brew install binutils
# brew install binwalk
# brew install cifer
# brew install dex2jar
# brew install dns2tcp
# brew install fcrackzip
# brew install foremost
# brew install hashpump
# brew install hydra
# brew install john
# brew install knock
# brew install netpbm
# brew install nmap
# brew install pngcheck
# brew install socat
# brew install sqlmap
# brew install tcpflow
# brew install tcpreplay
# brew install tcptrace
# brew install ucspi-tcp # `tcpserver` etc.
# brew install xpdf
# brew install xz

# Install other useful binaries.
# brew install ack
# brew install exiv2
# brew install git
# brew install git-lfs
# brew install gs
# brew install imagemagick --with-webp
# brew install lua
# brew install lynx
# brew install p7zip
# brew install pigz
# brew install pv
# brew install rename
# brew install rlwrap
# brew install ssh-copy-id
# brew install tree
# brew install vbindiff
# brew install zopfli
