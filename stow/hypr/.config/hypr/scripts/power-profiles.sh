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

  current_index=0
  for i in "${!profiles[@]}"; do
    if [ "${profiles[$i]}" = "$current" ]; then
      current_index=$i
      break
    fi
  done

  next_index=$(( (current_index + 1) % ${#profiles[@]} ))
  set_profile "${profiles[$next_index]}"
}

get_battery() {
  local bat
  bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
  [ -z "$bat" ] && return
  capacity=$(cat "$bat/capacity" 2>/dev/null)
  status=$(cat "$bat/status" 2>/dev/null)
  echo "$capacity|$status"
}

format_output() {
  local profile="$1"
  local icon="" label=""

  case "$profile" in
    "performance") icon="\uf135"; label="Performance" ;;
    "balanced")    icon="\uf24e"; label="Balanced" ;;
    "power-saver") icon="\uf06c"; label="Power Saver" ;;
    *)             icon="\uf0e7"; label="$profile" ;;
  esac

  local bat cap st bolt=""
  bat=$(get_battery)
  cap="${bat%%|*}"
  st="${bat##*|}"
  [ "$st" = "Charging" ] && bolt="\uf0e7 "

  local text tooltip class="power-$profile"
  if [ -n "$cap" ]; then
    text=$(printf '%b %b%s%%' "$icon" "$bolt" "$cap")
    tooltip="$label\\n$st — $cap%"
    if [ "$cap" -le 15 ] && [ "$st" != "Charging" ]; then
      class="$class critical"
    elif [ "$cap" -le 30 ] && [ "$st" != "Charging" ]; then
      class="$class warning"
    fi
  else
    text=$(printf '%b' "$icon")
    tooltip="$label"
  fi

  printf '{"text":"%s","tooltip":"%s","class":"%s","alt":"%s"}\n' "$text" "$tooltip" "$class" "$profile"
}

main() {
  case "${1:-}" in
    "toggle") toggle_profile ;;
    "set")    [ -n "${2:-}" ] && set_profile "$2" ;;
    "list")   get_profiles_list ;;
    *)
      profile=$(get_current_profile)
      if [ -n "$profile" ]; then
        format_output "$profile"
      else
        printf '{"text":"\\uf0e7","tooltip":"Power profiles unavailable","class":"power-unknown"}\n'
      fi
      ;;
  esac
}

main "$@"
