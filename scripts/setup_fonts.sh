#!/usr/bin/env bash

echo "Running setup_fonts.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# Get target root directory.
if [[ $(uname) == 'Darwin' ]]; then
  # MacOS.
  sys_share_dir="/Library"
  usr_share_dir="$HOME/Library"
  font_subdir="Fonts"
else
  # Linux.
  sys_share_dir="/usr/local/share"
  usr_share_dir="$HOME/.local/share"
  font_subdir="fonts"
fi

if [ -n "${XDG_DATA_HOME}" ]; then
  usr_share_dir="${XDG_DATA_HOME}"
fi

sys_font_dir="${sys_share_dir}/${font_subdir}/NerdFonts"
usr_font_dir="${usr_share_dir}/${font_subdir}/NerdFonts"

# Install fonts for all users, i.e. in `sys_font_dir`.
font_dir="${sys_font_dir}"
echo "font_dir is $font_dir"

# Create new clean font directory.
sudo rm -rf $font_dir
sudo mkdir -p $font_dir

# Install Nerd Fonts.
echo "Installing Nerd Fonts, this must also be done manually on Windows if using WSL..."
fontNames=("JetBrainsMono" "NerdFontsSymbolsOnly")
for font in ${fontNames[@]}; do
  echo "Installing font $font in directory $font_dir."
  sudo curl -fsSLO --create-dirs --output-dir "$font_dir" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz
  sudo tar -xf "$font_dir"/$font.tar.xz -C "$font_dir"
  sudo rm "$font_dir"/$font.tar.xz
done
if [[ $(uname) != "Darwin" ]]; then
  fc-cache -fv
fi
