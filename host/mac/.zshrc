echo "running zshrc"
# Ghostty shell integration for Bash. This should be at the top of your bashrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    echo "Ghostty shell integration runs automatically outside SSH, thus not called manyally here."
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# Unsure why ZSH does not default to `viins`,
# as EDITOR and VISUAL contains string `vi`.
# Thus, manually change to `viins` mode, from default `emacs`.
bindkey -v

# Bind sequence sent by ghostty for `Ctrl+[`, i.e. `^[[91;5u`,
# to `vi-cmd-mode`, with added benefit of no `KEYTIMEOUT` delay.
bindkey -M viins '^[[91;5u' vi-cmd-mode

# Ensure `^w` and `^h` deletes past last insert.
bindkey -M viins '^h' backward-delete-char
bindkey -M viins '^w' backward-kill-word

# Search command history for line starting with current line up to cursor.
# If line is empty, moves to next/previous event in history list.
# Overwrites default `self-insert` in mode `viins`.
# Overwrites default `down-history` in mode `vicmd`.
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Prevent blinking cursor.
function __set_beam_cursor {
    echo -ne '\e[6 q'
}

function __set_block_cursor {
    echo -ne '\e[2 q'
}

function zle-keymap-select {
  case $KEYMAP in
    vicmd) __set_block_cursor;;
    viins|main) __set_beam_cursor;;
  esac
}
zle -N zle-keymap-select

precmd_functions+=(__set_beam_cursor)

# Source environment variables.
source "$HOME/.env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.cargo/env"

# Initialize zoxide.
eval "$(zoxide init zsh)"
