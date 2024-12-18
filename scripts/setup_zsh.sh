#!/usr/bin/env bash

echo "Running setup_zsh.sh."

# Remove existing oh-my-zsh install folder, then install oh-my-zsh.
# If $ZSH folder is pre-created, oh-my-zsh complains.
# $ZSH is used by oh-my-zsh install script, as install directory for oh-my-zsh.
rm -rf "$ZSH"
sh -c "export ZSH=${ZSH_HOME:-$HOME/.local/share/zsh}/oh-my-zsh; $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# Install ZLE widgets.
# - zsh-syntax-highlighting registers a zle-line-pre-redraw hook.
# - ZLE hooks run in order of registration.
# - zsh-syntax-highlighting must be installed / registered after all other ZLE hooks that change the command-line buffer,
#   so syntax highlighting is added to all text. 
rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting" "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions" "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"
git clone https://github.com/zsh-users/zsh-completions "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions"
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting"
