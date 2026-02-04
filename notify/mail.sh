#!/usr/bin/env bash
# =============================================================================
# Script:    mail.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification via email using the local mail command.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
#   $3 - Log line (optional).
# Environment:
#   NOTIFY_MAIL_TO - Destination email address.
#   NOTIFY_MAIL_SUBJECT - Optional subject prefix (default: "Login notifier").
# =============================================================================
set -euo pipefail

MAIL_HOST_TEMPLATE="${NOTIFY_MAIL_HOST_TEMPLATE:-Host: %s}"
MAIL_ACTION_TEMPLATE="${NOTIFY_MAIL_ACTION_TEMPLATE:-Action: %s}"
MAIL_USER_TEMPLATE="${NOTIFY_MAIL_USER_TEMPLATE:-User: %s}"
MAIL_LOG_LINE_TEMPLATE="${NOTIFY_MAIL_LOG_LINE_TEMPLATE:-Log line: %s}"
MAIL_CONFIG_TEMPLATE="${NOTIFY_MAIL_CONFIG_TEMPLATE:-Config: NOTIFY_MAIL_TO=%s | NOTIFY_MAIL_SUBJECT=%s}"
MAIL_SUBJECT_PREFIX="${NOTIFY_MAIL_SUBJECT:-Login notifier}"

build_message() {
  local action="$1"
  local username="${2:-}"
  local log_line="${3:-}"
  local message
  printf -v message "$MAIL_HOST_TEMPLATE" "$(hostname)"
  message+=$'\n'
  message+=$(printf "$MAIL_ACTION_TEMPLATE" "$action")
  if [[ -n "$username" ]]; then
    message+=$'\n'
    message+=$(printf "$MAIL_USER_TEMPLATE" "$username")
  fi
  if [[ -n "$log_line" ]]; then
    message+=$'\n'
    message+=$(printf "$MAIL_LOG_LINE_TEMPLATE" "$log_line")
  fi
  message+=$'\n'
  message+=$(printf "$MAIL_CONFIG_TEMPLATE" "$NOTIFY_MAIL_TO" "$MAIL_SUBJECT_PREFIX")
  printf '%s\n' "$message"
}

send_notification() {
  local subject="$1"
  local message="$2"
  printf '%s\n' "$message" | mail -s "$subject" "$NOTIFY_MAIL_TO"
}

main() {
  local action="${1:-}"
  local username="${2:-}"
  local log_line="${3:-}"

  if [[ -z "$action" ]]; then
    echo "Usage: $0 <Action> [Username]" >&2
    exit 1
  fi

  if [[ -z "${NOTIFY_MAIL_TO:-}" ]]; then
    echo "NOTIFY_MAIL_TO must be set in the environment." >&2
    exit 1
  fi

  local subject message
  subject="${MAIL_SUBJECT_PREFIX}: ${action}"
  message=$(build_message "$action" "$username" "$log_line")
  send_notification "$subject" "$message"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
