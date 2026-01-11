# Project Overview

This repository contains a comprehensive set of dotfiles for configuring a development environment. It uses `stow` to manage symlinks to configuration files and a collection of shell scripts to automate the setup process on a new machine. The setup is designed to be flexible and supports different environments, including native Linux, Docker containers, and OrbStack.

The primary user is `nfu`, and the setup scripts are designed to create this user and configure the environment for it.

## Key Technologies and Tools

*   **Shell:** Zsh, configured with `oh-my-zsh` and various plugins.
*   **Terminal:** Wezterm, Ghostty
*   **Editor:** Neovim, with a custom configuration.
*   **Package Managers:** `pacman` (Arch Linux), `apt` (Ubuntu), `snap`, `cargo` (Rust), `pip` (Python), `pnpm` (Node.js).
*   **Window Manager:** Hyprland
*   **Dotfile Management:** `stow`
*   **Containerization:** Docker

## Building and Running

The main entry point for setting up the environment is the `scripts/bootstrap.sh` script. This script can be run in different ways depending on the target environment.

### Native Linux Setup

1.  Clone the repository: `git clone git@github.com:magnusriga/dotfiles.git "$HOME"/dotfiles`
2.  Run the bootstrap script: `. ~/dotfiles/scripts/bootstrap.sh`

This will create the `nfu` user and set up the environment.

### Docker Setup

1.  Build and access the container: `. ~/dotfiles/host/docker/manage-container.sh -b`
2.  Re-access the container: `ssh nfu-docker`

## Development Conventions

*   **Dotfile Management:** All dotfiles are managed using `stow`. Configuration files for different applications are organized into subdirectories within the `stow` directory.
*   **Shell Configuration:** The shell environment is configured through a set of files in `stow/shell`, including `.aliases`, `.functions`, and `.zshenv`.
*   **Package Management:** The `scripts/setup_packages.sh` script handles the installation of packages from various sources.
*   **Idempotency:** The setup scripts are designed to be idempotent, meaning they can be run multiple times without causing issues.
*   **Modularity:** The setup process is broken down into smaller, modular scripts, making it easier to manage and customize.
