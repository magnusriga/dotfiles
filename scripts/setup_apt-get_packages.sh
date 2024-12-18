#!/usr/bin/env bash

echo "Running setup_apt-get_packages.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Stop snapd service if it is running, so it can be upgraded.
systemctl --quiet is-active snapd.service && sudo service snapd stop

# Install packages.
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
  xclip \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  lsb-release \
  zsh zsh-common zsh-doc \
  iputils-ping \
  vim \
  file \
  ssh \
  iproute2 \
  rsync \
  cron \
  python3-pip \
  gpg \
  bat \
  tree \
  jq \
  poppler-utils \
  build-essential \
  fd-find \
  sysstat \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libxtst6 xauth xvfb

# Package clean-up.
sudo rm -rf /var/lib/apt/lists/*
