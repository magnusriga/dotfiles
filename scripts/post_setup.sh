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
echo "Starting Claude Code migration to local install..."

# ---------------------------------------------------------
# Check and Install Claude if needed
# ---------------------------------------------------------
echo "Checking for Claude installation..."

# Check if claude is installed globally
if ! pnpm list -g | grep -q 'claude'; then
  echo "Claude not found. Installing Claude..."
  pnpm add -g --allow-build=@anthropic-ai/claude-code @anthropic-ai/claude-code
else
  echo "Claude is installed, proceeding with migration."
fi

# Check if already migrated.
MIGRATION_CHECK=$(claude migrate-installer 2>&1 | head -n1)
if [[ "$MIGRATION_CHECK" == *"Already running from local installation"* ]]; then
  echo "Already running from local installation. No migration needed."
  return 0
fi

tmux new-session -d -s migrate 'claude migrate-installer'

for i in {1..3}; do
    sleep 2
    echo "Sending Enter $i/3..."
    tmux send-keys -t migrate Enter
done

# Show results.
# echo "Migration output:"
# tmux capture-pane -t migrate -p

# End session.
echo "Migration completed, ending session."
tmux kill-session -t migrate

