#!/usr/bin/env bash

echo "Running setup_apt-get_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Stop snapd service if it is running, so it can be upgraded.
systemctl --quiet is-active snapd.service && sudo service snapd stop

# ==========================================================
# Add repositories to apt.
# ==========================================================
# Create public key directory.
sudo mkdir -p -m 755 /etc/apt/keyrings

# GitHub CLI (for package `gh`).
(type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# glow.
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null

# fastfetch.
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch

# ==========================================================
# Install packages.
# ==========================================================
sudo apt-get update
sudo apt-get install -y \
  locales \
  sudo \
  curl \
  wget \
  pipx \
  snapd \
  make \
  cmake \
  unzip zip \
  git \
  gawk \
  xclip \
  autoconf \
  texinfo \
  man-db \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  lsb-release \
  zsh zsh-common zsh-doc \
  iputils-ping \
  vim \
  tmux \
  file \
  ssh \
  iproute2 \
  rsync \
  cron \
  gpg \
  bat \
  tree \
  jq \
  gh \
  libpoppler-dev \
  poppler-utils \
  build-essential \
  libssl-dev \
  fd-find \
  sysstat \
  python-dev python-pip python3-dev \
  python3 \
  python3-pip \
  ffmpeg \
  imagemagick \
  glow \
  ninja-build gettext \
  libjpeg-dev libpng-dev zlib1g libavcodec-dev libavformat-dev libavfilter-dev \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libxtst6 xauth xvfb \
  libxcb-shape0-dev libxcb-xfixes0-dev libxcb1-dev \
  libevent-dev ncurses-dev bison pkg-config

# Package clean-up.
sudo apt autoremove
sudo rm -rf /var/lib/apt/lists/*
