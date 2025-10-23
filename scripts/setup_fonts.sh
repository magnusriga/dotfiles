#!/usr/bin/env bash

echo "Running setup_fonts.sh as $(whoami), with HOME $HOME and USER $USER."

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
for font in "${fontNames[@]}"; do
  echo "Installing font $font in directory $font_dir."
  sudo curl -fsSLO --create-dirs --output-dir "$font_dir" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz"
  sudo tar -xf "$font_dir/$font.tar.xz" -C "$font_dir"
  sudo rm "$font_dir"/"$font".tar.xz
done
if [[ $(uname) != "Darwin" ]]; then
  fc-cache -fv
fi

# ================================================
# Install PowerPoint Viewer fonts
# ================================================
export DOWNLOAD_URL="https://archive.org/download/PowerPointViewer_201801/PowerPointViewer.exe"
export EXPECTED_CHECKSUM="249473568eba7a1e4f95498acba594e0f42e6581add4dead70c1dfb908a09423"

usr_font_dir="${usr_share_dir}/${font_subdir}/ppviewer"

function install_cabextract_arch_or_ubuntu() {
  if command -v pacman >/dev/null; then
    echo "Installing cabextract via pacman..."
    sudo pacman -Sy --noconfirm cabextract
  elif command -v apt >/dev/null; then
    echo "Installing cabextract via apt..."
    sudo apt update && sudo apt install -y cabextract
  else
    echo "Unsupported package manager. Please install cabextract manually."
    exit 1
  fi
}

command -v cabextract >/dev/null || {
  echo "Installing cabextract..."
  install_cabextract_arch_or_ubuntu
}

echo "Downloading PowerPoint Viewer..."

wget -q "$DOWNLOAD_URL"

ACTUAL_CHECKSUM=$(sha256sum PowerPointViewer.exe | cut -d' ' -f1)

[ "$ACTUAL_CHECKSUM" = "$EXPECTED_CHECKSUM" ] || {
  echo "Checksum verification failed!"
  rm -f PowerPointViewer.exe
  exit 1
}

echo "Installing PowerPoint Fonts..."

cabextract PowerPointViewer.exe -F ppviewer.cab >/dev/null
mkdir -p "$usr_font_dir"
cabextract ppviewer.cab -F '*.TTC' -F '*.TTF' -d "$usr_font_dir" >/dev/null

rm -f PowerPointViewer.exe ppviewer.cab

echo "Fonts installed to: $usr_font_dir"
echo "Restart applications to use new fonts."
