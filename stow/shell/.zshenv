# ================================================================
# Set Folder for ZSH startup files, etc.
# Must be set in $HOME startup file, for ZSH to pick it up,
# and thus load other startup files.
# ================================================================
export ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh

# ================================================================
# Handle .zprofile sourcing for non-login shells (Linux terminals)
# ================================================================
if [[ ! -o login ]] && [ -z "$ZSH_PROFILE_SOURCED" ] && [ -f "$ZDOTDIR/.zprofile" ]; then
  source "$ZDOTDIR/.zprofile"
  export ZSH_PROFILE_SOURCED=1
fi
