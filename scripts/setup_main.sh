#!/usr/bin/env bash

# ================================================
# Setup: Required environment variables.
# ================================================
export PATH="$PATH:$HOME/.local/bin"

echo "Running setup_main.sh as $(whoami), with HOME $HOME and USER $USER."

# ==========================================================
# Change directory to path of current script,
# to execute other scripts with relative path.
# ==========================================================
SCRIPTPATH="$(
  cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit
  pwd -P
)/"
echo "cd to SCRIPTPATH: $SCRIPTPATH"
cd "$SCRIPTPATH" || exit

# ================================================
# Setup: Directories.
# ================================================
if [ -f "./setup_directories.sh" ]; then
  set -a
  . ./setup_directories.sh
  set +a
  echo -e "Just sourced setup_directories.sh, environment variables in current process are now:\n\n$(env)"
fi

# ================================================
# Package installation: Update registry, upgrade existing packages, install new packages.
# ================================================
if [ -f "./setup_packages.sh" ]; then
  if [ -f /.dockerenv ] || [ -n "$DOCKER_BUILD" ]; then
    echo "Skipping ./setup_packages.sh in Docker environment (already run as root)"
  else
    echo "./setup_packages.sh found, executing script."
    . ./setup_packages.sh
  fi

  # Set necessary aliases (later set via dotfiles).
  alias python=python3
fi

# ================================================
# Arch User Repository (AUR): Install packages, if on Arch Linux.
# ================================================
if [ -f "./setup_packages_aur.sh" ] && [ -f "/etc/arch-release" ]; then
  echo "Running: . ./setup_packages_aur.sh."
  . ./setup_packages_aur.sh
fi

# ================================================
# Install: `snap` packages, if not Docker.
# snap(d):
# - Ubuntu: `snap` pre-installed.
# - Arch: `snap` installed via AUR, only outside Docker.
# - `dog`:
#   - Only package installed with `snap`.
#   - Only installed outside Docker.
#   - Thus, `dog` available everywhere, except in Docker.
# ================================================
if [ ! -f /.dockerenv ] && [ -z "$DOCKER_BUILD" ]; then
  echo "Not in container, installing dog via snap."
  sudo snap install dog
fi

# ================================================
# Setup: Locale.
# Done previously, in `setup_packages.sh`.
# ================================================
# sudo localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# ================================================
# Setup: Docker (installed with `pacman`).
# ================================================
if [ ! -f /.dockerenv ] && [ -z "$DOCKER_BUILD" ]; then
  echo "Not in container, starting docker service."
  # Start Docker engine now.
  sudo systemctl start docker.service
  # Ensure Docker engine starts on system boot.
  sudo systemctl enable docker.service
  # Reload all service files and update its internal configuration.
  sudo systemctl daemon-reload
fi

# ================================================
# Setup: Rust toolchain via `rustup`, and add it to path.
# ================================================
echo "Setup rust toolchain via rustup and add it to path."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
. "$HOME/.cargo/env"
rustup update

# ================================================
# `cargo`: Install packages (requires rust toolchain).
# ================================================
if [ -f "./setup_packages_cargo.sh" ]; then
  . ./setup_packages_cargo.sh
fi

# ================================================
# Install: Manual packages built from source.
# ================================================
if [ -f "./setup_packages_manual.sh" ]; then
  . ./setup_packages_manual.sh
fi

# ================================================
# `pip`: Install packages.
# ================================================
if [ -f "./setup_packages_pip.sh" ]; then
  . ./setup_packages_pip.sh
fi

# ================================================
# Not using Homebrew on Linux.
# ================================================
# if [ -f "./setup_brew.sh" ]; then
#   . ./setup_brew.sh
# fi

# ================================================
# Setup Wezterm shell integration.
# ================================================
rm -rf "$WEZTERM_HOME/shell-integration"
curl -fsSLO --create-dirs --output-dir "$WEZTERM_HOME/shell-integration" https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh

# ================================================
# Setup Ghostty shell integration.
# ================================================
rm -rf "${GHOSTTY_HOME:-${BUILD_HOME:-$HOME/build}/repositories/ghostty}"
rm -f "${GHOSTTY_RESOURCES_DIR:-$HOME/.local/share/ghostty}"
git clone https://github.com/ghostty-org/ghostty.git "${GHOSTTY_HOME:-${BUILD_HOME:-$HOME/build}/repositories/ghostty}"
ln -s "${BUILD_HOME:-$HOME/build}/repositories/ghostty/src" "${GHOSTTY_RESOURCES_DIR:-$HOME/.local/share/ghostty}"

