# Multi-Distribution Docker Setup

This Docker setup supports building dotfiles containers for multiple Linux distributions, automatically detecting and installing the appropriate packages for each distribution.

## Supported Distributions

- **Arch Linux**: `menci/archlinuxarm` (default)
- **Ubuntu**: `ubuntu:24.04`

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build for Arch Linux (default)
./host/docker/compose.sh -b

# Build for Ubuntu with verbose output
./host/docker/compose.sh -t ubuntu -v -b

# Build and push to registry
./host/docker/compose.sh -t arch -b -p

# Start container
./host/docker/compose.sh -u

# Enter container shell
./host/docker/compose.sh -s
```

### Enhanced Features

The compose.sh script now includes:

- **Multi-distribution support**: `-t arch|ubuntu`
- **Registry push**: `-p` to push after successful build
- **Verbose output**: `-v` for detailed build information
- **Colored output**: Enhanced UX with colored status messages
- **Error handling**: Proper exit codes and error reporting
- **Image information**: Displays image details after build

### Manual Docker Build

```bash
# Build for Arch Linux
docker build \
  --build-arg DISTRO=arch \
  -t dotfiles-arch \
  -f host/docker/Dockerfile \
  .

# Build for Ubuntu
docker build \
  --build-arg DISTRO=ubuntu \
  -t dotfiles-ubuntu \
  -f host/docker/Dockerfile \
  .
```

## Build Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `DISTRO` | Target distribution (`arch` or `ubuntu`) | `arch` |
| `ARCH_IMAGE` | Arch Linux base image | `menci/archlinuxarm` |
| `UBUNTU_IMAGE` | Ubuntu base image | `ubuntu:24.04` |
| `USERNAME` | Container username | `nfu` |
| `USER_UID` | User ID | `1000` |
| `USER_GID` | Group ID | `1000` |

## How It Works

The Dockerfile uses multi-stage builds and conditional logic to:

1. **Base Image Selection**: Uses build arguments to select the appropriate base image
2. **Package Installation**: Installs distribution-specific packages using the appropriate package manager
3. **Bootstrap Integration**: The `bootstrap.sh` script automatically detects the distribution and installs the correct packages
4. **SSH Configuration**: Sets up SSH daemon for both distributions
5. **User Setup**: Creates a non-root user with sudo privileges

## Distribution-Specific Features

### Arch Linux
- Uses `pacman` package manager
- Includes custom `pacman.conf` for ARM compatibility
- Installs AUR packages via bootstrap script
- Uses `glibc-locales` for locale support

### Ubuntu
- Uses `apt` package manager
- Includes additional repositories (GitHub CLI, Charm, etc.)
- Uses `locales` package for locale support
- Installs `snap` packages where appropriate

## Environment Variables

The following environment variables are set in the container:

- `USER`: Container username
- `DOCKER_BUILD`: Set to `1` to indicate Docker build environment
- `DISTRO`: The distribution being used (`arch` or `ubuntu`)
- `DEBIAN_FRONTEND`: Set to `noninteractive` for Ubuntu builds

## Running the Container

```bash
# Run interactively
docker run -it --rm dotfiles-arch

# Run with SSH access
docker run -d -p 2222:22 --name dotfiles-container dotfiles-arch

# Connect via SSH
ssh -p 2222 nfu@localhost
```

## Customization

### Adding New Distributions

1. Add the distribution detection logic to `scripts/setup_packages.sh`
2. Update the Dockerfile to include distribution-specific setup
3. Add the new distribution to the build script
4. Test the build and package installation

### Custom Base Images

You can use custom base images by overriding the build arguments:

```bash
docker build \
  --build-arg DISTRO=arch \
  --build-arg ARCH_IMAGE=your-custom-arch-image \
  -t dotfiles-custom \
  -f host/docker/Dockerfile \
  .
```

## Troubleshooting

### Common Issues

1. **Package conflicts**: Some packages may have different names between distributions
2. **Permission errors**: Ensure the user has proper sudo privileges
3. **Network issues**: Some installations require internet access during build

### Build Failures

If the build fails:

1. Check the distribution is supported
2. Verify the base image is available
3. Ensure all required files are present in the context
4. Check the bootstrap script logs for specific errors

### Debugging

Enable verbose output for detailed build information:

```bash
./host/docker/build.sh -v -d ubuntu
```

## Files

- `Dockerfile`: Multi-distribution Docker configuration
- `compose.sh`: Docker Compose wrapper with distribution selection
- `docker-compose.yml`: Docker Compose configuration
- `pacman.conf`: Custom Pacman configuration for Arch Linux
- `docker-init.sh`: Container initialization script
- `envs/docker-dev.env`: Environment variables including distribution config
- `README.md`: This documentation

## Integration with Bootstrap Script

The Docker setup seamlessly integrates with the existing `bootstrap.sh` script:

- The script automatically detects it's running in a Docker environment
- Distribution-specific package installation is handled transparently
- All dotfiles are properly installed and configured
- The container is ready to use after the build completes