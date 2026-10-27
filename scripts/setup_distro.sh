#!/usr/bin/env bash

# ==========================================================
# Detect Linux distribution and export it as `DISTRO`.
# - Values: `arch` or `ubuntu`.
# - Sourced first by `setup_main.sh`, so every later setup script
#   can branch on `$DISTRO` instead of probing `/etc/*-release` itself.
# - Also sourced by `setup_packages.sh`, which runs standalone in Docker builds.
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

DISTRO=$(detect_distro)
export DISTRO
unset -f detect_distro
