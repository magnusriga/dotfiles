#!/usr/bin/env bash

echo "Running setup_symlinks.sh as $(whoami), with HOME $HOME and USER $USER."

# ================================================================
# Create local bin folder if necessary.
# ================================================================
if [ ! -d "$HOME/.local/bin" ]; then
  mkdir "$HOME/.local/bin"
fi

# ================================================================
# Remove existing symlinks.
# ================================================================
rm -f ~/.local/bin/fd ~/.local/bin/sg ~/.local/bin/bat ~/.local/bin/pbcopy ~/.local/bin/pbpaste

# ================================================================
# Add software symlinks.
# Remember: Add ~/.local/bin to path.
# ================================================================
if [ -n "$(which fdfind 2>/dev/null)" ]; then
  ln -fs "$(which fdfind)" ~/.local/bin/fd
fi

if [ -n "$(which ast-grep 2>/dev/null)" ]; then
  ln -fs "$(which ast-grep)" ~/.local/bin/sg
fi

if [ -n "$(which batcat 2>/dev/null)" ]; then
  ln -fs "$(which batcat)" ~/.local/bin/bat
fi

if [ -f "$HOME/dotfiles/usr/local/bin/rpbcopy" ]; then
  chmod a+x "$HOME/dotfiles/usr/local/bin/rpbcopy"
  ln -fs "$HOME/dotfiles/usr/local/bin/rpbcopy" ~/.local/bin/pbcopy
fi

if [ -f "$HOME/dotfiles/usr/local/bin/rpbpaste" ]; then
  chmod a+x "$HOME/dotfiles/usr/local/bin/rpbpaste"
  ln -fs "$HOME/dotfiles/usr/local/bin/rpbpaste" ~/.local/bin/pbpaste
fi
