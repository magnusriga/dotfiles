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
rm -f ~/.local/bin/fd ~/.local/bin/sg ~/.local/bin/bat

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

# Keep the remote clipboard helpers distinct from the native commands they call.
# Installing rpbpaste as pbpaste makes its local fallback recurse indefinitely.
for clipboard_command in pbcopy pbpaste; do
  clipboard_helper="$HOME/dotfiles/usr/local/bin/r$clipboard_command"
  clipboard_alias="$HOME/.local/bin/$clipboard_command"
  # Migrate only aliases owned by this installer; preserve native/user commands.
  if [ -L "$clipboard_alias" ] && [ "$(readlink "$clipboard_alias")" = "$clipboard_helper" ]; then
    rm "$clipboard_alias"
  fi
  if [ -f "$clipboard_helper" ]; then
    chmod a+x "$clipboard_helper"
    ln -fs "$clipboard_helper" "$HOME/.local/bin/r$clipboard_command"
  fi
done
unset clipboard_command clipboard_helper clipboard_alias
