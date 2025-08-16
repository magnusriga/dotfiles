#!/usr/bin/env bash

my_cache_folder="$HOME/.cache/my/hyprland-dotfiles"

generated_versions="$my_cache_folder/wallpaper-generated"

rm "$generated_versions"/*
echo ":: Wallpaper cache cleared"
notify-send "Wallpaper cache cleared"
