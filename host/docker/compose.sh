#!/bin/bash

# ================================================================================================
# Multi-distribution Docker Compose wrapper with enhanced functionality
# ================================================================================================
# Features:
# - Multi-distribution support (Arch Linux, Ubuntu)
# - Registry push functionality
# - Colored output for better UX
# - Verbose build options
# - Image information display
#
# ================================================================================================
# HOW THIS SCRIPT WORKS
# ================================================================================================
#
# - "set -a" and "source" makes environment variables from sourced `.env` file in subshells.
# - Thus, those variables are available inside `docker-compose.yml`.
# - Passed on from `docker-compose.yml` to Dockerfile build via `args`.
# - Passed on from `docker-compose.yml` to running container via `environment`.
# - See `docker-compose.yml` for more info.
#
# - Image built by compose file gets name: `127.0.0.1:5000/nfront`.
# - Taggig image as `hostname:port`, in case we add other Docker nodes to swarm,
#   so they can acces image on registry service on manager node.
# - Must then run registry service on `127.0.0.1:5000`
#   (see: https://docs.docker.com/engine/swarm/stack-deploy/#set-up-a-docker-registry).
#
# - `-d`: Container is run in background (detached) mode.
# - `--build`: Rebuild image, but use cache.
# - `-V`: Rebuild volumes, i.e. all `node_modules` folders.
#
# - Stack name: `nfront`.
# - Service will be referenced by: <SATCKNAME>_<SERVICENAME>, where <SERVICENAME> is from compose-file.
#
# ================================================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
  echo -e "${BLUE}[STEP]${NC} $1"
}

# Reset OPTIND, used by getops, to 0.
# Allows script to be sourced.
export OPTIND=0

script_name=$0
usage() { echo "Usage: $0 [-e <dev|prod>] [-t <arch|ubuntu>] [-v] [-p] [-h] -d|u|b|s|l|c" 1>&2; }
help() {
  echo "  -h  Display help message."
  echo "  -b  Build Docker image."
  echo "  -u  Docker compose up."
  echo "  -d  Docker compose down."
  echo "  -r  Docker compose restart."
  echo "  -s  Enter container login shell (\`zsh -l\`)."
  echo "  -l  Show container logs."
  echo "  -c  Show container status."
  echo "  -e  Environment: dev or prod."
  echo "  -t  Distribution: arch or ubuntu (default: arch)."
  echo "  -v  Enable verbose output."
  echo "  -p  Push image to registry after build."
}
Exit() {
  # Return if sourced, otherwise exit.
  [ "$script_name" = "${BASH_SOURCE[0]}" ] && exit "$1"
  return 1
}

# Abort if option not set.
if [ $# -eq 0 ]; then
  echo "Error: No option set."
  usage
  help
  Exit 1 || return 1
fi

# Export all sourced environment variables, so they are available in child processes.
set -a

# Path to directory of this script.
ROOTDIR="$(cd "$(dirname "$0")" && pwd)"
echo "ROOTDIR is ${ROOTDIR}."

# Sourcing environment variables, making them accessible in `docker-compose.yml`.
echo "Sourcing environment variables, making them accessible in \`docker-compose.yml\`."
source "${ROOTDIR}/envs/docker-dev.env"

# ================================================
# Detect host architecture and set TARGETARCH
# ================================================
HOST_ARCH=$(uname -m)
case $HOST_ARCH in
x86_64)
  export TARGETARCH="amd64"
  ;;
aarch64 | arm64)
  export TARGETARCH="arm64"
  ;;
*)
  print_warning "Unsupported architecture: $HOST_ARCH, defaulting to amd64"
  export TARGETARCH="amd64"
  ;;
esac
print_info "Host architecture: $HOST_ARCH -> Docker TARGETARCH: $TARGETARCH"

# Initialize variables
VERBOSE=false
PUSH_IMAGE=false
PROGRESS_FLAG=(--progress plain)

while getopts "hbdurslct:vp" opt; do
  case ${opt} in
  h)
    usage
    help
    Exit 0 || return 0
    ;;
  b)
    # Build Docker image.
    if [[ "$VERBOSE" == "true" ]]; then
      PROGRESS_FLAG=(--progress plain)
      print_step "Building Docker image with verbose output for distribution: ${DISTRO:-arch}"
    else
      print_step "Building Docker image for distribution: ${DISTRO:-arch}"
    fi

    if docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" build --no-cache; then
      print_info "Build completed successfully!"

      # Show image info
      print_info "Image details:"
      docker images "127.0.0.1:5000/nfront-dev" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

      # Push if requested
      if [[ "$PUSH_IMAGE" == "true" ]]; then
        print_step "Pushing image to registry..."
        if docker push "127.0.0.1:5000/nfront-dev"; then
          print_info "Push completed successfully!"
        else
          print_error "Push failed!"
          Exit 1 || return 1
        fi
      fi
    else
      print_error "Build failed!"
      Exit 1 || return 1
    fi
    ;;
  d)
    # Stop containers.
    print_step "Taking down docker container."
    if docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" down; then
      print_info "Container stopped successfully."
    else
      print_error "Failed to stop container."
    fi
    ;;
  u)
    # Start docker containers.
    print_step "Starting docker containers for distribution: ${DISTRO:-arch}"
    if docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" up -d; then
      print_info "Container started successfully."
    else
      print_error "Failed to start container."
    fi
    ;;
  r)
    # Restart containers.
    print_step "Restarting docker containers."
    if docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" restart; then
      print_info "Container restarted successfully."
    else
      print_error "Failed to restart container."
    fi
    ;;
  s)
    # Enter container shell.
    print_step "Entering container with zsh login shell..."
    docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" exec -e TERM -e DISPLAY nfront zsh -l
    ;;
  l)
    # Show container logs.
    print_step "Showing container logs..."
    # shellcheck disable=SC2068,SC2086
    docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" logs -f nfront
    ;;
  c)
    # Show container status.
    print_info "Container status:"
    # shellcheck disable=SC2068,SC2086
    docker compose "${PROGRESS_FLAG[@]}" --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" ps
    ;;
  t)
    # Set distribution
    DISTRO="$OPTARG"
    if [[ "$DISTRO" != "arch" && "$DISTRO" != "ubuntu" ]]; then
      print_error "Invalid distribution '$DISTRO'. Must be 'arch' or 'ubuntu'."
      Exit 1 || return 1
    fi
    export DISTRO
    print_info "Target distribution set to: $DISTRO"
    ;;
  v)
    # Enable verbose output
    VERBOSE=true
    print_info "Verbose output enabled."
    ;;
  p)
    # Enable push to registry
    PUSH_IMAGE=true
    print_info "Registry push enabled."
    ;;
  \?)
    print_error "Invalid option: $OPTARG"
    usage
    Exit 1 || return 1
    ;;
  :)
    print_error "Invalid option: $OPTARG requires an argument"
    usage
    Exit 1 || return 1
    ;;
  esac
done

# List docker containers.
docker ps -a
