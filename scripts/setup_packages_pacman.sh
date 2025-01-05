#!/usr/bin/env bash

echo "Running setup_packages_pacman.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Stop snapd service if it is running, so it can be upgraded.
systemctl --quiet is-active snapd.service && sudo service snapd stop

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
sudo pacman -Syup --noconfirm \
  base-devel \
  sudo \
  curl \
  wget \
  stow \
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
  zsh zsh-completions zsh-doc \
  iputils \
  jless \
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
  github-cli \
  yazi ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick \
  sysstat \
  python python-pip python-pipx \
  lua \
  ninja gettext \
  gtk4 libadwaita \
  libjpeg-turbo libpng zlib \
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
sudo pacman -Sc
