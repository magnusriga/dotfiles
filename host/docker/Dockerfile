# Do not use vscode versions, the ones without are newer

# IMAGES FOR GITHUB CODESPACES
# ================================
# Alt 1: mcr.microsoft.com/devcontainers/universal
# Alt 2: mcr.microsoft.com/devcontainers/javascript-node

# OTHER IMAGES (see: Docker Hub)
# ================================
# Images specified without specific url are downloaded from Docker Hub, if not found locally.
# 1) node:latest
# 2) cypress:included
# And many others. Full list: https://hub.docker.com

# FROM archlinux:latest AS builder
FROM menci/archlinuxarm AS builder
# FROM mcr.microsoft.com/devcontainers/universal
# FROM mcr.microsoft.com/devcontainers/javascript-node

# Prevent dialog during apt install
# ENV DEBIAN_FRONTEND noninteractive

# The below will replace the shell used when running this Dockerfile,
# from ["/bin/sh", "-c"] to ["bin/bash", ...], so we can source files.
# Comma-separated arguments to launch of bash shell:
# -l (login-shell)
# -e (exit when command fails)
# -u (unset variables treated as error, do NOT include this)
# -x (print each command before executing it)
# -o pipefall (set exit code to right-most command to exit with non-zero status)
# Took -l and -u out, as they caused issues with the Docker setup.
# SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]
SHELL ["/bin/bash", "-exo", "pipefail", "-c" ]

RUN rm -f /etc/pacman.conf
COPY pacman.conf /etc/pacman.conf

RUN pacman-key --init && pacman-key --populate archlinux

# Install sudo and git[]
RUN pacman -Syu --noconfirm sudo git

# ==========================================================
# Set locale.
# ==========================================================
# `localectl` needs `systemd`, thus skip.
#RUN sudo localectl set-locale LANG=en_US.UTF-8 && \
#  unset LANG && \
#  source /etc/profile.d/locale.sh
ENV LANG en_US.utf8

# ================================================
# Setup: Directories.
# ================================================
COPY setup_directories.sh .
RUN . ./setup_directories.sh && \ 
  echo -e "Just sourced setup_directories.sh, environment variables in current process are now:\n\n" && env

# ================================================
# `pacman`: Update registry, upgrade existing packages, install new packages.
# ================================================
COPY setup_packages_pacman.sh .
RUN . ./setup_packages_pacman.sh && \
  echo "Completed: ./setup_packages_pacman.sh."

