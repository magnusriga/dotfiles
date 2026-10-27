#!/usr/bin/env bash

# ==========================================================
# Shell helpers shared by the setup scripts.
# Sourced by `setup_main.sh`, and by every script that needs a helper
# so each script also works when sourced on its own.
# ==========================================================

# Resolve latest release tag of GitHub repository `owner/repo`.
# - Follows the `releases/latest` redirect instead of calling `api.github.com`,
#   which is rate limited (60 unauthenticated requests per hour).
# - Prints tag exactly as GitHub names it (e.g. `v1.2.3`, `tectonic@0.17.0`).
# - Returns 1, printing nothing, when no release tag can be resolved.
function github_latest_tag() {
  local url
  url=$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest") || return 1
  case "$url" in
  */releases/tag/*) echo "${url##*/releases/tag/}" ;;
  *) return 1 ;;
  esac
}
