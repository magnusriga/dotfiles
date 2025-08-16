# ================================================================
# Set Folder for ZSH startup files, etc.
# Must be set in $HOME startup file, for ZSH to pick it up,
# and thus load other startup files.
# ================================================================
export ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh
# export SHELL_DEBUG=1
[[ -n "$SHELL_DEBUG" ]] && echo "Running .zshenv, sourcing .zprofile if not done before..."

# ================================================================
# Handle .zprofile sourcing for non-login shells (Linux terminals)
# ================================================================
if [[ ! -o login ]] && [ -z "$ZSH_PROFILE_SOURCED" ] && [ -f "$ZDOTDIR/.zprofile" ]; then
  [[ -n "$SHELL_DEBUG" ]] && echo "In .zshenv, sourcing .zprofile..."
  source "$ZDOTDIR/.zprofile"
  [[ -n "$SHELL_DEBUG" ]] && echo "In .zshenv, done sourcing .zprofile, setting ZSH_PROFILE_SOURCED to 1."
  export ZSH_PROFILE_SOURCED=1
fi
