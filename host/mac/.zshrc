[[ -n "$SHELL_DEBUG" ]] && echo "running zshrc"

# echo "Setting TERM to 'xterm-ghostty' manually, as Neovim termial otherwise uses 'xterm-256color'."
# export TERM=xterm-ghostty
# echo "Sourcing ghosty shell integration for ZSH: ${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration}"
# ls -la "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
# builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"

# Ghostty shell integration for Bash. This should be at the top of your bashrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "Ghostty shell integration runs automatically outside SSH, thus not called manyally here."
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# Unsure why ZSH does not default to `viins`,
# as EDITOR and VISUAL contains string `vi`.
# Thus, manually change to `viins` mode, from default `emacs`.
bindkey -v

# Bind sequence sent by ghostty for `Ctrl+[`, i.e. `^[[91;5u`,
# to `vi-cmd-mode`, with added benefit of no `KEYTIMEOUT` delay.
[[ ${TERM} == xterm-ghostty && ! -n "$TMUX" ]] && { [[ -n "$SHELL_DEBUG" ]] && echo "Setting: bindkey '^[[91;5u' vi-cmd-mode"; bindkey '^[[91;5u' vi-cmd-mode; }
KEYTIMEOUT=4
[[ -n "$TMUX" ]] && { [[ -n "$SHELL_DEBUG" ]] && echo "Setting: KEYTIMEOUT = $KEYTIMEOUT"; export KEYTIMEOUT=$KEYTIMEOUT; }

# Ensure `^w` and `^h` deletes past last insert.
bindkey -M viins '^h' backward-delete-char
bindkey -M viins '^w' backward-kill-word

# Search command history for line starting with current line up to cursor.
# If line is empty, moves to next/previous event in history list.
# Overwrites default `self-insert` in mode `viins`.
# Overwrites default `down-history` in mode `vicmd`.
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# ================================================================
# Set cursor to non-blinking bar|block, depending on ZSH vi-mode.
# ================================================================
function __set_bar_cursor {
    echo -ne '\e[6 q'
}

function __set_block_cursor {
    echo -ne '\e[2 q'
}

# - When keymap changes, i.e. when switching between Insert and Normal mode,
#   set cursor to bar|block, depending on new mode.
# - `KEYMAP`: Keymap being switched to, i.e. `main` | `viins` | `vicmd`.
# - Thus, when switching to `vicmd`, set cursor to block, and when switching to
#  `viins` or `main`, set cursor to bar.
function zle-keymap-select {
  case $KEYMAP in
    vicmd) __set_block_cursor;;
    viins|main) __set_bar_cursor;;
  esac
}
zle -N zle-keymap-select

# Start new lines with bar cursor, since, in ZSH vi-mode, each line starts in Insert mode.
# Not needed, when using `precmd`.
# function zle-line-init {
#     __set_bar_cursor
# }
# zle -N zle-line-init

# When prompt is redrawn, set cursor to bar.
precmd_functions+=__set_bar_cursor

# ================================================================
# iTerm2 Shell Integration for ZSH.
# ================================================================
export ZDOTDIR=$HOME
if [[ -e "${HOME}/.iterm2_shell_integration.zsh" && \
${TERM} == xterm-256color ]]; then
  [[ -n "$SHELL_DEBUG" ]] && echo "Sourcing iTerm shell integration..."
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Source environment variables.
# source "$HOME/.env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.cargo/env"

# Initialize zoxide.
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/Users/magnus/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
