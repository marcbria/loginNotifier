#!/usr/bin/env bash
# =============================================================================
# Script:    mail.sh
# Author:    Marc Bria (UAB)
# License:   AGPL-3.0
# Purpose:   Send a login/logout notification via email using the local mail command.
# Parameters:
#   $1 - Action (e.g., Login, Logout).
#   $2 - Username (optional).
<<<<<<< codex/fix-log-file-not-readable-error
#   $3 - Log line (optional).
=======
>>>>>>> main
# Environment:
#   NOTIFY_MAIL_TO - Destination email address.
#   NOTIFY_MAIL_SUBJECT - Optional subject prefix (default: "Login notifier").
# =============================================================================
set -euo pipefail

ACTION="${1:-}"
USERNAME="${2:-}"
<<<<<<< codex/fix-log-file-not-readable-error
LOG_LINE="${3:-}"
=======
>>>>>>> main

if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 <Action> [Username]" >&2
  exit 1
fi

if [[ -z "${NOTIFY_MAIL_TO:-}" ]]; then
  echo "NOTIFY_MAIL_TO must be set in the environment." >&2
  exit 1
fi

SUBJECT_PREFIX="${NOTIFY_MAIL_SUBJECT:-Login notifier}"
SUBJECT="${SUBJECT_PREFIX}: ${ACTION}"

MESSAGE="Host: $(hostname)"
MESSAGE+=$'\n'
MESSAGE+="Action: ${ACTION}"
if [[ -n "$USERNAME" ]]; then
  MESSAGE+=$'\n'
  MESSAGE+="User: ${USERNAME}"
fi
<<<<<<< codex/fix-log-file-not-readable-error
if [[ -n "$LOG_LINE" ]]; then
  MESSAGE+=$'\n'
  MESSAGE+="Log line: ${LOG_LINE}"
fi
=======
>>>>>>> main

# Send the message using the local mail command.
printf '%s\n' "$MESSAGE" | mail -s "$SUBJECT" "$NOTIFY_MAIL_TO"
