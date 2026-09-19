#!/usr/bin/env bash
#  _              _     _           _ _
# | | _____ _   _| |__ (_)_ __   __| (_)_ __   __ _ ___
# | |/ / _ \ | | | '_ \| | '_ \ / _` | | '_ \ / _` / __|
# |   <  __/ |_| | |_) | | | | | (_| | | | | | (_| \__ \
# |_|\_\___|\__, |_.__/|_|_| |_|\__,_|_|_| |_|\__, |___/
#           |___/                             |___/
#
# -----------------------------------------------------
# List registered keybindings with their `description` flag
# (set in conf/keybindings/*.lua) from `hyprctl binds`.
# -----------------------------------------------------

keybinds=$(hyprctl -j binds | jq -r '
  .[]
  | select(.has_description)
  | . as $bind
  | [ [64, "SUPER"], [4, "CTRL"], [8, "ALT"], [1, "SHIFT"] ]
  | map(select(($bind.modmask / .[0] | floor) % 2 == 1) | .[1])
  | . + [$bind.key]
  | "\(join(" + "))\r\($bind.description)"
')

sleep 0.2
wofi --dmenu --insensitive --allow-markup --prompt="Keybinds" <<<"$keybinds"