# ================================================
# Arch User Repository (AUR): Install packages.
# ================================================
# COPY ../../scripts/setup_packages_aur.sh .
# RUN . ./setup_packages_aur.sh && \
#   echo "Completed: ./setup_packages_aur.sh."
# 
# # To make en_US.utf8 work:
# # Download locales package, run localdef command,
# # and set LANG environment variable (ensures it is available in the container)
# # See: https://hub.docker.com/_/ubuntu
# ENV LANG en_US.utf8
# 
# # Below we create a new user and further down we set it as default container user.
# # 1) New username here must match remoteUser in devcontainer.json.
# # 2) UID:GID of new user here must match UID:GID on host (WSL), to avoid binding issues.
# # See: https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_specifying-a-user-for-vs-code
# 
# # There is already a user with UID:GID 1000:1000 in the ubuntu image (username: ubuntu),
# # so update that user to a different UID:GID before adding ourselves to UID:GID 1000:1000.
# ARG UBUNTU_USERNAME=ubuntu
# ARG UBUNTU_UID_NEW=1001
# ARG UBUNTU_GID_NEW=$UBUNTU_UID_NEW
# 
# RUN groupmod --gid $UBUNTU_UID_NEW $UBUNTU_USERNAME \
#   && usermod --uid $UBUNTU_UID_NEW --gid $UBUNTU_GID_NEW $UBUNTU_USERNAME \
#   && chown -R $UBUNTU_UID_NEW:$UBUNTU_GID_NEW /home/$UBUNTU_USERNAME
# 
# ARG USERNAME=nfu
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID
# 
# # Create new group with GID USER_GID and group name USERNAME.
# # Create new user with UID USER_GID, GID USER_GID, and useer name USERNAME.
# RUN groupadd --gid $USER_GID $USERNAME \
#   && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#   #
#   # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
#   && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#   && chmod 0440 /etc/sudoers.d/$USERNAME
# 
# # Update sudoers file so $USERNAME does not have to type password for sudo commands.
# RUN echo "\$USERNAME is $USERNAME, adding ADMIN User_Alias to: /etc/sudoers.d/$USERNAME"
# RUN echo "User_Alias ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : FULLTIMERS = $USERNAME, %$USERNAME" >> "/etc/sudoers.d/$USERNAME"
# RUN echo 'ADMIN, FULLTIMERS ALL = NOPASSWD: ALL' >> "/etc/sudoers.d/$USERNAME"
# # RUN echo 'ADMIN, FULLTIMERS ALL = NOPASSWD: /usr/bin/apt-get, NOPASSWD: /usr/bin/apt' | sudo tee -a "/etc/sudoers.d/$USERNAME" &>/dev/null
# 
# # Setting passwords to same as username, in case needed.
# RUN echo 'root:root' | chpasswd; \
#   echo 'ubuntu:ubuntu' | chpasswd; \
#   echo "$USERNAME:$USERNAME" | chpasswd
# 
# # Make it so we do not have to enter in password when using sudo.
# # Done above.
# # RUN echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# 
# # Create Homebrew dir and change owner from root to $USER_NAME.
# # The directory must be "linuxbrew", as that's where curl-downloaded script installs it.
# # Note order of commands: Root changes owner of folder.
# RUN mkdir -p /home/linuxbrew/.linuxbrew
# RUN chown -R $USERNAME:$USERNAME /home/linuxbrew/.linuxbrew
# 
# # Create dir we want bun in, and let root change owner of folder.
# ENV BUN_INSTALL="/home/$USERNAME/.bun"
# RUN mkdir -p $BUN_INSTALL
# RUN chown -R $USERNAME:$USERNAME $BUN_INSTALL
# 
# # Folder we want nvm repo cloned to,
# # and where nvm.sh script is run from (which installs node).
# ENV NVM_DIR="/home/$USERNAME/.nvm"
# 
# # Create dir we want NVM in, and let root change owner of folder.
# RUN mkdir -p $NVM_DIR
# RUN chown -R $USERNAME:$USERNAME $NVM_DIR
# 
# # Folder we want the global pnpm store, aka. CAS, in.
# # Folder must be added to path later.
# ENV PNPM_HOME="/home/$USERNAME/.local/share/pnpm"
# RUN mkdir -p $PNPM_HOME
# 
# # Folder we want fonts in.
# # Only works on Linux.
# # On WSL or WSL > devcontainer, fonts must be installed in Windows.
# ENV FONT_HOME="/home/$USERNAME/.local/share/fonts"
# RUN mkdir -p $FONT_HOME
# 
# # Folder for starship prompt config
# ENV STARSHIP_HOME="/home/$USERNAME/.config/starship"
# RUN mkdir -p $STARSHIP_HOME && touch $STARSHIP_HOME/starship.toml
# RUN chown -R $USERNAME:$USERNAME $STARSHIP_HOME
# 
# # Folder for wezterm.
# ENV WEZTERM_HOME="/home/$USERNAME/.local/share/wezterm"
# RUN mkdir -p $WEZTERM_HOME
# RUN chown -R $USERNAME:$USERNAME $WEZTERM_HOME
# 
# # Folder for nvim.
# ENV XDG_CONFIG_HOME="/home/$USERNAME/.config"
# ENV NVIM_HOME="$XDG_CONFIG_HOME/nvim"
# # Let git make the folder.
# 
# ENV VIM_SESSIONS="/home/$USERNAME/.vim/sessions"
# RUN mkdir -p $VIM_SESSIONS
# 
# # Folder for yazi.
# ENV YAZI_HOME="/home/$USERNAME/.config/yazi"
# RUN mkdir -p $YAZI_HOME
# RUN chown -R $USERNAME:$USERNAME $YAZI_HOME
# 
# # Folder for zsh plugins and addins.
# # ZSH env is used by oh-my-zsh install script.
# ENV ZSH_HOME="/home/$USERNAME/.local/share/zsh"
# ENV ZSH="$ZSH_HOME/oh-my-zsh"
# RUN mkdir -p $ZSH_HOME
# RUN chown -R $USERNAME:$USERNAME $ZSH_HOME
# # Do not pre-create $ZSH directory, it will make oh-my-zsh complain.
# # RUN mkdir -p $ZSH
# # RUN chown -R $USERNAME:$USERNAME $ZSH
# 
# # Folder for eza git repo.
# # EZA_CONFIG_DIR is used by eza to lookup theme.
# ENV EZA_HOME="/home/$USERNAME/.local/share/eza"
# RUN mkdir -p $EZA_HOME
# RUN chown -R $USERNAME:$USERNAME $EZA_HOME
# ENV EZA_CONFIG_DIR="/home/$USERNAME/.config/eza"
# RUN mkdir -p $EZA_CONFIG_DIR
# RUN chown -R $USERNAME:$USERNAME $EZA_CONFIG_DIR
# 
# # Create folder for trash.
# ENV TRASH_HOME="/home/$USERNAME/.local/share/Trash"
# RUN mkdir -p $TRASH_HOME
# RUN chown -R $USERNAME:$USERNAME $TRASH_HOME
# 
# # Create folders for trash-cli completions.
# RUN mkdir -p "/usr/share/zsh/site-functions/"
# RUN chown -R $USERNAME:$USERNAME "/usr/share/zsh/site-functions/"
# RUN mkdir -p "/usr/share/bash-completion/completions"
# RUN chown -R $USERNAME:$USERNAME "/usr/share/bash-completion/completions"
# RUN mkdir -p "/etc/profile.d"
# RUN chown -R $USERNAME:$USERNAME "/etc/profile.d"
# 
# # Create folder for rustup and cargo.
# ENV RUST_HOME="/home/$USERNAME/.rustup"
# RUN mkdir -p $RUST_HOME
# RUN chown -R $USERNAME:$USERNAME $RUST_HOME
# ENV CARGO_HOME="/home/$USERNAME/.cargo"
# RUN mkdir -p $CARGO_HOME
# RUN chown -R $USERNAME:$USERNAME $CARGO_HOME
# 
# # Create folder for tmux plugins.
# ENV TMUX_HOME="/home/$USERNAME/.config/tmux"
# RUN mkdir -p $TMUX_HOME/plugins/catppuccin
# RUN chown -R $USERNAME:$USERNAME $TMUX_HOME/plugins/catppuccin
# 
# # Create temporary envfile to store environment variables from other scripts,
# # needed since docker cannot do command substitution in ENV operations.
# # /envfile is deleted at the end.
# # This did not solve the issue, as we would still not be able to access that environment
# # variable in an ENV operator.
# # RUN touch /envfile
# # RUN chown $USERNAME:$USERNAME /envfile
# 
# # Persist the command history across container restarts.
# # The contents of the PROMPT_COMMAND variable is executed as a regular Bash
# # command just before Bash displays a prompt. Thus, each time a command is used
# # in bash, the history is saved in /commandhistory/.bash_history.
# # /commandhistory will be saved as a volume, see the compose file.
# RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.shell_history" \
#   && mkdir /commandhistory \
#   && touch /commandhistory/.shell_history \
#   && chown -R $USERNAME /commandhistory \
#   && echo "$SNIPPET" >> "/home/$USERNAME/.profile"
# 
# # Install Docker Compose
# RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
#   && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
#   && chmod +x /usr/local/bin/docker-compose
# 
# RUN echo -e "#!/bin/sh\n\
#   sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
#   SOCKET_GID=\$(stat -c '%g' /var/run/docker.sock) \n\
#   if [ \"${SOCKET_GID}\" != '0' ]; then\n\
#   if [ \"\$(cat /etc/group | grep :\${SOCKET_GID}:)\" = '' ]; then sudoIf groupadd --gid \${SOCKET_GID} docker-host; fi \n\
#   if [ \"\$(id ${USERNAME} | grep -E \"groups=.*(=|,)\${SOCKET_GID}\(\")\" = '' ]; then sudoIf usermod -aG \${SOCKET_GID} ${USERNAME}; fi\n\
#   fi\n\
#   exec \"\$@\"" > /usr/local/share/docker-init.sh \
#   && chmod +x /usr/local/share/docker-init.sh
# 
# # Create binary folders.
# RUN mkdir -p ~/.local/bin
# RUN mkdir -p /home/$USERNAME/.local/bin
# 
# # While still executing commands as root, set permissions for home folder.
# # -R: Recursive, i.e. change owner of directiory itself and of all files and folders within it.
# # -v: Verbose, i.e. print what is being done.
# # -h: If file is a symbolic link, change the owner of the link itself, not the file it points to.
# RUN chown -hRv $USERNAME:$USERNAME /home/$USERNAME
# 
# # Add to PATH.
# ENV PATH="/root/.local/bin:${PATH}"
# ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
# 
# # Install trash-cli.
# RUN pipx ensurepath
# RUN pipx install 'trash-cli[completion]'
# RUN cmds=(trash-empty trash-list trash-restore trash-put trash); for cmd in ${cmds[@]}; do \
#   $cmd --print-completion zsh > "/usr/share/zsh/site-functions/_$cmd"; \
#   $cmd --print-completion bash > "/usr/share/bash-completion/completions/$cmd"; \
#   $cmd --print-completion tcsh > "/etc/profile.d/$cmd.completion.csh"; done
# 
# # RUN cmds=(trash-empty trash-list trash-restore trash-put trash); for cmd in ${cmds[@]}; $cmd --print-completion bash > "/usr/share/bash-completion/completions/$cmd"; done
# # $cmd --print-completion bash > "/usr/share/bash-completion/completions/$cmd"; $cmd --print-completion zsh > "/usr/share/zsh/site-functions/_$cmd"; $cmd --print-completion tcsh > "/etc/profile.d/$cmd.completion.csh";
# 
# # && for cmd in ${cmds[@]}; do $cmd --print-completion bash | tee /usr/share/bash-completion/completions/$cmd; done
# # && for cmd in ${cmds[@]}; do $cmd --print-completion bash | tee /usr/share/bash-completion/completions/$cmd \
# # && $cmd --print-completion zsh | tee /usr/share/zsh/site-functions/_$cmd; done
# # && $cmd --print-completion tcsh | tee /etc/profile.d/$cmd.completion.csh; done
# 
# # RUN cat /proc/$$/limits
# # RUN ulimit -Sn 1048576
# # RUN cat /proc/$$/limits
# 
# # Install Starship as root (needs sudo).
# RUN curl -sS https://starship.rs/install.sh | sh -s -- -y
# 
# # Done with root tasks, switch to non-root user for security purposes.
# USER $USERNAME
# 
# # Set USER environment variable to make it available in any container
# # running this image (used by pnpm in ~/.bash_profile).
# ENV USER=$USERNAME
# 
# # Download and install Homebrew.
# RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
# 
# # Add Homebrew bin (brew) to path.
# ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
# 
# # Install Homebrew packages.
# RUN brew install preslavmihaylov/taps/todocheck; \
#   brew install pre-commit; \
#   brew install gh; \
#   brew install jless; \
#   brew install gcc; \
#   brew install bat; \
#   brew install fzf; \
#   brew install rg; \
#   brew install ast-grep; \
#   brew install tmux; \
#   brew install jesseduffield/lazygit/lazygit; \
#   brew tap wez/wezterm-linuxbrew; \
#   brew install wezterm; \
#   brew install zoxide; \
#   brew install ffmpegthumbnailer sevenzip imagemagick; \
#   brew install yazi --HEAD; \
#   brew install zsh-vi-mode; \
#   brew install glow; \
#   brew install zsh-autosuggestions
# 
# # These install node via linuxbrew, so do not install them with brew.
# # RUN brew install neonctl
# # RUN brew install contentful-cli
# 
# # Download and install nvm, node, npm.
# # 1) Clone the nvm repository to ~/.nvm.
# # 2) Run $NVM_DIR/nvm.sh, which copies a snippet that starts nvm in the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).
# # 3) Install node.
# # All nvm commands must have .nvm.sh run in same RUN command,
# # otherwise it won't find the binaries it needs.
# # NVM install should have been done by NVM script from curl,
# # but for some reason it does not, so we must do it manually.
# # "node" is an alias for the latest version, however we must use an actual version number for the addition to PATH to work.
# ENV NODE_VERSION="23.3.0"
# RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
#   && . "$NVM_DIR/nvm.sh" \
#   && nvm install $NODE_VERSION \
#   && nvm alias default $NODE_VERSION \
#   && nvm use default
# 
# # Hack to get node version, since ENV operation cannot do command substitution.
# # See: https://stackoverflow.com/questions/34911622/dockerfile-set-env-to-result-of-command.
# # /envfile can be used in RUN operations like this: RUN . /envfile; echo $VAR_FROM_ENVFILE
# # Unfortunatelt, it has to be run ahead of every node, npm, or nvm command,
# # so reverting back to manually setting version number.
# # RUN echo "export $(source $NVM_DIR/nvm.sh && nvm current)" >> /envfile
# 
# # Add npm's node_modules folder to NODE_PATH, where (p)npm looks if it cannot find requested module up hierarchy.
# # This is a semicolon-delimited list of directories, and pnpm will add to it when installed.
# # TODO: nvm.sh also modifies PATH, NODE_PATH and MANPATH, but they do not stick in docker,
# # so set them manually.
# ENV NODE_PATH "$NODE_PATH:$NVM_DIR/versions/node/v${NODE_VERSION}/lib/node_modules"
# 
# # Add node to path.
# # Not sure if it is necessary to add node specifically to path, once nvm has been added to path.
# # TODO: It might be necessary in docker, as the nvm script modifies PATH, which does not stick
# # inside this docker build. Test.
# ENV PATH "$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH"
# 
# # Download and install pnpm binary.
# #   - pnpm install script, used when installing pnpm with curl, will:
# #     a) Set PNPM_HOME to ~/.local/share/pnpm
# #     b) Install pnpm binary there
# #     c) Add PNPM_HOME to PATH.
# #   - corepack, on other hand, will install pnpm in nvm folder, which is already on PATH.
# #   - Thus, with corepack, we do not need to make sure .bashrc or .bash_profile adds PNPM_HOME to PATH.
# #   - corepack is preferrable to curl, as it allows updating pnpm with one command,
# #     and at the same time updates the pnpm version in package.json.
# #   - Add pnpm update script to package.json, to make updating pnpm easy (pnpm:up).
# #   - Above, we set PNPM_HOME to t~/.local/share/pnpm, which is the recommended/default by pnpm,
# #     which means the content-addressable store (CAS) will be in: /home/nfu/.local/share/pnpm/store/v3
# #   - However, in docker, pnpm recommends this $PNPM_HOME path (i.e. root): /pnpm,
# #     which means CAS would be in: /pnpm/store/v3
# #   - Here, in dev container, we keep standard and use the user folder for the virtual store,
# #     and install pnpm with corepack so the binary is placed in the nvm folder:
# #     a) Set PNPM_HOME to ~/.local/share/pnpm <-- CAS will be placed here.
# #     b) Install pnpm with corepack, which places binary in nvm folder.
# #     c) Now we do not have to add PNPM_HOME to PATH, as the nvm folder is already in PATH.
# #     d) Set CAS in .npmrc: store-dir=${PNPM_HOME}/store <-- Not sure why this is needed.
# #   - Thus, we can install other repos etc., which are saved in user folder and use same CAS.
# #   - Old: RUN curl https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
# # RUN corepack enable pnpm
# 
# # Install pnpm.
# RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
# 
# # Add global pnpm store, aka. CAS, to PATH.
# ENV PATH $PNPM_HOME:$PATH
# 
# # Install bun and add it to path.
# RUN curl -fsSL https://bun.sh/install | bash
# ENV PATH $BUN_INSTALL/bin:$PATH
# 
# # Setup the latest stable Rust toolchain via rustup, and add it to path.
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# ENV PATH $CARGO_HOME/bin:$PATH
# RUN echo ". $CARGO_HOME/env" >> ${ZDOTDIR:-$HOME}/.zshrc
# RUN rustup update
# 
# # Install fonts.
# # Does not work, apparently the fonts must be installed on the host, i.e. Windows if using WSL.
# RUN curl -fsSLO --create-dirs --output-dir "$FONT_HOME" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
#   && tar -xf "$FONT_HOME"/JetBrainsMono.tar.xz -C "$FONT_HOME" \
#   && rm "$FONT_HOME"/JetBrainsMono.tar.xz \
#   && fc-cache -fv
# 
# # Clone kickstart.nvim.
# RUN git clone https://github.com/magnusriga/kickstart.nvim.git "${NVIM_HOME:-$HOME/.config/nvim}"
# 
# # Install Yazi plugins.
# RUN git clone https://github.com/sharklasers996/eza-preview.yazi ${YAZI_HOME:-$HOME/.config/yazi}/plugins/eza-preview.yazi
# RUN git clone https://github.com/boydaihungst/restore.yazi ${YAZI_HOME:-$HOME/.config/yazi}/plugins/restore.yazi
# RUN git clone https://github.com/BennyOe/onedark.yazi.git ${YAZI_HOME:-$HOME/.config/yazi}/flavors/onedark.yazi
# 
# # Install Wezterm shell intergration.
# RUN curl -fsSLO --create-dirs --output-dir $WEZTERM_HOME/shell-integration https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh
# RUN echo "source $WEZTERM_HOME/shell-integration/wezterm.sh" >> ${ZDOTDIR:-$HOME}/.zshrc
# 
# # Install oh-my-zsh.
# # ZSH env is used by oh-my-zsh install script, for where it installs oh-my-zsh.
# RUN sh -c "export ZSH=${ZSH_HOME:-$HOME/.local/share/zsh}/oh-my-zsh; $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
# 
# # Install ZSH plugins and addins.
# RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-syntax-highlighting
# RUN echo "source $ZSH_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
# RUN git clone https://github.com/zsh-users/zsh-completions ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-completions
# 
# RUN git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_HOME:-$HOME/.local/share/zsh}/zsh-autocomplete
# # RUN echo "source $ZSH_HOME/zsh-autocomplete/zsh-autocomplete.plugin.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
# 
# # Install Clipboard.
# RUN curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh -s -- -y
# 
# # Install eza theme.
# RUN git clone https://github.com/eza-community/eza-themes.git ${EZA_HOME:-$HOME/.local/share/eza}/eza-themes
# RUN ln -sf "${EZA_HOME:-$HOME/.local/share/eza}/eza-themes/themes/default.yml" ${EZA_CONFIG_DIR:-$HOME/.config/eza}/theme.yml
# 
# # Setup eza completions.
# RUN git clone https://github.com/eza-community/eza.git ${EZA_HOME:-$HOME/.local/share/eza}/eza
# RUN echo 'export FPATH="${EZA_HOME:-$HOME/.local/share/eza}/eza/completions/zsh:$FPATH"' >> ~/.zshrc
# 
# # Setup tmux plugin manager and manually install plugins.
# RUN git clone https://github.com/tmux-plugins/tpm ${TMUX_HOME:-$HOME/.config/tmux}/plugins/tpm
# RUN git clone -b v2.1.1 https://github.com/catppuccin/tmux.git ${TMUX_HOME:-$HOME/.config/tmux}/plugins/catppuccin/tmux
# RUN git clone https://github.com/tmux-plugins/tmux-battery ${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-battery
# RUN git clone https://github.com/tmux-plugins/tmux-cpu ${TMUX_HOME:-$HOME/.config/tmux}/plugins/tmux-cpu
# 
# # Setup cron jobs.
# # Does not work inside containers?
# # RUN (crontab -l ; echo "@daily $(which trash-empty) 30") | crontab -
# 
# # Install Yazi plugins.
# RUN ya pack -a yazi-rs/plugins:full-border; \
#   ya pack -a yazi-rs/plugins:max-preview; \
#   ya pack -a dedukun/relative-motions; \
#   ya pack -a Reledia/glow; \
#   ya pack -a yazi-rs/plugins:jump-to-char; \
#   ya pack -a dedukun/bookmarks; \
#   ya pack -a yazi-rs/plugins:chmod; \
#   ya pack -a Lil-Dank/lazygit; \
#   ya pack -a yazi-rs/plugins:smart-filter; \
#   ya pack -a yazi-rs/plugins:git; \
#   ya pack -a Rolv-Apneseth/starship
# 
# # Create symlinks to programs, overwriting default programs.
# RUN ln -s $(which fdfind) ~/.local/bin/fd; \
#   ln -s $(which ast-grep) ~/.local/bin/sg; \
#   ln -s $(which batcat) ~/.local/bin/bat
# 
# # Install global packages.
# # RUN pnpm install -g turbo
# RUN pnpm install -g tree-node-cli
# 
# # Print tool versions
# RUN bash --version | head -n 1; \
#   git --version; \
#   curl --version; \
#   wget --version
# 
# # Print package versions.
# # nvm, npm must be called in same RUN as nvm.sh, to access the shell variables set there.
# RUN node --version; \
#   npm --version; \
#   pnpm --version; \
#   bun --version
# 
# # Print package binaray paths, to verify that the right binaries are used.
# RUN which node; \
#   which npm; \
#   which pnpm; \
#   which bun

