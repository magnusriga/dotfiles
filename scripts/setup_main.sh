#!/usr/bin/env bash

# ================================================
# Setup: Required environment variables.
# ================================================
export PATH="$PATH:$HOME/.local/bin"

echo "Running setup_main.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

# ==========================================================
# Change directory to path of current script,
# to execute other scripts with relative path.
# ==========================================================
SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE")" >/dev/null 2>&1 ; pwd -P )/"
echo "cd to SCRIPTPATH: $SCRIPTPATH"
cd $SCRIPTPATH

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
# `pacman`: Update registry, upgrade existing packages, install new packages.
# ================================================
if [ -f "./setup_packages_pacman.sh" ]; then
  echo "./setup_packages_pacman.sh found, executing script as sudo."
  . ./setup_packages_pacman.sh

  # Set necessary aliases (later set via dotfiles).
  alias python=python3
fi

# ================================================
# Arch User Repository (AUR): Install packages.
# ================================================
if [ -f "./setup_packages_aur.sh" ]; then
  . ./setup_packages_aur.sh
fi

# ================================================
# Setup: Locale.
# Done previously, in `setup_packages_pacman.sh`.
# ================================================
# sudo localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# ================================================
# Setup: Docker (installed with `pacman`).
# ================================================
# Start Docker engine now.
sudo systemctl start docker.service
# Ensure Docker engine starts on system boot.
sudo systemctl enable docker.service

# ================================================
# Setup: Rust toolchain via `rustup`, and add it to path.
# ================================================
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
rustup update

# ================================================
# `cargo`: Install packages (requires rust toolchain).
# ================================================
if [ -f "./setup_cargo_packages.sh" ]; then
  . ./setup_cargo_packages.sh
fi

# ================================================
# `pip`: Install packages, currently none.
# ================================================
# if [ -f "./setup_pip_packages.sh" ]; then
#   . ./setup_pip_packages.sh
# fi

# ================================================
# Not using Homebrew on Linux.
# ================================================
# if [ -f "./setup_brew.sh" ]; then
#   . ./setup_brew.sh
# fi

# ================================================
# Not using Wezterm.
# ================================================
# rm -rf "$WEZTERM_HOME/shell-integration"
# curl -fsSLO --create-dirs --output-dir "$WEZTERM_HOME/shell-integration" https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh

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
# Install: `snap` packages.
# ================================================
sudo snap install dog

# ================================================
# Install: `trash-cli`.
# ================================================
pipx ensurepath
pipx install 'trash-cli[completion]'
cmds=(trash-empty trash-list trash-restore trash-put trash)
for cmd in "${cmds[@]}"; do
  $cmd --print-completion bash | sudo tee "/usr/share/bash-completion/completions/$cmd" 1>/dev/null
  $cmd --print-completion zsh | sudo tee "/usr/share/zsh/site-functions/_$cmd" 1>/dev/null
  $cmd --print-completion tcsh | sudo tee "/etc/profile.d/$cmd.completion.csh" 1>/dev/null
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
# Clone: `nfront`.
# ================================================
if [ ! -d "$HOME/nfront" ]; then
  git clone git@github.com:magnusriga/nfront.git "$HOME/nfront"
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
