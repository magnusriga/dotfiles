#!/usr/bin/env bash

# ==========================================================
# Post Setup Script - Run after main bootstrap setup
# ==========================================================
echo "Running post_setup.sh as $(whoami), with HOME $HOME and USER $USER."

# ==========================================================
# Get Script Path.
# ==========================================================
SCRIPTPATH="$( cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 ; pwd -P )/"

echo "cd to SCRIPTPATH: $SCRIPTPATH"
cd "$SCRIPTPATH" || return

# ==========================================================
# Move Claude Code to Local Install
# ==========================================================
echo "Starting Claude Code migration..."

tmux new-session -d -s migrate 'claude migrate-installer'

for i in {1..3}; do
    sleep 2
    echo "Sending Enter $i/3..."
    tmux send-keys -t migrate Enter
done

echo "Migration completed! Session will close automatically."
