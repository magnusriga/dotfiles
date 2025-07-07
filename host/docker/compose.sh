#!/bin/bash

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

# Reset OPTIND, used by getops, to 0.
# Allows script to be sourced.
export OPTIND=0

script_name=$0
usage() { echo "Usage: $0 [-e <dev|prod>] [-h] -d|u|b|s|l|c" 1>&2; }
help() {
  echo "  -h  Display help message."
  echo "  -b  Build Docker image."
  echo "  -u  Docker compose up."
  echo "  -d  Docker compose down."
  echo "  -r  Docker compose restart."
  echo "  -s  Enter container shell (zsh)."
  echo "  -l  Show container logs."
  echo "  -c  Show container status."
  echo "  -e  Environment: dev or prod."
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

while getopts "hbdurslc" opt; do
  case ${opt} in
  h)
    usage
    help
    Exit 0 || return 0
    ;;
  b)
    # Build Docker image.
    echo "Building Docker image."
    docker compose --progress plain -f "${ROOTDIR}/docker-compose.yml" build --no-cache
    docker image ls
    ;;
  d)
    # Stop containers.
    echo "Taking down docker container."
    # docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" up -d --build
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" down
    ;;
  u)
    # Start docker containers.
    echo "Starting docker containers."
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" up -d
    ;;
  r)
    # Restart containers.
    echo "Restarting docker containers."
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" restart
    ;;
  s)
    # Enter container shell.
    echo "Entering container with zsh shell..."
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" exec nfront zsh
    ;;
  l)
    # Show container logs.
    echo "Showing container logs..."
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" logs -f nfront
    ;;
  c)
    # Show container status.
    echo "Container status:"
    docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" ps
    ;;
  \?)
    echo "Invalid option: $OPTARG" 1>&2
    usage
    Exit 1 || return 1
    ;;
  :)
    echo "Invalid option: $OPTARG requires an argument" 1>&2
    usage
    Exit 1 || return 1
    ;;
  esac
done

# List docker containers.
docker ps -a