# devcontainer Default ENTRYPOINT and CMD
# ENTRYPOINT ["/bin/sh", "-c", "echo Container started trap \"exit 0\" 15\n \n exec \"$@\"\n while sleep 1 & wait $!; do :; done", "-"]
# CMD ["/bin/sh", "-c", "while sleep 1000; do :; done"]
# ${@} allows us to take whatever extra args were passed to /bin/sh, and supply those same arguments to our script.
COPY --chmod=0755 entrypoint.sh .
# RUN chmod +x /entrypoint.sh

# WORKS, used prior to adding Docker in Docker.
# ENTRYPOINT ["/bin/sh", "-c"]
# CMD ["exec /entrypoint.sh \"${@}\"", "--"]

# IMPORTANT NOTES
# ================================
# - Finally, we execute the command passed in as argument to this script, which for docker is: sleep infinity.
# - Since this command is run by a bash shell inside the container (the default shell is set in the Dockerfile),
#   sleep will block that shell from exiting, thus keep the container running until it is stopped.
# - To see the processes running in the container: ps aux
#   - a: Show processes from all users.
#   - u: Show user/owner of process.
#   - x: Include processes not associated with a terminal, like system services.
# - Docker will create a new process with PID 1, which calls /sbin/docker-init -- ENTRYPOINT command/script,
#   where -- is present to signal end of command options, aka. flags, so ENTRYPOINT command is not interpreted as flags to docker-init.
# - The ENTRYPOINT script will be executed in a NEW sub-shell, e.g. with PID 7, as is always the case when one script calls another script.
# - The ENTRYPOINT script will use CMD command(s) as arguments, which in this case is: sleep infinity.
# - When the ENTRYPOINT script runs, it will execute its passed in arguments as shell commands, with: exec $@.
# - If exec had not been present, the shell running the ENTRYPOINT script, i.e. PID 7, would have spawned yet another sub-shell to run CMD command(s): sleep infinity.
# - Instead, with exec, the current shell running the ENTRYPOINT script, i.e. PID 7, will be replaced by the shell executing the sleep command.
# - The sleep infinity command will keep that shell, i.e. PID 7, running forever, until the container is shut down.
# - IMPORTANT: These shell processes are not associated with a terminal, instead they are so called daemon processes, which run in the background.
# - If sleep infinity proccess was assiciated with a terminal, that terminal would have been blocked, i.e. frozen,
#   because the sleep command makes the shell wait for the given period.
# - So, now we have a container running a shell indefinitely in the background, which keeps the container alive.
# - Remember: Containers are only alive as long as the commands they are made to execute, with ENTRYPOINT and CMD, are running.
# - As a next step, we may attach VS Code to the container, or execute another command within the container from the outside,
#   e.g. docker exec -it <containerId> bash, which will open a bash shell within the container.
# - When VS Code is attached to the container, it will run various files with node, from /tmp/ folder,
#   presumably to run all the extensions and similar.
# - Preferrably, execute the command: docker exec -it <containerId> zsh, to open a ZSH shell with a terminal inside the container,
#   then cd to the project folder, then run nvim from there.
# - Type "exit" to get out of the container.

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# OTHER OPTIONS
# ================================
# Install global packages
# RUN pnpm install -g commitizen turbo

# ENV HOME_DIR="/home/$USERNAME/"
# Not needed, as there are no commands after this.
# WORKDIR "/home/$USERNAME/nfront"

# COPY . .
# RUN pnpm build

# FROM ubuntu:latest as runner
# WORKDIR /code

# COPY --from=builder /code/package.json
# COPY --from=builder /code/yarn.lock .
# COPY --from=builder /code/next.config.js ./
# COPY --from=builder /code/public ./public
# COPY --from=builder /code/public ./public
