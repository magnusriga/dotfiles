#!/usr/bin/env bash

# Stop snapd service if it is running, so it can be upgraded.
systemctl is-active snapd.service && sudo service snapd stop

# Install packages.
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update
sudo apt-get install -y \
  locales \
  sudo \
  curl \
  wget \
  pipx \
  snapd \
  make \
  unzip zip \
  git \
  xclip \
  neovim \
  apt-transport-https \
  ca-certificates \
  gnupg2 \
  lsb-release \
  zsh zsh-common zsh-doc \
  iputils-ping \
  vim \
  file \
  ssh \
  iproute2 \
  rsync \
  python3-pip \
  gpg \
  bat \
  tree \
  jq \
  poppler-utils \
  build-essential \
  fd-find \
  sysstat \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libxtst6 xauth xvfb

# Package clean-up.
sudo rm -rf /var/lib/apt/lists/*

# Set locale.
sudo localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Add Docker's official GPG key.
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add docker repository to apt-get package sources.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Update apt-get register again, after adding package sources.
sudo apt-get update

# Install the latest Docker versions.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set username and UID variables.
USERNAME="$(id -un)"
USER_UID="$(id -u)"
USER_GID="$(id -g)"

# Set needed environment variables.
export XDG_CONFIG_HOME="/home/$USERNAME/.config"

# Setup directories.
LINUXBREW_HOME="/home/linuxbrew/.linuxbrew"
if [ ! -d $LINUXBREW_HOME ]; then
  mkdir -p $LINUXBREW_HOME
  # chown -R $USERNAME:$USERNAME $linuxbrew_home
fi

BUN_INSTALL="/home/$USERNAME/.bun"
if [ ! -d "$BUN_INSTALL" ]; then
  mkdir -p "$BUN_INSTALL"
fi

NVM_DIR="/home/$USERNAME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  mkdir -p "$NVM_DIR"
fi

PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
if [ ! -d "$PNPM_HOME" ]; then
  mkdir -p "$PNPM_HOME"
fi

FONT_HOME="/home/$USERNAME/.local/share/fonts"
if [ ! -d "$FONT_HOME" ]; then
  mkdir -p "$FONT_HOME"
fi

STARSHIP_HOME="$XDG_CONFIG_HOME/starship"
if [ ! -d "$STARSHIP_HOME" ]; then
  mkdir -p "$STARSHIP_HOME"
fi

WEZTERM_HOME="/home/$USERNAME/.local/share/wezterm"
if [ ! -d "$WEZTERM_HOME" ]; then
  mkdir -p "$WEZTERM_HOME"
fi

NVIM_HOME="$XDG_CONFIG_HOME/nvim"
# Let git make the folder.
# if [ ! -d "$NVIM_HOME" ]; then
#   mkdir -p "$NVIM_HOME"
# fi

YAZI_HOME="$XDG_CONFIG_HOME/yazi"
if [ ! -d "$YAZI_HOME" ]; then
  mkdir -p "$YAZI_HOME"
fi

ZSH_HOME="/home/$USERNAME/.local/share/zsh"
if [ ! -d "$ZSH_HOME" ]; then
  mkdir -p "$ZSH_HOME"
fi

ZSH="$ZSH_HOME/oh-my-zsh"
# Do not pre-create $ZSH directory, otherwise oh-my-zsh will complain.
# if [ ! -d "$ZSH" ]; then
#   mkdir -p "$ZSH"
# fi

EZA_HOME="/home/$USERNAME/.local/share/eza"
if [ ! -d "$EZA_HOME" ]; then
  mkdir -p "$EZA_HOME"
fi

EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
if [ ! -d "$EZA_CONFIG_DIR" ]; then
  mkdir -p "$EZA_CONFIG_DIR"
fi

TRASH_HOME="/home/$USERNAME/.local/share/Trash"
if [ ! -d "$TRASH_HOME" ]; then
  mkdir -p "$TRASH_HOME"
fi

# For trash-cli completion.
mkdir -p "/usr/share/zsh/site-functions/"
mkdir -p "/usr/share/bash-completion/completions"
mkdir -p "/etc/profile.d"

RUST_HOME="/home/$USERNAME/.rustup"
if [ ! -d "$RUST_HOME" ]; then
  mkdir -p "$RUST_HOME"
fi

CARGO_HOME="/home/$USERNAME/.cargo"
if [ ! -d "$CARGO_HOME" ]; then
  mkdir -p "$CARGO_HOME"
fi

TMUX_HOME="$XDG_CONFIG_HOME/tmux"
if [ ! -d "$TMUX_HOME" ]; then
  mkdir -p "$TMUX_HOME"
fi

COMMAND_HISTORY_DIR="/commandhistory"
if [ ! -d "$COMMAND_HISTORY_DIR" ]; then
  sudo mkdir -p "$COMMAND_HISTORY_DIR"
  sudo touch /commandhistory/.shell_history
fi

# Update sudoers file.
if [ ! -d "/etc/sudoers.d/$USERNAME" ] || ! grep -iFq "User_Alias ADMIN" "/etc/sudoers.d/$USERNAME"; then
  echo "\$USERNAME is $USERNAME, adding ADMIN User_Alias to: /etc/sudoers.d/$USERNAME"
  echo "User_Alias ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : FULLTIMERS = $USERNAME, %$USERNAME" | sudo tee "/etc/sudoers.d/$USERNAME" &>/dev/null
  echo 'ADMIN, FULLTIMERS ALL = NOPASSWD: /usr/bin/apt-get, NOPASSWD: /usr/bin/apt' | sudo tee -a "/etc/sudoers.d/$USERNAME" &>/dev/null
fi

# Install Nerd Font.
echo "Installing Nerd Font, this must also be done manually on Windows if using WSL..."
curl -fsSLO --create-dirs --output-dir "$FONT_HOME" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz &&
  tar -xf "$FONT_HOME"/JetBrainsMono.tar.xz -C "$FONT_HOME" &&
  rm "$FONT_HOME"/JetBrainsMono.tar.xz &&
  fc-cache -fv

# Download and install Homebrew.
if [ -z "$(brew --version)" ]; then
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
fi

# Clone kickstart.nvim.
if [ ! -d "${NVIM_HOME:-$HOME/.config/nvim}" ]; then
  git clone https://github.com/magnusriga/kickstart.nvim.git "${NVIM_HOME:-$HOME/.config/nvim}"
fi

# Update Homebrew and upgrade its packages.
brew update
brew upgrade

# Install Homebrew packages.
brew install preslavmihaylov/taps/todocheck
brew install pre-commit
brew install gh
brew install jless
brew install gcc
brew install bat
brew install fzf
brew install rg
brew install ast-grep
brew install tmux
brew install jesseduffield/lazygit/lazygit
brew tap wez/wezterm-linuxbrew
brew install wezterm
brew install zoxide
brew install ffmpegthumbnailer sevenzip imagemagick
brew install yazi --HEAD
brew install zsh-vi-mode
brew install glow
brew install zsh-autosuggestions

# These install node via linuxbrew, so do not install them with brew.
# brew install neonctl
# brew install contentful-cli

# Uninstall Homebrew packages that clash with below installations.
if [ -n "$(brew list --versions rust)" ]; then brew uninstall rust; fi
brew autoremove

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

# Install eza.
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor
# wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update
sudo apt-get install -y eza

# Download and install nvm, node, npm.
# 1) Clone the nvm repository to ~/.nvm.
# 2) Run $NVM_DIR/nvm.sh, which copies a snippet that starts nmv insto the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).
# 3) Install node.
# All nvm commands must have .nvm.sh run in same RUN command,
# otherwise it won't find the binaries it needs.
# NVM install should have been done by NVM script from curl,
# but for some reason it does not, so we must do it manually.
# "node" is an alias for the latest version, however we must use an actual version number for the addition to PATH to work.
# NODE_VERSION="22.11.0"
NODE_VERSION="node"
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default

# Install pnpm.
curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" sh -

# Install bun.
curl -fsSL https://bun.sh/install | bash

# Setup the latest stable Rust toolchain via rustup, and add it to path.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
rustup update

# Install Yazi plugins.
# rm -rf "${YAZI_HOME:-$HOME/.config/yazi}/plugins" "${YAZI_HOME:-$HOME/.config/yazi}/flavors"
rm -rf $(find ~/.config/yazi/plugins -maxdepth 1 -type d | grep -v -e 'arrow.yazi' -e 'folder-rules.yazi' -e 'system-clipboard.yazi' -e 'plugins$' -)
rm "${YAZI_HOME:-$HOME/.config/yazi}/package.toml"
git clone https://github.com/sharklasers996/eza-preview.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/eza-preview.yazi"
git clone https://github.com/boydaihungst/restore.yazi "${YAZI_HOME:-$HOME/.config/yazi}/plugins/restore.yazi"
git clone https://github.com/BennyOe/onedark.yazi.git "${YAZI_HOME:-$HOME/.config/yazi}/flavors/onedark.yazi"

# Install Wezterm shell intergration.
rm -rf "$WEZTERM_HOME/shell-integration"
curl -fsSLO --create-dirs --output-dir "$WEZTERM_HOME/shell-integration" https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh

# Remove existing oh-my-zsh install folder, then install oh-my-zsh.
# If $ZSH folder is pre-created, oh-my-zsh complains.
# $ZSH is used by oh-my-zsh install script, as install directory for oh-my-zsh.
rm -rf "$ZSH"
sh -c "export ZSH=${ZSH_HOME:-$HOME/.local/share/zsh}/oh-my-zsh; $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# Install ZSH plugins and addins.
rm -rf "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting" "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions" "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-completions "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions"
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete"

# Install Clipboard.
curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh -s -- -y

# Install Starship.
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install eza theme and symlink default theme to our own theme.
# eza uses the theme.yml file stored in $EZA_CONFIG_DIR, or if that is not defined then in $XDG_CONFIG_HOME/eza.
# Download theme repo as reference, but do not symlink $EZA_CONFIG_DIR/theme to it,
# instead just keep own theme from dotfiles sync.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"
git clone https://github.com/eza-community/eza-themes.git "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes"
# ln -sf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes/themes/default.yml" "${EZA_CONFIG_DIR:-$HOME/.config/eza}/theme.yml"

# Setup eza completions.
rm -rf "${EZA_HOME:-$HOME/.local/share/eza}/eza"
git clone https://github.com/eza-community/eza.git "${EZA_HOME:-$HOME/.local/share/eza}/eza"

# Setup tmux plugin manager and manually install plugins.
rm -rf "${TMUX_HOME:-$HOME/.config/tmux}/plugins"
git clone https://github.com/tmux-plugins/tpm "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tpm"
git clone -b v2.1.1 https://github.com/catppuccin/tmux.git "${TMUX_HOME:-$HOME/.config/tmux}/plugins/catppuccin/tmux"
git clone https://github.com/tmux-plugins/tmux-battery "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-battery"
git clone https://github.com/tmux-plugins/tmux-cpu "${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-cpu"

# Setup cron jobs.
(
  crontab -l
  echo "@daily $(which trash-empty) 30"
) | crontab -

# Install Yazi plugins.
ya pack -a yazi-rs/plugins:full-border
ya pack -a yazi-rs/plugins:max-preview
ya pack -a dedukun/relative-motions
ya pack -a Reledia/glow
ya pack -a yazi-rs/plugins:jump-to-char
ya pack -a dedukun/bookmarks
ya pack -a yazi-rs/plugins:chmod
ya pack -a Lil-Dank/lazygit
ya pack -a yazi-rs/plugins:smart-filter
ya pack -a yazi-rs/plugins:git
ya pack -a Rolv-Apneseth/starship
ya pack -a yazi-rs/plugins:diff

# Create symlinks to programs, overwriting default programs.
rm ~/.local/bin/fd ~/.local/bin/sg ~/.local/bin/bat
ln -s "$(which fdfind)" ~/.local/bin/fd
ln -s "$(which ast-grep)" ~/.local/bin/sg
ln -s "$(which batcat)" ~/.local/bin/bat

# Install global packages.
# RUN pnpm install -g turbo
pnpm install -g tree-node-cli

# Print tool versions
echo -e "\n\n================================\n\
PACKAGE VERSIONS\
\n================================\n\n\
"
bash --version | head -n 1
git --version
curl --version
wget --version

# Print package versions.
# nvm, npm must be called in same RUN as nvm.sh, to access the shell variables set there.
echo 'node version:' "$(node --version)"
echo 'npm version:' "$(npm --version)"
echo 'bun version:' "$(bun --version)"

# Print package binaray paths, to verify that the right binaries are used.
which node
which npm
which pnpm
which bun
