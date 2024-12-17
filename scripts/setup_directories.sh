#!/usr/bin/env bash

echo "Running setup_directories.sh"

LINUXBREW_HOME="/home/linuxbrew/.linuxbrew"
if [ ! -d $LINUXBREW_HOME ]; then
  mkdir -p $LINUXBREW_HOME
  # chown -R $USERNAME:$USERNAME $linuxbrew_home
fi

BUN_INSTALL="/home/$USERNAME/.bun"
if [ ! -d "$BUN_INSTALL" ]; then
  mkdir -p "$BUN_INSTALL"
fi

NVM_DIR="/home/$USERNAME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  mkdir -p "$NVM_DIR"
fi

PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
if [ ! -d "$PNPM_HOME" ]; then
  mkdir -p "$PNPM_HOME"
fi

FONT_HOME="/home/$USERNAME/.local/share/fonts"
if [ ! -d "$FONT_HOME" ]; then
  mkdir -p "$FONT_HOME"
fi

STARSHIP_HOME="$XDG_CONFIG_HOME/starship"
if [ ! -d "$STARSHIP_HOME" ]; then
  mkdir -p "$STARSHIP_HOME"
fi

WEZTERM_HOME="/home/$USERNAME/.local/share/wezterm"
if [ ! -d "$WEZTERM_HOME" ]; then
  mkdir -p "$WEZTERM_HOME"
fi

NVIM_HOME="$XDG_CONFIG_HOME/nvim"
# Let git make the folder.
# if [ ! -d "$NVIM_HOME" ]; then
#   mkdir -p "$NVIM_HOME"
# fi

YAZI_HOME="$XDG_CONFIG_HOME/yazi"
if [ ! -d "$YAZI_HOME" ]; then
  mkdir -p "$YAZI_HOME"
fi

ZSH_HOME="/home/$USERNAME/.local/share/zsh"
if [ ! -d "$ZSH_HOME" ]; then
  mkdir -p "$ZSH_HOME"
fi

ZSH="$ZSH_HOME/oh-my-zsh"
# Do not pre-create $ZSH directory, otherwise oh-my-zsh will complain.
# if [ ! -d "$ZSH" ]; then
#   mkdir -p "$ZSH"
# fi

EZA_HOME="/home/$USERNAME/.local/share/eza"
if [ ! -d "$EZA_HOME" ]; then
  mkdir -p "$EZA_HOME"
fi

EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
if [ ! -d "$EZA_CONFIG_DIR" ]; then
  mkdir -p "$EZA_CONFIG_DIR"
fi

TRASH_HOME="/home/$USERNAME/.local/share/Trash"
if [ ! -d "$TRASH_HOME" ]; then
  mkdir -p "$TRASH_HOME"
fi

VIM_SESSIONS="/home/$USERNAME/.vim/sessions"
if [ ! -d "$VIM_SESSIONS" ]; then
  mkdir -p "$VIM_SESSIONS"
fi

# For trash-cli completion.
sudo mkdir -p "/usr/share/zsh/site-functions/"
sudo chown 1000:1000 "/usr/share/zsh/site-functions/"
sudo mkdir -p "/usr/share/bash-completion/completions"
sudo chown 1000:1000 "/usr/share/bash-completion/completions"
sudo mkdir -p "/etc/profile.d"
sudo chown 1000:1000 "/etc/profile.d"

RUST_HOME="/home/$USERNAME/.rustup"
if [ ! -d "$RUST_HOME" ]; then
  mkdir -p "$RUST_HOME"
fi

CARGO_HOME="/home/$USERNAME/.cargo"
if [ ! -d "$CARGO_HOME" ]; then
  mkdir -p "$CARGO_HOME"
fi

TMUX_HOME="$XDG_CONFIG_HOME/tmux"
if [ ! -d "$TMUX_HOME" ]; then
  mkdir -p "$TMUX_HOME"
fi

COMMAND_HISTORY_DIR="/commandhistory"
if [ ! -d "$COMMAND_HISTORY_DIR" ]; then
  sudo mkdir -p "$COMMAND_HISTORY_DIR"
  sudo touch /commandhistory/.shell_history
fi
