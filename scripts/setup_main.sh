#!/usr/bin/env bash

echo "Running setup_main.sh with USERNAME $USERNAME."

SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE || $0")" >/dev/null 2>&1 ; pwd -P )/"
echo "SCRIPTPATH is $SCRIPTPATH."

# apt-get: Update registry, upgrade existing packages, install new packages.
if [ -f "${SCRIPTPATH:-./}setup_apt-get_packages.sh" ]; then
  sudo ${SCRIPTPATH:-./}setup_apt-get_packages.sh
fi

# Set locale.
sudo localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Install Docker.
if [ -f "${SCRIPTPATH:-./}setup_docker.sh" ]; then
  sudo ${SCRIPTPATH:-./}setup_docker.sh
fi

# Setup directories.
if [ -f "${SCRIPTPATH:-./}setup_directories.sh" ]; then
  set -a
  source ${SCRIPTPATH:-./}setup_directories.sh
  set +a
  echo -e "Just sourced setup_directories.sh, environment variables in current process are now:\n\n$(env)"
fi

# Setup the latest stable Rust toolchain via rustup, and add it to path.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
rustup update

# Install Homebrew and Homebrew packages.
if [ -f "${SCRIPTPATH:-./}setup_brew.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_brew.sh
fi

# Setup git credentials.
# Use .gitconfig from dotfiles instead.
# if [ -f "${SCRIPTPATH:-./}setup_git_credentials.sh" ]; then
#   sudo -u $USERNAME ${SCRIPTPATH:-./}setup_git_credentials.sh
# fi

# Install eza: Program, theme, and completions.
if [ -f "${SCRIPTPATH:-./}setup_eza.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_eza.sh
fi

# Install oh-my-zsh and ZLE widgets.
if [ -f "${SCRIPTPATH:-./}setup_zsh.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_zsh.sh
fi

# Install nvm and node.
if [ -f "${SCRIPTPATH:-./}setup_nvm.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_nvm.sh
fi

# Install tmux plugins, including tmux plugin manager.
if [ -f "${SCRIPTPATH:-./}setup_tmux.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_tmux.sh
fi

# Install pnpm and global pnpm packages.
if [ -f "${SCRIPTPATH:-./}setup_pnpm.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_pnpm.sh
fi

# Install bun.
curl -fsSL https://bun.sh/install | bash

# Install Clipboard.
curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh -s -- -y

# Install Starship.
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install packages with snap.
sudo snap install dog

# Install trash-cli.
pipx ensurepath
pipx install 'trash-cli[completion]'
cmds=(trash-empty trash-list trash-restore trash-put trash)
for cmd in "${cmds[@]}"; do
  $cmd --print-completion bash | sudo tee "/usr/share/bash-completion/completions/$cmd" 1>/dev/null
  $cmd --print-completion zsh | sudo tee "/usr/share/zsh/site-functions/_$cmd" 1>/dev/null
  $cmd --print-completion tcsh | sudo tee "/etc/profile.d/$cmd.completion.csh" 1>/dev/null
done

# Install fonts.
if [ -f "${SCRIPTPATH:-./}setup_fonts.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_fonts.sh
fi

# Install yazi and yazi plugins.
if [ -f "${SCRIPTPATH:-./}setup_yazi.sh" ]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_yazi.sh
fi

# Install Wezterm shell intergration.
rm -rf "$WEZTERM_HOME/shell-integration"
curl -fsSLO --create-dirs --output-dir "$WEZTERM_HOME/shell-integration" https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh

# Clone kickstart.nvim.
if [ ! -d "${NVIM_HOME:-$HOME/.config/nvim}" ]; then
  git clone https://github.com/magnusriga/kickstart.nvim.git "${NVIM_HOME:-$HOME/.config/nvim}"
fi

# Clone dotfiles.
if [ ! -d "$HOME/dotfiles" ]; then
  git clone git@github.com:magnusriga/dotfiles.git "$HOME/dotfiles"
fi

# Setup cron jobs.
(
  crontab -l
  echo "@daily $(which trash-empty) 30"
) | crontab -

# Create symlinks, e.g. to commonly used programs.
if [[ -f ${SCRIPTPATH:-./}setup_symlinks.sh ]]; then
  sudo -u $USERNAME ${SCRIPTPATH:-./}setup_symlinks.sh
fi

# Print tool versions
if [[ -f ${SCRIPTPATH:-./}print_versions.sh ]]; then
  source ${SCRIPTPATH:-./}print_versions.sh
fi
