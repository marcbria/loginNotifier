#!/usr/bin/env bash
# =============================================================================
# Script:    notifyTelegram.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification to Telegram via the Bot API.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
# =============================================================================
set -euo pipefail

ACTION="${1:-}"
USERNAME="${2:-}"

if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 <Action> [Username]" >&2
  exit 1
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set in the environment." >&2
  exit 1
fi

MESSAGE="[$(hostname)] Action: $ACTION"
if [[ -n "$USERNAME" ]]; then
  MESSAGE+=" | User: $USERNAME"
fi

# Send the message to Telegram.
curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  >/dev/null
