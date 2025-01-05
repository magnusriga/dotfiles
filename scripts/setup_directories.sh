#!/usr/bin/env bash

echo "Running setup_directories.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Set needed environment variables.
export XDG_CONFIG_HOME="/home/$USERNAME/.config"

export LINUXBREW_HOME="/home/linuxbrew/.linuxbrew"
if [ ! -d $LINUXBREW_HOME ]; then
  sudo mkdir -p $LINUXBREW_HOME
fi

export BUN_INSTALL="/home/$USERNAME/.bun"
if [ ! -d "$BUN_INSTALL" ]; then
  mkdir -p "$BUN_INSTALL"
fi

export NVM_DIR="/home/$USERNAME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  mkdir -p "$NVM_DIR"
fi

export PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
if [ ! -d "$PNPM_HOME" ]; then
  mkdir -p "$PNPM_HOME"
fi

export FONT_HOME="/home/$USERNAME/.local/share/fonts"
if [ ! -d "$FONT_HOME" ]; then
  mkdir -p "$FONT_HOME"
fi

export STARSHIP_HOME="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/starship"
if [ ! -d "$STARSHIP_HOME" ]; then
  mkdir -p "$STARSHIP_HOME"
fi

export AEROSPACE_HOME="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/aerospace"
if [ ! -d "$AEROSPACE_HOME" ]; then
  mkdir -p "$AEROSPACE_HOME"
fi

export WEZTERM_HOME="/home/$USERNAME/.local/share/wezterm"
if [ ! -d "$WEZTERM_HOME" ]; then
  mkdir -p "$WEZTERM_HOME"
fi

export NVIM_HOME="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/nvim"
# Let git make the folder.
# if [ ! -d "$NVIM_HOME" ]; then
#   mkdir -p "$NVIM_HOME"
# fi

export YAZI_HOME="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/yazi"
if [ ! -d "$YAZI_HOME" ]; then
  mkdir -p "$YAZI_HOME"
fi

export ZSH_HOME="/home/$USERNAME/.local/share/zsh"
if [ ! -d "$ZSH_HOME" ]; then
  mkdir -p "$ZSH_HOME"
fi

export ZSH="$ZSH_HOME/oh-my-zsh"
# Do not pre-create $ZSH directory, otherwise oh-my-zsh will complain.
# if [ ! -d "$ZSH" ]; then
#   mkdir -p "$ZSH"
# fi

export EZA_HOME="/home/$USERNAME/.local/share/eza"
if [ ! -d "$EZA_HOME" ]; then
  mkdir -p "$EZA_HOME"
fi

export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/eza"
if [ ! -d "$EZA_CONFIG_DIR" ]; then
  mkdir -p "$EZA_CONFIG_DIR"
fi

export TRASH_HOME="/home/$USERNAME/.local/share/Trash"
if [ ! -d "$TRASH_HOME" ]; then
  mkdir -p "$TRASH_HOME"
fi

export VIM_SESSIONS="/home/$USERNAME/.vim/sessions"
if [ ! -d "$VIM_SESSIONS" ]; then
  mkdir -p "$VIM_SESSIONS"
fi

export GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
if [ ! -d "$GNUPGHOME" ]; then
  mkdir -p "$GNUPGHOME"
fi

export BUILD_HOME="${BUILD_HOME=:-$HOME/build}"
if [ ! -d "$BUILD_HOME" ]; then
  mkdir -p "$BUILD_HOME/repositories"
  mkdir -p "$BUILD_HOME/packages"
  mkdir -p "$BUILD_HOME/sources"
fi

# For `makepkg` configuration: `$HOME/.config/pacman/makepkg.conf`.
# Pacman configuration must be placed separately in: `/etc/pacman.conf`.
export PACMAN_HOME="${PACMAN_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/pacman}"
if [ ! -d "$PACMAN_HOME" ]; then
  mkdir -p "$PACMAN_HOME"
fi

# For trash-cli completion.
sudo mkdir -p "/usr/share/zsh/site-functions/"
sudo chown $(id -u $USERNAME):$(id -g $USERNAME) "/usr/share/zsh/site-functions/"
sudo mkdir -p "/usr/share/bash-completion/completions"
sudo chown $(id -u $USERNAME):$(id -g $USERNAME) "/usr/share/bash-completion/completions"
sudo mkdir -p "/etc/profile.d"
sudo chown $(id -u $USERNAME):$(id -g $USERNAME) "/etc/profile.d"

export RUST_HOME="/home/$USERNAME/.rustup"
if [ ! -d "$RUST_HOME" ]; then
  mkdir -p "$RUST_HOME"
fi

export CARGO_HOME="/home/$USERNAME/.cargo"
if [ ! -d "$CARGO_HOME" ]; then
  mkdir -p "$CARGO_HOME"
fi

export TMUX_HOME="${XDG_CONFIG_HOME:-/home/$USERNAME/.config}/tmux"
if [ ! -d "$TMUX_HOME" ]; then
  mkdir -p "$TMUX_HOME"
fi

export COMMAND_HISTORY_DIR="/commandhistory"
if [ ! -d "$COMMAND_HISTORY_DIR" ]; then
  sudo mkdir -p "$COMMAND_HISTORY_DIR"
  sudo touch $COMMAND_HISTORY_DIR/.shell_history
fi
