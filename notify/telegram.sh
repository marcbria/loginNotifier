#!/usr/bin/env bash
# =============================================================================
# Script:    telegram.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification to Telegram via the Bot API.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
# =============================================================================
set -euo pipefail

# Visit BotFather to get your token:
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"

TELEGRAM_HEADER_TEMPLATE="${NOTIFY_TELEGRAM_HEADER_TEMPLATE:-[%s] Action: %s}"
TELEGRAM_USER_TEMPLATE="${NOTIFY_TELEGRAM_USER_TEMPLATE:- | User: %s}"

build_message() {
  local action="$1"
  local username="${2:-}"
  local message
  printf -v message "$TELEGRAM_HEADER_TEMPLATE" "$(hostname)" "$action"
  if [[ -n "$username" ]]; then
    message+=$(printf "$TELEGRAM_USER_TEMPLATE" "$username")
  fi
  printf '%s\n' "$message"
}

send_notification() {
  local message="$1"
  curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${message}" \
    >/dev/null
}

main() {
  local action="${1:-}"
  local username="${2:-}"

  if [[ -z "$action" ]]; then
    echo "Usage: $0 <Action> [Username]" >&2
    exit 1
  fi

  if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
    echo "TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set in the environment." >&2
    exit 1
  fi

  local message
  message=$(build_message "$action" "$username")
  send_notification "$message"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
