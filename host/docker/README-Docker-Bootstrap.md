# Docker Bootstrap for Dotfiles

This Docker setup provides a containerized version of the complete dotfiles development environment using the standard `bootstrap.sh` script.

## Quick Start

1. **Build and start the development environment:**
   ```bash
   ./compose.sh -b  # Build image
   ./compose.sh -u  # Start container
   ```

2. **Enter the development environment:**
   ```bash
   ./compose.sh -s
   ```

3. **Stop the environment:**
   ```bash
   ./compose.sh -d
   ```

## Commands

The `compose.sh` script provides several commands:

- `-b` - Build the Docker image
- `-u` - Start the container
- `-d` - Stop the container
- `-r` - Restart the container
- `-s` - Enter container shell (zsh)
- `-l` - Show container logs
- `-c` - Show container status
- `-h` - Show help message

## What's Included

The Docker bootstrap sets up a complete development environment with:

### Development Tools
- **Languages:** Node.js (via NVM), Rust (via rustup), Python
- **Package Managers:** PNPM, Cargo, pipx
- **Version Managers:** NVM for Node.js, rustup for Rust

### CLI Tools
- **File Management:** eza, yazi, trash-cli
- **Search & Navigation:** fzf, ripgrep, ast-grep, zoxide
- **Git Tools:** lazygit, delta, gh (GitHub CLI)
- **System Tools:** tmux, starship prompt, bat, jless
- **Development:** neovim, todocheck, pre-commit

### Shell Environment
- **Shell:** Zsh with Oh-My-Zsh
- **Plugins:** zsh-syntax-highlighting, zsh-autosuggestions, zsh-vi-mode
- **Prompt:** Starship with custom configuration
- **Terminal Integration:** Wezterm shell integration

### Configuration Management
- **Dotfiles:** Managed with GNU Stow
- **Fonts:** JetBrains Mono Nerd Font
- **Themes:** Catppuccin theme for various tools

## Architecture Support

The bootstrap script automatically detects and handles:
- **x86_64** (Intel/AMD)
- **aarch64** (ARM64, including Apple Silicon)

## Distribution Support

The setup works with:
- **Arch Linux** (primary, includes AUR packages)
- **Ubuntu/Debian** (fallback, standard packages only)

## Directory Structure

The container sets up the following directory structure:

```
/home/nfu/
├── .cargo/           # Rust toolchain
├── .config/          # Application configurations
├── .local/           # Local binaries and data
├── .nvm/             # Node Version Manager
├── dotfiles/         # Dotfiles repository
└── projects/         # Workspace for development projects
```

## Persistence

The following data is persisted across container restarts:
- Command history (zsh/bash)
- Docker socket (for Docker-in-Docker)

## Customization

### Mount Local Projects
To mount your local projects directory, uncomment and modify this line in `docker-compose-dotfiles.yml`:
```yaml
- ~/projects:/home/nfu/projects
```

### Development Mode
To edit dotfiles while using the container, uncomment this line:
```yaml
- ../..:/home/nfu/dotfiles-source
```

### Environment Variables
You can add custom environment variables in the `environment` section of `docker-compose-dotfiles.yml`.

## Troubleshooting

### Container Won't Start
Check the build logs:
```bash
./build-dotfiles.sh logs
```

### Permission Issues
Ensure your user has Docker permissions:
```bash
sudo usermod -aG docker $USER
# Then logout and login again
```

### Rebuild from Scratch
If you encounter issues, try rebuilding without cache:
```bash
./build-dotfiles.sh rebuild
```

### Clean Everything
To start completely fresh:
```bash
./build-dotfiles.sh clean
./build-dotfiles.sh up
```

## Development Workflow

1. **Start the environment:**
   ```bash
   ./build-dotfiles.sh up
   ```

2. **Enter the development shell:**
   ```bash
   ./build-dotfiles.sh shell
   ```

3. **Your development environment is ready!**
   - All tools are installed and configured
   - Dotfiles are applied
   - Shell is set to zsh with custom configuration
   - All paths are properly configured

4. **Work on your projects:**
   ```bash
   cd ~/projects  # or wherever your code is
   nvim .         # or your preferred editor
   ```

## Docker vs Host Bootstrap

The Docker setup uses the same `bootstrap.sh` script as the host environment with `--force` flag to skip interactive prompts. Key Docker adaptations:

1. **User Already Exists:** User creation is skipped automatically since user is created in Dockerfile
2. **Non-Interactive:** Runs with `--force` flag to avoid prompts
3. **Passwordless Sudo:** User has passwordless sudo configured in Dockerfile
4. **Same Logic:** Uses identical bootstrap logic as host environment

## Files Modified

- `Dockerfile` - Enhanced with dotfiles bootstrap integration
- `docker-compose.yml` - Updated to use dotfiles-enabled image
- `README-Docker-Bootstrap.md` - This documentation

The Docker setup provides the same complete development environment as the host bootstrap, but containerized for easy deployment and isolation.