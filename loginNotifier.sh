#!/usr/bin/env bash
# =============================================================================
# Script:    loginNotifier.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Monitor Debian auth logs for login events and trigger notifier scripts.
# Parameters:
#   None. Configure EXCLUDED_USERS and NOTIFY_SCRIPT paths below.
# =============================================================================
set -euo pipefail

LOG_FILE="/var/log/auth.log"
NOTIFY_SCRIPT="$(dirname "$0")/run/notifyTelegram.sh"

# List of usernames to exclude from notifications.
EXCLUDED_USERS=("root" "debian")

if [[ ! -x "$NOTIFY_SCRIPT" ]]; then
  echo "Notify script not found or not executable: $NOTIFY_SCRIPT" >&2
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
  # Description: Parse a log line, extract the username, and notify on login.
  # Parameters:
  #   $1 - Log line to process.
  local line="$1"
  local user
  user=$(sed -n 's/.*session opened for user \([^ ]\+\).*/\1/p' <<<"$line")
  if [[ -z "$user" ]]; then
    return 0
  fi
  if is_excluded_user "$user"; then
    return 0
  fi
  "$NOTIFY_SCRIPT" "Login" "$user"
}

if [[ ! -r "$LOG_FILE" ]]; then
  echo "Log file not readable: $LOG_FILE" >&2
  exit 1
fi

echo "Watching $LOG_FILE for logins..."

# Follow the auth log indefinitely and detect login sessions.
tail -F "$LOG_FILE" | while IFS= read -r line; do
  # Detect the PAM session opening message for a user login.
  if [[ "$line" == *"session opened for user"* ]]; then
    process_login_line "$line"
  fi
done
