#!/usr/bin/env bash

echo "Running setup_packages_pacman.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Stop snapd service if it is running, so it can be upgraded.
# systemctl --quiet is-active snapd.service && sudo service snapd stop

# ==========================================================
# Copy `pacman.conf` to `/etc`, so it is used by `pacman`.
# Cannot `stow`, it is installed later.
# ==========================================================
ROOTPATH="$( cd -- "$(dirname "${BASH_SOURCE}")/.." >/dev/null 2>&1 ; pwd -P )"
sudo rm -f /etc/pacman.conf
sudo ln -s "${ROOTPATH}/.system/pacman.conf" /etc

# ==========================================================
# Set locale.
# ==========================================================
sudo localectl set-locale LANG=en_US.UTF-8
unset LANG
source /etc/profile.d/locale.sh

# ==========================================================
# Add repositories to apt.
# ==========================================================
# Create public key directory.
# sudo mkdir -p -m 755 /etc/apt/keyrings

# GitHub CLI (for package `gh`).
# (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) \
#   && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
#   && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
#   && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
#   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# glow.
# curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null

# fastfetch.
# sudo add-apt-repository ppa:zhangsongcui3371/fastfetch

# ==========================================================
# Default locations, defined in `/etc/pacman.conf`.
# ==========================================================
# Root      : /
# Conf File : /etc/pacman.conf
# DB Path   : /var/lib/pacman/
# Cache Dirs: /var/cache/pacman/pkg/
# Hook Dirs : /usr/share/libalpm/hooks/  /etc/pacman.d/hooks/
# Lock File : /var/lib/pacman/db.lck
# Log File  : /var/log/pacman.log
# GPG Dir   : /etc/pacman.d/gnupg/
# Targets   : None

# ==========================================================
# Install packages.
# ==========================================================
# - `-y`, `--refresh`:
#   - Download fresh copy of master package databases (repo.db),
#     from server(s) defined in pacman.conf(5).
#   - Should be used each time `-u`, `--sysupgrade` is used.
#   - Passing two `--refresh` or `-y` flags will force refresh of all package databases,
#     even if they appear to be up-to-date.
#   `-u`, `--sysupgrade`:
#   - Upgrades all packages that are out-of-date.
#   - Each installed package will be examined and upgraded if newer package exists.
#   - Additional targets can also be specified manually, i.e. `-Su foo` will do system upgrade
#     and install/upgrade "foo" package in same operation.
# - Important:
#   - Never run `-Sy <pkg>` alone, without `-u`,
#     as it might install an old dependency from the sync database,
#     while local dependee package is updated to latest version,
#     thus causing conflict.
#   - `-Su <pkg>` alone, without `-y`, is OK, but probably not recommended,
#     as it would upgrade all packages locally, but might install an old package dependency.
# - Recommendation:
#   - Refresh master packages databases in `/var/lib/pacman/*`,
#     upgrade all out-of-date installed packages,
#     and install new packages, with: `pacman -Syu <pkg>`.
sudo pacman -Syu --noconfirm \
  base-devel btrfs-progs \
  devtools postgresql-libs \
  coreutils \
  sudo \
  curl \
  wget \
  stow \
  jsoncpp jsoncpp-doc \
  ninja qt6-base qt6-5compat alsa-lib gettext \
  make \
  cmake \
  unzip zip \
  git \
  lazygit \
  gawk \
  xclip \
  autoconf \
  texinfo \
  man-db \
  ca-certificates \
  gnupg \
  lsb-release \
  bash \
  zsh zsh-doc \
  zsh-completions zsh-syntax-highlighting zsh-autosuggestions \
  fish \
  iputils \
  libxkbcommon-x11 wayland \
  jless \
  ghostty ghostty-shell-integration \
  vim \
  neovim \
  tmux \
  file \
  openssh \
  iproute2 \
  rsync \
  cronie \
  bat \
  tree \
  glow \
  fastfetch neofetch \
  docker docker-buildx docker-compose \
  github-cli \
  fzf viu \
  zoxide \
  fd ripgrep \
  ffmpeg p7zip jq poppler poppler-data imagemagick chafa yazi \
  graphite graphite-docs \
  harfbuzz harfbuzz-utils \
  dav1d dav1d-doc \
  rrdtool \
  vulkan-driver \
  freeglut \
  opengl-man-pages \
  gdk-pixbuf2 gimp java-runtime \
  libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader \
  tk gnuplot sysstat \
  python-setuptools python-keyring python-xdg python python-pip python-pipx \
  lua luarocks \
  evince gtk4 libadwaita \
  libjpeg-turbo libpng zlib \
  intel-media-driver libva-intel-driver libva-mesa-driver libvdpau-va-gl \
  nvidia-utils opencl-driver \
  intel-media-sdk vpl-gpu-rt \
  fftw-openmpi libusb libdecor \
  mesa libnss_nis libxss libxtst \
  xorg-xauth xorg-server-xvfb \
  libxcb \
  libevent ncurses bison pkgconf

# ==========================================================
# Clean cache for unused packages and sync databases
# ==========================================================
# Remove all cached packages that are not currently installed,
# as well as unused sync databases, in cache directory,
# which by default is: `/var/cache/pacman/pkg/`.
# - Remove packages no longer installed from cache,
#   as well as currently unused sync databases.
# - When pacman downloads packages, it saves them in cache directory.
# - In addition, databases are saved for every sync DB downloaded from
#   and are not deleted even if they are removed from configuration file pacman.conf(5).
# - Use one `--clean` switch to only remove packages that are no longer installed;
#   use two to remove all files from the cache.
# - In both cases, you will have `yes` | `no` option to remove packages
#   and/or unused downloaded databases.
sudo pacman -Sc --noconfirm

# ==========================================================
# Setup above packages and install related tools.
# ==========================================================
# Install luzsocket.
sudo luarocks install luasocket
# lua require "socket"

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
