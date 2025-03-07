#!/usr/bin/env bash

echo "Running print_versions.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

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
