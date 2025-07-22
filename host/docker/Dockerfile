# syntax=docker/dockerfile:1
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

# ================================================
# Multi-distribution and multi-architecture support configuration.
# ================================================
ARG DISTRO=arch
ARG TARGETARCH
ARG ARCH_IMAGE_AMD64=archlinux:latest
ARG ARCH_IMAGE_ARM64=menci/archlinuxarm
ARG UBUNTU_IMAGE=ubuntu:devel

# ================================================
# Stage 1: Build environment with dotfiles.
# ================================================
FROM ${ARCH_IMAGE_AMD64} AS arch-base-amd64
FROM ${ARCH_IMAGE_ARM64} AS arch-base-arm64
FROM ${UBUNTU_IMAGE} AS ubuntu-base-amd64
FROM ${UBUNTU_IMAGE} AS ubuntu-base-arm64

FROM arch-base-${TARGETARCH} AS arch-base
FROM ubuntu-base-${TARGETARCH} AS ubuntu-base

FROM ${DISTRO}-base AS builder

# Re-declare ARG after FROM to make it available in this stage.
ARG DISTRO=arch

# Prevent dialog during apt install (Ubuntu only)
ENV DEBIAN_FRONTEND=noninteractive

# The below will replace the shell used when running this Dockerfile,
# from ["/bin/sh", "-c"] to ["bin/bash", ...], so we can source files.
# Comma-separated arguments to launch of bash shell:
# -l (login-shell)
# -e (exit when command fails)
# -u (unset variables treated as error, do NOT include this)
# -x (print each command before executing it)
# -o pipefall (set exit code to right-most command to exit with non-zero status)
# Took -l and -u out, as they caused issues with the Docker setup.
# SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]
SHELL ["/bin/bash", "-exo", "pipefail", "-c" ]

# ================================================
# Distribution-specific initial setup.
# ================================================
COPY host/docker/pacman.conf /tmp/pacman.conf

# Install base packages needed for setup
RUN set -ex; \
  if [ "$DISTRO" = "arch" ]; then \
  rm -f /etc/pacman.conf && \
  cp /tmp/pacman.conf /etc/pacman.conf && \
  pacman-key --init && \
  pacman-key --populate archlinux && \
  pacman -Syu --noconfirm sudo git glibc-locales openssh curl; \
  elif [ "$DISTRO" = "ubuntu" ]; then \
  apt-get update && \
  apt-get install -y sudo git locales openssh-server curl unminimize && \
  locale-gen en_US.UTF-8 && \
  yes | unminimize && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*; \
  else \
  echo "Error: DISTRO variable not set or unsupported value: $DISTRO" && \
  exit 1; \
  fi

# ================================================
# Install Docker Compose.
# ================================================
RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
  && case "${TARGETARCH}" in \
  "amd64") COMPOSE_ARCH="x86_64" ;; \
  "arm64") COMPOSE_ARCH="aarch64" ;; \
  *) COMPOSE_ARCH="$(uname -m)" ;; \
  esac \
  && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-${COMPOSE_ARCH}" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# ================================================
# Create new group and user, and add user to sudoers file.
# ================================================
ARG USERNAME=nfu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Check if UID/GID 1000 exist and change them to 2000 if they do.
RUN if getent passwd 1000 >/dev/null 2>&1; then \
  usermod -u 2000 $(getent passwd 1000 | cut -d: -f1); \
  fi \
  && if getent group 1000 >/dev/null 2>&1; then \
  groupmod -g 2000 $(getent group 1000 | cut -d: -f1); \
  fi

# Create new group, and new user within it.
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Update sudoers file so $USERNAME does not have to type password for sudo commands.
  && echo "User_Alias ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : FULLTIMERS = $USERNAME, %$USERNAME" >> "/etc/sudoers.d/$USERNAME" \
  && echo 'ADMIN, FULLTIMERS ALL = NOPASSWD: ALL' >> "/etc/sudoers.d/$USERNAME" \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Setting passwords to same as username, in case needed.
RUN echo 'root:root' | chpasswd; \
  echo "$USERNAME:$USERNAME" | chpasswd

# ================================================
# Configure SSH
# ================================================
RUN ssh-keygen -A && \
  sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# ================================================
# Switch to new, non-root, user for rest of setup.
# ================================================
USER $USERNAME

# ================================================
# Copy dotfiles directly to final location
# ================================================
COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/dotfiles/

# ================================================
# Setup SSH known_hosts for common Git providers
# ================================================
RUN mkdir -p -m 0700 /home/$USERNAME/.ssh && \
  ssh-keyscan github.com >> /home/$USERNAME/.ssh/known_hosts && \
  ssh-keyscan gitlab.com >> /home/$USERNAME/.ssh/known_hosts && \
  ssh-keyscan bitbucket.org >> /home/$USERNAME/.ssh/known_hosts && \
  chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# ================================================
# Set environment variables
# ================================================
ENV USER=$USERNAME
ENV DISTRO=$DISTRO
# `DOCKER_BUILD=1`: Needed in setup scripts.
ENV DOCKER_BUILD=1
ENV SHELL=/bin/bash

# ================================================
# Setup: Locale.
# ================================================
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# ================================================
# Run package install scripts as root.
# ================================================
USER root

WORKDIR /home/$USERNAME/dotfiles

RUN --mount=type=ssh chmod +x ./scripts/setup_packages.sh && \
  echo "Running setup_packages.sh script as root, for $DISTRO..." && \
  ./scripts/setup_packages.sh && \
  echo "Completed running setup_packages.sh as root, for $DISTRO"

# ================================================
# Run remaining setup scripts as non-root user.
# ================================================
USER $USERNAME

RUN --mount=type=ssh chmod +x ./scripts/bootstrap.sh && \
  echo "Running bootstrap script for $DISTRO..." && \
  ./scripts/bootstrap.sh --force && \
  echo "Bootstrap completed successfully for $DISTRO" && \
  rm -rf /home/$USERNAME/dotfiles && \
  echo "Dotfiles cleaned up"

# ================================================
# Container entrypoint and CMD
# ================================================
COPY --chmod=0755 host/docker/docker-init.sh "/usr/local/share/"
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
