#!/usr/bin/env bash

echo "Running setup_zsh.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ================================================
# Remove existing oh-my-zsh install folder,
# then install oh-my-zsh.
# ================================================
# If $ZSH folder is pre-created, oh-my-zsh complains.
# $ZSH is used by oh-my-zsh install script, as install directory for oh-my-zsh.
rm -rf "${ZSH:-$HOME/.local/share/zsh/oh-my-zsh}"
sh -c "export ZSH=${ZSH_HOME:-$HOME/.local/share/zsh}/oh-my-zsh; $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# ================================================
# Install ZLE widgets and ZSH plugins.
# ================================================
# `zsh-autocomplete`.
# - Not used, interferes too much with ZLE's built-in vi mode.
# rm -rf ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete
# git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"

# `zsh-completions`.
rm -rf ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions
git clone https://github.com/zsh-users/zsh-completions "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions"

# `zsh-vi-mode`.
# - No need, ZLE built-in keybindings are sufficient.
# rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode"
# git clone https://github.com/jeffreytse/zsh-vi-mode.git ${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode

# `zsh-autosuggestions`.
rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autosuggestions"

# `zsh-syntax-highlighting`.
# - zsh-syntax-highlighting registers a zle-line-pre-redraw hook.
# - ZLE hooks run in order of registration.
# - zsh-syntax-highlighting must be installed / registered after all other ZLE hooks that change the command-line buffer,
#   so syntax highlighting is added to all text.
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting"
