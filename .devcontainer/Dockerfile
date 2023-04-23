# Do not use vscode versions, the ones without are newer

# IMAGES FOR GITHUB CODESPACES
# ================================
# Alt 1: mcr.microsoft.com/devcontainers/universal
# Alt 2: mcr.microsoft.com/devcontainers/javascript-node

# OTHER IMAGES (see: Docker Hub)
# ================================
# Images specified without specific url are downloaded from Docker Hub, if not found locally.
# 1) node:latest
# 2) cypress:included
# And many others. Full list: https://hub.docker.com

FROM ubuntu:latest
# FROM mcr.microsoft.com/devcontainers/universal
# FROM mcr.microsoft.com/devcontainers/javascript-node

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

# Replace shell with bash so we can source files
# Comma-separated arguments to launch of bash shell
# -l (login-shell), -e (exit when command fails), -o pipefall (set exit code to right-most command to exit with non-zero status)
# -u (unset variables treated as error), -x (print each command before executing it)
SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]

# Install packages.
# git is needed, and the lib packages are needed for Cypress.
# For Homebrew, ruby-full must be installed.
# Perhaps good to update curl and build-essentials too.
RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
    git \
    sudo \
    file \
    curl \
    wget \
    ssh \
    rsync \
    gpg \
    locales \
    ca-certificates \
    build-essential \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 xauth xvfb \
    ruby-full && \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Name of non-root user
ENV USER_NAME magnus

# Create new non-root user and group of same name, but do not switch to it yet.
RUN useradd -m $USER_NAME && echo $USER_NAME:$USER_NAME | chpasswd && usermod -aG sudo $USER_NAME

# Make it so we do not have to enter in password when using sudo.
RUN echo '$USER_NAME ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create Homebrew dir and change owner from root to $USER_NAME.
# The directory must be "linuxbrew", as that's where curl-downloaded script installs it.
# Note order of commands: Root changes owner of folder.
RUN mkdir -p /home/linuxbrew/.linuxbrew
RUN chown -R $USER_NAME:$USER_NAME /home/linuxbrew/.linuxbrew

# Folder we want nvm repo cloned to,
# and where nvm.sh script is run from (which installs node).
ENV NVM_DIR="/home/$USER_NAME/.nvm"

# Create dir we want NVM in, and let root change owner of folder.
RUN mkdir -p $NVM_DIR
RUN chown -R $USER_NAME:$USER_NAME $NVM_DIR

# Needed for some locale issue
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
# ENV LANG en_US.utf-8
# ENV LC_ALL en_US.utf-8

# Done with root tasks, switch to non-root user for security purposes.
USER $USER_NAME

# Download and install Homebrew.
RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# Add Homebrew bin (brew) to path.
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Download and install nvm, node, npm.
# 1) Clones the nvm repository to ~/.nvm.
# 2) Tries to run nvm.sh
# 3) Copies all of it to the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc)
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Install nvm and node.
# All nvm commands must have .nvm.sh run in same RUN command,
# otherwise it won't find the binaries it needs.
# NVM install should have been done by NVM script from curl,
# but for some reason it does not, so we must do it manually.
ENV NODE_VERSION=20
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && npm install -g turbo pnpm
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Print package versions.
# nvm, npm must be called in same RUN as nvm.sh, to access the shell variables set there.
RUN node --version
RUN npm --version

# Print tool versions
RUN bash --version | head -n 1
RUN git --version
RUN curl --version
RUN wget --version
