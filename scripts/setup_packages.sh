#!/usr/bin/env bash

echo "Running setup_packages.sh as $(whoami), with HOME $HOME and USER $USER."

# ==========================================================
# Detect Linux distribution
# ==========================================================
function detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    # Handle Arch Linux ARM which has ID=archarm but ID_LIKE=arch
    if [ "$ID" = "archarm" ] && [ "$ID_LIKE" = "arch" ]; then
      echo "arch"
    else
      echo "$ID"
    fi
  elif [ -f /etc/arch-release ]; then
    echo "arch"
  elif [ -f /etc/debian_version ]; then
    echo "ubuntu"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_distro)
echo "Detected distribution: $DISTRO"

if [ "$DISTRO" != "arch" ] && [ "$DISTRO" != "ubuntu" ]; then
  echo "Unsupported distribution: $DISTRO"
  echo "This script only supports Arch Linux and Ubuntu."
  exit 1
fi

# ==========================================================
# Ubuntu-specific setup
# ==========================================================
function setup_ubuntu_repositories() {
  echo "Setting up Ubuntu repositories..."

  # Stop snapd service if it is running, so it can be upgraded.
  systemctl --quiet is-active snapd.service && sudo service snapd stop

  # Create public key directory.
  sudo mkdir -p -m 755 /etc/apt/keyrings

  # GitHub CLI (for package `gh`).
  (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) &&
    out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
    sudo cp "$out" /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  # glow.
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null

  # fastfetch.
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch

  # Infisical CLI.
  curl -1sLf 'https://artifacts-cli.infisical.com/setup.deb.sh' | sudo -E bash

  # HashiCorp HCP CLI.
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

  # Update package lists
  sudo apt-get update
}

# ==========================================================
# Define common packages that have identical names
# ==========================================================
COMMON_PACKAGES=(
  autoconf
  bash
  bat
  blueprint-compiler gettext
  btrfs-progs
  ca-certificates
  cmake
  coreutils
  curl
  evince
  fastfetch
  ffmpeg jq imagemagick chafa
  file
  fish
  fzf
  gawk
  git
  lazygit
  glow
  gnupg
  lsb-release
  luarocks
  make
  man-db
  ripgrep
  rsync
  socat net-tools lsof
  stow
  strace nmap
  sudo
  texinfo
  tk gnuplot sysstat
  tmux
  tree
  unzip zip
  vim
  wget
  which
  xclip
  zoxide
  zsh
  zsh-syntax-highlighting zsh-autosuggestions
)

# ==========================================================
# Install packages based on distribution
# ==========================================================
if [ "$DISTRO" = "arch" ]; then
  echo "Installing packages for Arch Linux..."

  # Update system and install common + Arch-specific packages
  sudo pacman -Syu --noconfirm \
    "${COMMON_PACKAGES[@]}" \
    base-devel \
    devtools postgresql-libs \
    lynx \
    jsoncpp jsoncpp-doc \
    ninja qt6-base qt6-5compat alsa-lib gettext \
    lazygit \
    jless \
    git-delta \
    zsh-doc \
    libxkbcommon-x11 wayland waypipe \
    ctags \
    openssh \
    iproute2 iputils \
    netcat \
    cronie \
    tectonic \
    docker docker-buildx docker-compose \
    github-cli \
    fd \
    poppler poppler-data \
    ueberzugpp \
    graphite graphite-docs \
    harfbuzz harfbuzz-utils \
    dav1d dav1d-doc \
    rrdtool \
    valkey \
    vulkan-driver \
    freeglut \
    libnotify \
    opengl-man-pages \
    gdk-pixbuf2 gimp java-runtime \
    libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader \
    python-setuptools python-keyring python-xdg python python-pip python-pipx \
    lua \
    gtk4 gtk4-layer-shell libadwaita \
    libjpeg-turbo libpng zlib \
    libva-mesa-driver libvdpau-va-gl \
    opencl-driver \
    fftw-openmpi libusb libdecor \
    mesa libnss_nis libxss libxtst \
    xorg-xauth xorg-server-xvfb \
    libxcb \
    libevent ncurses bison pkgconf

  # Clean cache for unused packages
  # sudo pacman -Sc --noconfirm

