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

# Export all sourced environment variables, so they are available in child processes.
set -a

# Path to directory of this script.
ROOTDIR="$(cd "$(dirname "$0")" && pwd)"
echo "ROOTDIR is ${ROOTDIR}."

# Sourcing environment variables, making them accessible in `docker-compose.yml`.
echo "Sourcing environment variables, making them accessible in \`docker-compose.yml\`."
source "${ROOTDIR}/envs/docker-dev.env"

# Run Docker container.
echo "Running Docker container."
docker compose --progress plain --project-name nfront_devcontainer -f "${ROOTDIR}/docker-compose.yml" up -d --build

# List Docker images.
docker image ls
