#!/usr/bin/env bash

echo "Running setup_packages.sh as $(whoami), with HOME $HOME and USER $USER."

# ==========================================================
# Detect Linux distribution
# ==========================================================
function detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    # Handle Arch Linux ARM which has ID=archarm but ID_LIKE=arch.
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

# ==========================================================
# Check Ubuntu version for conditional package installation
# ==========================================================
function check_ubuntu_version() {
  local required_major="$1"
  local required_minor="$2"

  if [ "$DISTRO" = "ubuntu" ] && [ -f /etc/os-release ]; then
    . /etc/os-release
    # Extract major and minor version numbers.
    # shellcheck disable=SC2153
    local version_id="$VERSION_ID"
    local major_version
    local minor_version
    major_version=$(echo "$version_id" | cut -d'.' -f1)
    minor_version=$(echo "$version_id" | cut -d'.' -f2)

    # Check if version meets requirement.
    if [ "$major_version" -gt "$required_major" ] || { [ "$major_version" -eq "$required_major" ] && [ "$minor_version" -ge "$required_minor" ]; }; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "false"
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

  # Ensure `~/.gnupg` directory is owned by user executing below commands, i.e. root.
  # sudo chown -R root:root "$HOME"/.gnupg

  # Stop snapd service if it is running, so it can be upgraded.
  if [ ! -f /.dockerenv ] && [ -z "$DOCKER_BUILD" ]; then
    systemctl --quiet is-active snapd.service && sudo service snapd stop
  fi

  # Create public key directory.
  sudo mkdir -p -m 755 /etc/apt/keyrings

  # GitHub CLI (for package `gh`).
  (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) &&
    out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
    sudo cp "$out" /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  # glow.
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null

  # fastfetch.
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch

  # Infisical CLI.
  curl -1sLf 'https://artifacts-cli.infisical.com/setup.deb.sh' | sudo -E bash

  # HashiCorp HCP CLI.
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg --yes
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

  # Docker Engine (following https://docs.docker.com/engine/install/ubuntu/)
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

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
  glow
  gnupg
  # lazygit
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

  # Update system and install common + Arch-specific packages.
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
    ttf-font-awesome \
    ttf-jetbrains-mono-nerd \
    ttf-cascadia-code-nerd \
    hyprland hyprpaper hypridle hyprlock \
    hyprshot hyprpicker \
    nwg-look \
    waybar \
    wofi \
    swaync \
    kitty \
    nautilus \
    firefox \
    brightnessctl \
    pavucontrol \
    nwg-displays \
    network-manager-applet \
    pasystray \
    wl-clipboard \
    cliphist \
    mpv \
    file-roller \
    netcat \
    cronie \
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
    redis \
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

  # Clean cache for unused packages.
  # sudo pacman -Sc --noconfirm

elif [ "$DISTRO" = "ubuntu" ]; then
  echo "Installing packages for Ubuntu..."

  # Modernize package sources.
  sudo apt -y modernize-sources

  # Update local package list with latest information about
  # available packages and their versions from configured repositories,
  # then upgrade installed packages.
  sudo apt-get update && sudo apt-get upgrade -y

  # Install packages needed to update repositories.
  sudo apt-get install -y gnupg wget curl software-properties-common apt-transport-https ca-certificates

  # Setup repositories.
  setup_ubuntu_repositories

  # Check Ubuntu version for conditional packages.
  UBUNTU_24_10_OR_LATER=$(check_ubuntu_version 24 10)
  UBUNTU_25_10_OR_LATER=$(check_ubuntu_version 25 10)

  # Update system and install common + Ubuntu-specific packages.
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
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    gh \
    snapd \
    fd-find \
    poppler-utils poppler-data \
    libharfbuzz-bin \
    librrd-dev \
    redis-tools \
    vulkan-tools \
    freeglut3-dev \
    libnotify-bin \
    libgdk-pixbuf2.0-dev gimp default-jre \
    libwmf-dev libopenraw-dev libavif-dev libheif-dev libjxl-dev librsvg2-dev \
    python3-setuptools python3-keyring python3-xdg python3 python3-pip pipx \
    lua5.4 \
    libgtk-4-dev libadwaita-1-dev libxml2-utils \
    libjpeg-turbo8-dev libpng-dev zlib1g-dev \
    va-driver-all vainfo libvdpau-va-gl1 \
    opencl-headers \
    libfftw3-mpi-dev libusb-1.0-0-dev \
    libgl1-mesa-dev libnss-nis libxss1 libxtst6 \
    xauth xvfb \
    libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev \
    libevent-dev libncurses-dev bison pkgconf

  # Install libgtk4-layer-shell-dev on Ubuntu 24.10 or later
  if [ "$UBUNTU_24_10_OR_LATER" = "true" ]; then
    echo "Ubuntu 24.10 or later, installing libgtk4-layer-shell-dev."
    sudo apt-get install -y libgtk4-layer-shell-dev
  else
    echo "Skipping libgtk4-layer-shell-dev, requires Ubuntu 24.10 or later."
  fi

  # Install lazygit on Ubuntu 25.10 or later
  if [ "$UBUNTU_25_10_OR_LATER" = "true" ]; then
    echo "Ubuntu 25.10 or later, installing lazygit."
    sudo apt-get install -y lazygit
  else
    echo "Skipping lazygit, requires Ubuntu 25.10 or later."
  fi

  # Clean apt cache.
  sudo apt-get autoremove -y
  sudo apt-get autoclean
fi

# Clean up functions.
unset -f detect_distro
unset -f setup_ubuntu_repositories
unset -f check_ubuntu_version

echo "Package installation completed for $DISTRO!"
