#!/usr/bin/env sh

# ================================================================
# Setup and launch tmux.
# ================================================================
# ----------------------------------------------------------------
# Notes
# ----------------------------------------------------------------
# - Panes are indexed from 0, within a window (each has a unique index).
# - TMUX_PANE however, is globel, meaning third pane in second window has TMUX_PANE=4.
# ----------------------------------------------------------------
SESSION_NAME="main"
if [ -z ${TMUX+x} ]; then
  echo "Not attached to tmux."
  # ================================================================
  # Runs if tmux is not attached.
  # ================================================================

  # ================================================================
  # If tmux session does not exist, create new session, windows and panes.
  # If tmux session exists, attach to it without creating windows.
  # ================================================================
  if ! tmux has-session -t$SESSION_NAME 2>/dev/null; then
    tmux new-session -nnvim -s$SESSION_NAME \; \
      new-window -d -ndev \; \
      split-window -dh -t$SESSION_NAME:1.0 \; \
      split-window -dv -t$SESSION_NAME:1.1 \;
  else
    tmux attach -t$SESSION_NAME
  fi
else
  # ================================================================
  # Runs if tmux is attached.
  # ================================================================

  # ================================================================
  # Open specific windows in specific panes.
  # ================================================================
  if [ "$TMUX_PANE" = "%0" ]; then
    echo "Shell is currently in the first pane."
    # ================================================================
    # Start nvim, unless already running.
    # ================================================================
    if ! tmux list-panes -F "#{pane_current_command}" -t$SESSION_NAME | grep -q "nvim"; then
      tmux send-keys -t$SESSION_NAME:0.0 "source ~/launch-session.sh" C-m
    fi
  elif [ "$TMUX_PANE" = "%1" ]; then
    echo "Shell is currently in the second pane."
    cd ~/nfront/ || cd ~ || return
    # ================================================================
    # This pane should just run interactive shell at start.
    # ================================================================
  elif [ "$TMUX_PANE" = "%2" ]; then
    echo "Shell is currently in the third pane."
    cd ~/nfront/ || cd ~ || return
    # ================================================================
    # This pane should just run interactive shell at start.
    # ================================================================
  elif [ "$TMUX_PANE" = "%3" ]; then
    echo "Shell is currently in the fourth pane."
    if ! tmux list-panes -aF "#{pane_current_command}" | grep -q "top"; then
      echo "Running function to update package managers and upgrade installed packages..."
      update-and-upgrade-all-packages

      # ================================================================
      # Start top, unless already running.
      # ================================================================
      echo "Starting top..."
      tmux send-keys -t$SESSION_NAME:1.2 "top" C-m
      tmux select-pane -t$SESSION_NAME:1.0
    fi
  fi
fi
