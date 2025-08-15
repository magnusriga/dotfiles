#!/usr/bin/env bash

# Settings menu script for waybar
# Uses wofi to display a menu with system settings

options="󰤨  WiFi Settings
󰂲  Bluetooth
✈  Airplane Mode
󰍁  Display Settings
󰕾  Sound Settings
󰌾  Lock Screen
󰗼  Logout
󰜉  Reboot
󰐥  Shutdown"

chosen="$(echo -e "$options" | wofi --dmenu --prompt "Settings" --width 300 --height 400)"

case $chosen in
  "󰤨  WiFi Settings")
    # Use terminal-based nmtui if GUI tool not available
    if command -v nm-connection-editor &> /dev/null; then
      nm-connection-editor &
    else
      ghostty -e nmtui &
    fi
    ;;
  "󰂲  Bluetooth")
    if command -v blueman-manager &> /dev/null; then
      blueman-manager &
    else
      ghostty -e bluetoothctl &
    fi
    ;;
  "✈  Airplane Mode")
    # Toggle airplane mode (rfkill)
    if rfkill list all | grep -q "Soft blocked: yes"; then
      rfkill unblock all
      notify-send "Airplane Mode" "Disabled" -i network-wireless
    else
      rfkill block all
      notify-send "Airplane Mode" "Enabled" -i airplane-mode
    fi
    ;;
  "󰍁  Display Settings")
    if command -v nwg-displays &> /dev/null; then
      nwg-displays &
    elif command -v wdisplays &> /dev/null; then
      wdisplays &
    elif command -v arandr &> /dev/null; then
      arandr &
    else
      notify-send "Display Settings" "No display configuration tool found"
    fi
    ;;
  "󰕾  Sound Settings")
    pavucontrol &
    ;;
  "󰌾  Lock Screen")
    hyprlock &
    ;;
  "󰗼  Logout")
    hyprctl dispatch exit
    ;;
  "󰜉  Reboot")
    systemctl reboot
    ;;
  "󰐥  Shutdown")
    systemctl poweroff
    ;;
esac