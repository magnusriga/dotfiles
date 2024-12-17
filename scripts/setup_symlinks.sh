#!/usr/bin/env bash

echo "Running setup_symlinks.sh..."

# ================================================================
# Add symlink to fd, since another program has taken fd name.
# Add ~/.local/bin, where symlink is placed, to path so fd is found.
# ================================================================
if [ ! -d "$HOME/.local/bin" ]; then
  mkdir "$HOME/.local/bin"
fi
if [ ! -L "$HOME/.local/bin/fd" ]; then
  ln -fs $(which fdfind) ~/.local/bin/fd
fi