elif [ "$DISTRO" = "ubuntu" ]; then
  echo "Installing packages for Ubuntu..."

  # Setup repositories
  setup_ubuntu_repositories

  # Update system and install common + Ubuntu-specific packages
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y \
    "${COMMON_PACKAGES[@]}" \
    build-essential \
    devscripts libpq-dev \
    infisical \
    hcp \
    lynx \
    libjsoncpp-dev libjsoncpp-doc \
    ninja-build qt6-base-dev qt6-5compat-dev libasound2-dev gettext \
    git-delta \
    zsh-doc \
    libxkbcommon-x11-0 libwayland-client0 waypipe \
    exuberant-ctags \
    openssh-client openssh-server \
    iproute2 iputils-ping \
    netcat-openbsd \
    cron \
    docker.io docker-buildx docker-compose \
    gh \
    fd-find \
    poppler-utils poppler-data \
    harfbuzz-utils \
    librrd-dev \
    vulkan-tools \
    freeglut3-dev \
    libnotify-bin \
    libgdk-pixbuf2.0-dev gimp default-jre \
    libwmf-dev libopenraw-dev libavif-dev libheif-dev libjxl-dev librsvg2-dev \
    python3-setuptools python3-keyring python3-xdg python3 python3-pip python3-pipx \
    lua5.4 \
    libgtk-4-dev libadwaita-1-dev libxml2-utils \
    libjpeg-turbo8-dev libpng-dev zlib1g-dev \
    libva-drv-video libvdpau-va-gl1 \
    opencl-headers \
    libfftw3-mpi-dev libusb-1.0-0-dev \
    libgl1-mesa-dev libnss-nis libxss1 libxtst6 \
    xauth xvfb \
    libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev \
    libevent-dev libncurses-dev bison pkgconf

  # Install tectonic via official installer.
  if ! command -v tectonic &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
    sudo mv tectonic /usr/local/bin/
  fi

  # Clean apt cache
  sudo apt-get autoremove -y
  sudo apt-get autoclean

fi

# ==========================================================
# Setup above packages and install related tools.
# ==========================================================
# Install `github-cli` extension: `Copilot`.
if command -v gh &>/dev/null; then
  gh extension install github/gh-copilot
fi

# Install luasocket.
if command -v luarocks &>/dev/null; then
  sudo luarocks install luasocket
fi

# Install eza theme.
# eza uses the theme.yml file stored in $EZA_CONFIG_DIR, or if that is not defined then in $XDG_CONFIG_HOME/eza.
# Download theme repo as reference, but do not symlink $EZA_CONFIG_DIR/theme to it,
# instead just keep own theme from dotfiles sync.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"
git clone https://github.com/eza-community/eza-themes.git "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"

# Install eza completions.
# `eza` software itself is installed with `cargo`.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza"
git clone https://github.com/eza-community/eza.git "${EZA_HOME:-$HOME/.local/share/eza}/eza"

# Manually install tmux plugins, including tmux plugin manager.
rm -rf "${TMUX_HOME:-$HOME/.config/tmux}/plugins"
git clone https://github.com/tmux-plugins/tpm "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tpm"
git clone -b v2.1.1 https://github.com/catppuccin/tmux.git "${TMUX_HOME:-$HOME/.config/tmux}/plugins/catppuccin/tmux"
git clone https://github.com/tmux-plugins/tmux-battery "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-battery"
git clone https://github.com/tmux-plugins/tmux-cpu "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-cpu"

# Clean up functions
unset -f detect_distro
unset -f setup_ubuntu_repositories

echo "Package installation completed for $DISTRO!"
