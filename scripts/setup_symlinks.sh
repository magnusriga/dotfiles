#!/usr/bin/env bash

echo "Running setup_symlinks.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ================================================================
# Create local bin folder if necessary.
# ================================================================
if [ ! -d "$HOME/.local/bin" ]; then
  mkdir "$HOME/.local/bin"
fi

# ================================================================
# Remove existing symlinks.
# ================================================================
rm ~/.local/bin/fd ~/.local/bin/sg ~/.local/bin/bat

# ================================================================
# Add symlinks.
# Remember: Add ~/.local/bin to path.
# ================================================================
if [ ! -L "$HOME/.local/bin/fd" ]; then
  ln -fs $(which fdfind) ~/.local/bin/fd
fi

if [ ! -L "$HOME/.local/bin/sg" ]; then
  ln -fs $(which ast-grep) ~/.local/bin/sg
fi

if [ ! -L "$HOME/.local/bin/bat" ]; then
  ln -fs $(which batcat) ~/.local/bin/bat
fi