# ================================================
# Clone `delta` repo for themes.
# ================================================
rm -rf "$HOME/.config/delta"
git clone https://github.com/dandavison/delta.git "$HOME/.config/delta"

# ================================================
# Setup: `git` credentials.
# Use `.gitconfig` from dotfiles instead.
# ================================================
# if [ -f "./setup_git_credentials.sh" ]; then
#   . ./setup_git_credentials.sh
# fi

# ================================================
# Install: `oh-my-zsh` and ZLE widgets.
# ================================================
if [ -f "./setup_zsh.sh" ]; then
  . ./setup_zsh.sh
fi

# ================================================
# Install: `nvm` and `node`.
# ================================================
if [ -f "./setup_nvm.sh" ]; then
  . ./setup_nvm.sh
fi

# ================================================
# Install: `pnpm` and global `pnpm` packages.
# ================================================
if [ -f "./setup_pnpm.sh" ]; then
  . ./setup_pnpm.sh
fi

# ================================================
# Install: `bun`.
# ================================================
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ================================================
# Install: `Clipboard`.
# Not needed, using xclip.
# ================================================
# curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh -s -- -y

# ================================================
# Install: `Starship`.
# ================================================
curl -sS https://starship.rs/install.sh | sh -s -- -y

# ================================================
# Install: `trash-cli`.
# ================================================
pipx ensurepath
pipx install 'trash-cli[completion]'
cmds=(trash-empty trash-list trash-restore trash-put trash)
for cmd in "${cmds[@]}"; do
  $cmd --print-completion bash | sudo tee /usr/share/bash-completion/completions/"$cmd"
  $cmd --print-completion zsh | sudo tee /usr/share/zsh/site-functions/_"$cmd"
  $cmd --print-completion tcsh | sudo tee /etc/profile.d/"$cmd".completion.csh
done

# ================================================
# Install: Fonts.
# ================================================
if [ -f "./setup_fonts.sh" ]; then
  . ./setup_fonts.sh
fi

# ================================================
# Install: `yazi` plugins.
# ================================================
if [ -f "./setup_yazi.sh" ]; then
  . ./setup_yazi.sh
fi

# ================================================
# Clone/Update repos, if not in Docker.
# Docker: All repos are bind-mounted from host.
# ================================================
if [ ! -f /.dockerenv ] && [ -z "$DOCKER_BUILD" ]; then
  # `nfront` repository.
  if [ -d "$HOME/nfront" ]; then
    echo "Updating nfront repository at $HOME/nfront."
    cd "$HOME/nfront" && git pull origin main
  else
    echo "Cloning nfront repository to $HOME/nfront."
    git clone git@github.com:magnusriga/nfront.git "$HOME/nfront"
  fi

  # `video-scraper` repository, only if username includes "magnus".
  if [[ "$USER" == *"magnus"* ]]; then
    if [ -d "$HOME/video-scraper" ]; then
      echo "Updating video-scraper repository at $HOME/video-scraper."
      cd "$HOME/video-scraper" && git pull origin main
    else
      echo "Cloning video-scraper repository to $HOME/video-scraper."
      git clone git@github.com:magnusriga/video-scraper.git "$HOME/video-scraper"
    fi
  else
    echo "Skipping video-scraper repository (username does not include 'magnus')."
  fi

  # Return to script directory.
  cd "$SCRIPTPATH" || exit
fi

# ================================================
# Setup: `cron` jobs.
# ================================================
(
  crontab -l
  echo "@daily $(which trash-empty) 30"
) | crontab -

# ================================================
# Create: Symlinks, e.g. to commonly used programs.
# ================================================
if [[ -f "./setup_symlinks.sh" ]]; then
  . ./setup_symlinks.sh
fi

# ================================================
# Update: Manual page cache.
# Many warnings, so make quiet.
# ================================================
sudo mandb -q

# ================================================
# Print: Tool versions.
# ================================================
if [[ -f "./print_versions.sh" ]]; then
  . ./print_versions.sh
fi
