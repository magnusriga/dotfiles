#!/usr/bin/env bash

echo "Running setup_apt-get_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Stop snapd service if it is running, so it can be upgraded.
systemctl --quiet is-active snapd.service && sudo service snapd stop

# ==========================================================
# Add repositories to apt.
# ==========================================================
# GitHub CLI (for package `gh`).
(type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

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
  unzip zip \
  git \
  gawk \
  xclip \
  autoconf \
  texinfo \
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
  poppler-utils \
  build-essential \
  fd-find \
  sysstat \
  python3 \
  python3-pip \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libxtst6 xauth xvfb \
  libxcb-shape0-dev libxcb-xfixes0-dev libxcb1-dev \
  libevent-dev ncurses-dev bison pkg-config

# Package clean-up.
sudo apt autoremove
sudo rm -rf /var/lib/apt/lists/*
