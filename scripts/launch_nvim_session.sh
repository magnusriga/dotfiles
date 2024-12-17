#!/bin/bash

# if [ -n ${TMUX+x} ]; then
#   # Runs if tmux is attached.
#   echo "ATTACHED: $TMUX"
# fi

# ================================================================
# Launch nvim and restore session.
# ================================================================
echo "Launching nvim..."
cd $HOME/nfront
NVIM_SESSION_FILE="$HOME/.vim/sessions/shutdown_session.vim"
if [ -f $NVIM_SESSION_FILE ]; then
  nvim -c "source $NVIM_SESSION_FILE"
else
  nvim
fi
