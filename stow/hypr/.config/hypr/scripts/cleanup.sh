#!/usr/bin/env bash
#   ____ _
#  / ___| | ___  __ _ _ __  _   _ _ __
# | |   | |/ _ \/ _` | '_ \| | | | '_ \
# | |___| |  __/ (_| | | | | |_| | |_) |
#  \____|_|\___|\__,_|_| |_|\__,_| .__/
#                                |_|
#

# Remove gamemode flag
if [ -f ~/.cache/gamemode ]; then
  rm ~/.cache/gamemode
  echo ":: ~/.cache/gamemode removed"
fi

# Cleanup AUR cache
clear
aur_helper="$(cat ~/.config/my/settings/aur.sh)"
figlet -f smslant "Cleanup"
echo
# --noconfirm: this script runs via Hyprland exec-once, where stdin is
# attached to a TTY hidden under the compositor — interactive prompts would
# block session startup invisibly.
$aur_helper -Scc --noconfirm
