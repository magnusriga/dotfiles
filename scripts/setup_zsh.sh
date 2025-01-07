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
# Install Vi Mode plugin for ZSH.
# ================================================
rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode"
# In .zshrc: source ${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode/zsh-vi-mode.plugin.zsh
git clone https://github.com/jeffreytse/zsh-vi-mode.git ${ZSH_HOME:-$HOME/.local/share/zsh}/.zsh-vi-mode

# ================================================
# Install zsh-autosuggestions plugin for ZSH.
# ================================================
rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autosuggestions

# ================================================
# Install ZLE widgets.
# ================================================
# - zsh-syntax-highlighting registers a zle-line-pre-redraw hook.
# - ZLE hooks run in order of registration.
# - zsh-syntax-highlighting must be installed / registered after all other ZLE hooks that change the command-line buffer,
#   so syntax highlighting is added to all text. 
rm -rf ${ZSH_HOME:-$HOME/.local/share/zsh}/{zsh-syntax-highlighting,zsh-completions,zsh-autocomplete}
git clone https://github.com/zsh-users/zsh-completions "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions"
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting"
