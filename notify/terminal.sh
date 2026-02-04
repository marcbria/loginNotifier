#!/usr/bin/env bash
# =============================================================================
# Script:    terminal.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification to the root user's terminal.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
#   $3 - Log line (optional).
# Environment:
#   ROOT_TTY_OVERRIDE - Optional tty device path (e.g., /dev/pts/1) for testing.
# =============================================================================
set -euo pipefail

TERMINAL_HEADER_TEMPLATE="${NOTIFY_TERMINAL_HEADER_TEMPLATE:-[%s] Action: %s}"
TERMINAL_USER_TEMPLATE="${NOTIFY_TERMINAL_USER_TEMPLATE:- | User: %s}"
TERMINAL_LINE_TEMPLATE="${NOTIFY_TERMINAL_LINE_TEMPLATE:- | Line: %s}"

build_message() {
  local action="$1"
  local username="${2:-}"
  local log_line="${3:-}"
  local message
  printf -v message "$TERMINAL_HEADER_TEMPLATE" "$(hostname)" "$action"
  if [[ -n "$username" ]]; then
    message+=$(printf "$TERMINAL_USER_TEMPLATE" "$username")
  fi
  if [[ -n "$log_line" ]]; then
    message+=$(printf "$TERMINAL_LINE_TEMPLATE" "$log_line")
  fi
  printf '%s\n' "$message"
}

send_notification() {
  local message="$1"
  local root_tty="${ROOT_TTY_OVERRIDE:-}"
  if [[ -z "$root_tty" ]]; then
    root_tty=$(who | awk '$1=="root" {print $2; exit}')
    if [[ -n "$root_tty" ]]; then
      root_tty="/dev/${root_tty}"
    fi
  fi

  if [[ -z "$root_tty" || ! -w "$root_tty" ]]; then
    echo "No writable root TTY found; skipping terminal notification." >&2
    exit 0
  fi

  printf '%s\n' "$message" > "$root_tty"
}

main() {
  local action="${1:-}"
  local username="${2:-}"
  local log_line="${3:-}"

  if [[ -z "$action" ]]; then
    echo "Usage: $0 <Action> [Username]" >&2
    exit 1
  fi

  local message
  message=$(build_message "$action" "$username" "$log_line")
  send_notification "$message"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
