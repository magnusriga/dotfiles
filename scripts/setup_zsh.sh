#!/usr/bin/env bash

echo "Running setup_zsh.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ================================================
# Install ZLE widgets and ZSH plugins.
# ================================================
# `zsh-autosuggestions` and `zsh-syntax-highlighting`:
# - Installed with the package manager on every distro (`setup_packages.sh`),
#   sourced from the package path in `.zshrc`.

# `zsh-autocomplete`.
# - Not used, interferes too much with ZLE's built-in vi mode.
# rm -rf ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete
# git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"

# `zsh-completions`.
# - Arch: `pacman` installs into `/usr/share/zsh/site-functions`, already in `fpath`.
# - Ubuntu: Cloned into `ZSH_HOME`, added to `fpath` in `.zshrc`.
if [ "$DISTRO" != "arch" ]; then
  ZSH_COMPLETIONS_DIR="${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions"
  if [ -d "$ZSH_COMPLETIONS_DIR/.git" ]; then
    git -C "$ZSH_COMPLETIONS_DIR" pull --ff-only
  else
    rm -rf "$ZSH_COMPLETIONS_DIR"
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_COMPLETIONS_DIR"
  fi
  unset ZSH_COMPLETIONS_DIR
fi

# `zsh-vi-mode`.
# - No need, ZLE built-in keybindings are sufficient.
# rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode"
# git clone https://github.com/jeffreytse/zsh-vi-mode.git ${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode
