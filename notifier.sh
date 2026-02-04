#!/usr/bin/env bash
# =============================================================================
# Script:    notifier.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Monitor journalctl for session events and trigger notifier scripts.
# Parameters:
#   $1 - Action to match (e.g., opened, closed).
#   $2 - Notifier type (e.g., terminal, telegram, mail).
#   $3 - Cooldown interval in seconds between notifications (optional, default: 10).
# =============================================================================
set -euo pipefail

NOTIFY_DIR="$(dirname "$0")/notify"
ACTION_MATCH="${1:-}"
NOTIFY_TYPE="${2:-}"
POLL_INTERVAL="${3:-10}"
NOTIFY_TYPE_LOWER=""

# List of usernames to exclude from notifications.
EXCLUDED_USERS=("root" "debian")

if [[ -z "$ACTION_MATCH" || -z "$NOTIFY_TYPE" ]]; then
  echo "Usage: $0 <action> <notifier> [poll-interval-seconds]" >&2
  echo "Action should match the session keyword (e.g., opened, closed)." >&2
  echo "Notifier should match a script in: $NOTIFY_DIR (e.g., terminal, telegram, mail)." >&2
  exit 1
fi

if [[ ! "$POLL_INTERVAL" =~ ^[0-9]+$ || "$POLL_INTERVAL" -le 0 ]]; then
  echo "Poll interval must be a positive integer (seconds)." >&2
  exit 1
fi

NOTIFY_TYPE_LOWER=$(tr '[:upper:]' '[:lower:]' <<<"$NOTIFY_TYPE")
NOTIFY_SCRIPT="${NOTIFY_DIR}/${NOTIFY_TYPE_LOWER}.sh"

if [[ ! -x "$NOTIFY_SCRIPT" ]]; then
  echo "Notify script not found or not executable: $NOTIFY_SCRIPT" >&2
  exit 1
fi

# Load notifier configuration and message formatter.
# shellcheck source=/dev/null
source "$NOTIFY_SCRIPT"
if ! declare -f build_message >/dev/null 2>&1; then
  echo "Notify script does not define build_message: $NOTIFY_SCRIPT" >&2
  exit 1
fi

is_excluded_user() {
  # Description: Check if a username is in the exclusion list.
  # Parameters:
  #   $1 - Username to check.
  local user="$1"
  local excluded
  for excluded in "${EXCLUDED_USERS[@]}"; do
    if [[ "$user" == "$excluded" ]]; then
      return 0
    fi
  done
  return 1
}

process_login_line() {
  # Description: Parse a log line, extract the username, and notify on session events.
  # Parameters:
  #   $1 - Log line to process.
  local line="$1"
  local user
  user=$(sed -n 's/.* by \([^ ]\+\).*/\1/p' <<<"$line")
  if [[ -z "$user" ]]; then
    return 0
  fi
  if is_excluded_user "$user"; then
    return 0
  fi
  local message
  message=$(build_message "$ACTION_MATCH" "$user" "$line")
  printf '%s\n' "$message"
  "$NOTIFY_SCRIPT" "$ACTION_MATCH" "$user" "$line"
}

if command -v journalctl >/dev/null 2>&1; then
  if ! journalctl --no-pager -n 1 -o cat >/dev/null 2>&1; then
    echo "journalctl access denied." >&2
    echo "Run with sudo or add the user to the adm group to read auth logs." >&2
    exit 1
  fi
else
  echo "journalctl not available." >&2
  exit 1
fi

echo "Watching systemd journal for session events (${ACTION_MATCH}) from now on..."

# Follow the journal from now on and detect session events.
journalctl -n 0 -f -o cat | while IFS= read -r line; do
  if [[ "$line" == *"session"* && "$line" == *"$ACTION_MATCH"* ]]; then
    process_login_line "$line"
    sleep "$POLL_INTERVAL"
  fi
done
