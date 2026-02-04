#!/usr/bin/env bash
# =============================================================================
# Script:    terminal.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification to the root user's terminal.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
# Environment:
#   ROOT_TTY_OVERRIDE - Optional tty device path (e.g., /dev/pts/1) for testing.
# =============================================================================
set -euo pipefail

ACTION="${1:-}"
USERNAME="${2:-}"

if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 <Action> [Username]" >&2
  exit 1
fi

MESSAGE="[$(hostname)] Action: $ACTION"
if [[ -n "$USERNAME" ]]; then
  MESSAGE+=" | User: $USERNAME"
fi

ROOT_TTY="${ROOT_TTY_OVERRIDE:-}"
if [[ -z "$ROOT_TTY" ]]; then
  ROOT_TTY=$(who | awk '$1=="root" {print $2; exit}')
  if [[ -n "$ROOT_TTY" ]]; then
    ROOT_TTY="/dev/${ROOT_TTY}"
  fi
fi

if [[ -z "$ROOT_TTY" || ! -w "$ROOT_TTY" ]]; then
  echo "No writable root TTY found; skipping terminal notification." >&2
  exit 0
fi

# Send the message directly to the root terminal.
printf '%s\n' "$MESSAGE" > "$ROOT_TTY"
