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

# FROM archlinux:latest AS builder
FROM menci/archlinuxarm AS builder
# FROM mcr.microsoft.com/devcontainers/universal
# FROM mcr.microsoft.com/devcontainers/javascript-node

# Prevent dialog during apt install
# ENV DEBIAN_FRONTEND noninteractive

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
# Setup pacman and install initial packages.
# ================================================
# Replace pacman.conf with custom one, e.g. to disable sandboxing,
# which does not work on ARM version of Arch Linux.
RUN rm -f /etc/pacman.conf
COPY host/docker/pacman.conf /etc/pacman.conf

# Setup pacman keyring and populate it.
RUN pacman-key --init && pacman-key --populate archlinux

# Install sudo and git, needed for initial setup.
RUN pacman -Syu --noconfirm sudo git glibc-locales

# ================================================
# Install Docker Compose.
# ================================================
RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
  && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# ================================================
# Create new group and user, and add user to sudoers file.
# ================================================
ARG USERNAME=nfu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

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
# Switch to new, non-root, user for rest of setup.
# ================================================
USER $USERNAME

# ================================================
# Set environment variables
# ================================================
ENV USER=$USERNAME
ENV DOCKER_BUILD=1

# ================================================
# Setup: Locale.
# ================================================
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# ================================================
# Create dotfiles directory and run bootstrap with bind mount
# ================================================
RUN mkdir -p /home/$USERNAME/dotfiles && \
  chown $USERNAME:$USERNAME /home/$USERNAME/dotfiles

WORKDIR /home/$USERNAME/dotfiles

# Run bootstrap script with bind mount to access full git repo
RUN --mount=type=bind,source=.,target=/home/$USERNAME/dotfiles,rw \
  chmod +x scripts/bootstrap.sh && \
  ./scripts/bootstrap.sh --force && \
  echo "Bootstrap completed successfully"

# ================================================
# Bootstrap script handles all tool installation and PATH setup
# ================================================

# ================================================
# Container entrypoint and CMD
# ================================================

COPY --chmod=0755 host/docker/docker-init.sh "/usr/local/share/"
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
