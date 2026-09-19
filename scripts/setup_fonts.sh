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
# Install design fonts
# ------------------------------------------------
# Modern sans-serifs commonly used in product/UI/logo design.
# Installed system-wide alongside Nerd Fonts so design tools
# (Inkscape, GIMP, Figma desktop, etc.) can pick them up.
# ================================================
design_font_dir="${sys_share_dir}/${font_subdir}/Design"
echo "Installing design fonts in directory $design_font_dir"
sudo rm -rf "$design_font_dir"
sudo mkdir -p "$design_font_dir"

# Helper: download Fontshare TTF (Satoshi, General Sans) and fix the
# corrupted name table that Fontshare's CDN ships in some weights.
# Requires `python-fonttools` (Arch) / `python3-fonttools` (Ubuntu), installed by `setup_packages.sh`.
function install_fontshare_font() {
  local slug="$1"      # URL slug, e.g. "satoshi"
  local family="$2"    # Display family, e.g. "Satoshi"
  local weights="$3"   # Space-separated weights, e.g. "400 500 700 900"

  local wcsv="${weights// /,}"
  local css
  css="$(curl -fsSL "https://api.fontshare.com/v2/css?f%5B%5D=${slug}@${wcsv}&display=swap" \
    -H "User-Agent: Mozilla/5.0")"

  for w in $weights; do
    local ttf_url
    ttf_url=$(awk -v w="$w" '
      /^@font-face/ { block="" }
      { block = block "\n" $0 }
      /font-weight:/ {
        if (block ~ ("font-weight: *" w)) {
          match(block, /\/\/cdn\.fontshare\.com\/[^'\'']+\.ttf/)
          if (RSTART) print substr(block, RSTART, RLENGTH)
        }
      }
    ' <<< "$css" | head -1)

    if [ -z "$ttf_url" ]; then
      echo "    skip: no $family weight $w on Fontshare"
      continue
    fi

    local outpath="$design_font_dir/${family// /}-${w}.ttf"
    sudo curl -fsSL -o "$outpath" "https:${ttf_url}"

    # Repair name table: Fontshare ships some weights with name ID 1 set to "false".
    sudo python3 - "$outpath" "$family" "$w" <<'PY'
import sys
from fontTools.ttLib import TTFont
path, family, weight = sys.argv[1], sys.argv[2], sys.argv[3]
subfam_map = {"400":"Regular","500":"Medium","600":"SemiBold","700":"Bold","800":"ExtraBold","900":"Black"}
subfam = subfam_map.get(weight, weight)
full = f"{family} {subfam}"
ps   = f"{family.replace(' ','')}-{subfam}"
t = TTFont(path)
for n in t["name"].names:
    if   n.nameID == 1: val = family
    elif n.nameID == 2: val = subfam
    elif n.nameID == 4: val = full
    elif n.nameID == 6: val = ps
    else: continue
    n.string = val.encode("utf-16-be") if n.platformID == 3 else val.encode("latin-1")
t.save(path)
PY
  done
}

# Inter (rsms/inter) — static TTFs from the v4.1 release.
echo "  - Inter"
inter_tmp=$(mktemp -d)
sudo curl -fsSL -o "$inter_tmp/inter.zip" \
  "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
sudo unzip -j -o "$inter_tmp/inter.zip" "extras/ttf/*.ttf" -d "$design_font_dir" >/dev/null
sudo rm -rf "$inter_tmp"

# Geist (vercel/geist-font) — static TTFs from the Next.js distribution.
echo "  - Geist"
for w in Thin UltraLight Light Regular Medium SemiBold Bold Black UltraBlack; do
  sudo curl -fsSL --output-dir "$design_font_dir" -O \
    "https://github.com/vercel/geist-font/raw/main/packages/next/dist/fonts/geist-sans/Geist-${w}.ttf"
done

# Cal Sans (calcom/sans, distributed via Google Fonts) — single weight, popular for headings.
echo "  - Cal Sans"
sudo curl -fsSL -o "$design_font_dir/CalSans-Regular.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/calsans/CalSans-Regular.ttf"

# Google Fonts variable fonts — DM Sans, Manrope, Plus Jakarta Sans, Outfit, Onest.
echo "  - DM Sans, Manrope, Plus Jakarta Sans, Outfit, Onest (Google Fonts)"
sudo curl -fsSL -o "$design_font_dir/DMSans.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/dmsans/DMSans%5Bopsz%2Cwght%5D.ttf"
sudo curl -fsSL -o "$design_font_dir/Manrope.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/manrope/Manrope%5Bwght%5D.ttf"
sudo curl -fsSL -o "$design_font_dir/PlusJakartaSans.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/plusjakartasans/PlusJakartaSans%5Bwght%5D.ttf"
sudo curl -fsSL -o "$design_font_dir/Outfit.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/outfit/Outfit%5Bwght%5D.ttf"
sudo curl -fsSL -o "$design_font_dir/Onest.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/onest/Onest%5Bwght%5D.ttf"

# Fontshare fonts — Satoshi and General Sans, with name-table repair.
echo "  - Satoshi, General Sans (Fontshare)"
install_fontshare_font "satoshi"      "Satoshi"      "400 500 700 900"
install_fontshare_font "general-sans" "General Sans" "400 500 600 700"
unset -f install_fontshare_font

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
