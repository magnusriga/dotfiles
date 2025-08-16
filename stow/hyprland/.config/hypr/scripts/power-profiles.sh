#!/usr/bin/env bash

# Power Profiles Script for tuned-ppd
# Provides integration between tuned-ppd and waybar

get_current_profile() {
  profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | cut -d '"' -f 2)
  echo "$profile"
}

get_profiles_list() {
  busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles Profiles 2>/dev/null | grep -oP '"Profile" s "[^"]+"' | cut -d'"' -f4 | sort -u
}

set_profile() {
  local profile="$1"
  busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$profile" 2>/dev/null
}

toggle_profile() {
  current=$(get_current_profile)
  profiles=($(get_profiles_list))
  
  if [ ${#profiles[@]} -eq 0 ]; then
    profiles=("power-saver" "balanced" "performance")
  fi
  
  # Find current index
  current_index=0
  for i in "${!profiles[@]}"; do
    if [ "${profiles[$i]}" = "$current" ]; then
      current_index=$i
      break
    fi
  done
  
  # Get next profile
  next_index=$(( (current_index + 1) % ${#profiles[@]} ))
  next_profile="${profiles[$next_index]}"
  
  set_profile "$next_profile"
}

format_output() {
  local profile="$1"
  local icon=""
  local tooltip=""
  
  case "$profile" in
    "performance")
      icon=""
      tooltip="Performance Mode\nMaximum performance, higher power consumption"
      ;;
    "balanced")
      icon=""
      tooltip="Balanced Mode\nBalanced performance and power consumption"
      ;;
    "power-saver")
      icon=""
      tooltip="Power Saver Mode\nReduced performance, lower power consumption"
      ;;
    *)
      icon=""
      tooltip="Power Profile: $profile"
      ;;
  esac
  
  # Output JSON for waybar
  echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"power-$profile\",\"alt\":\"$profile\"}"
}

main() {
  case "${1:-}" in
    "toggle")
      toggle_profile
      ;;
    "set")
      if [ -n "${2:-}" ]; then
        set_profile "$2"
      fi
      ;;
    "list")
      get_profiles_list
      ;;
    *)
      # Default: output current status
      profile=$(get_current_profile)
      if [ -n "$profile" ]; then
        format_output "$profile"
      else
        echo "{\"text\":\"\",\"tooltip\":\"Power profiles unavailable\",\"class\":\"power-unknown\"}"
      fi
      ;;
  esac
}

main "$@"