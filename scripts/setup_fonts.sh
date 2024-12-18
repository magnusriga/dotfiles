#!/usr/bin/env bash

echo "Running setup_fonts.sh."

FONT_HOME = ${FONT_HOME:-/home/$USERNAME/.local/share/fonts}

echo "FONT_HOME is $FONT_HOME"

# Install Nerd Font.
echo "Installing Nerd Font, this must also be done manually on Windows if using WSL..."
curl -fsSLO --create-dirs --output-dir "$FONT_HOME" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz &&
  tar -xf "$FONT_HOME"/JetBrainsMono.tar.xz -C "$FONT_HOME" &&
  rm "$FONT_HOME"/JetBrainsMono.tar.xz &&
  fc-cache -fv
