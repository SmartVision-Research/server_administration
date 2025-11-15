#!/bin/bash
set -e

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root."
  exit 1
fi

# --- ARGUMENT CHECK ---
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <username> <extra_days>"
  exit 1
fi

USERNAME="$1"
EXTRA_DAYS="$2"

# --- SCRIPT DIRECTORY ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/user_passwords.log"
touch "$LOG_FILE"

# --- ENSURE USER EXISTS ---
if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

# --- READ SHADOW ENTRY ---
SHADOW_ENTRY=$(grep "^$USERNAME:" /etc/shadow)

if [[ -z "$SHADOW_ENTRY" ]]; then
  echo "❌ Could not read /etc/shadow entry for '$USERNAME'"
  exit 1
fi


# Fields in /etc/shadow:
# 1: username
# 2: encrypted password
# 3: last password change (days since epoch)
# 4: minimum days
# 5: maximum days
# 6: warning days
# 7: inactivity period
# 8: expiration date (days since epoch)
IFS=':' read -r _ _ LAST_CHANGE MIN_DAYS MAX_DAYS WARN_DAYS INACTIVE EXPIRE_DAYS _ <<< "$SHADOW_ENTRY"

TODAY_EPOCH_DAYS=$(( $(date +%s) / 86400 ))

# --- COMPUTE NEW EXPIRATION DATE ---
if [[ -z "$EXPIRE_DAYS" || "$EXPIRE_DAYS" == "" ]]; then
    # No expiration set → extend from today
    OLD_EXPIRATION_DAYS=$TODAY_EPOCH_DAYS
elif (( EXPIRE_DAYS < TODAY_EPOCH_DAYS )); then
    # Already expired → extend from today
    OLD_EXPIRATION_DAYS=$TODAY_EPOCH_DAYS
else
    # Not yet expired → extend from existing expiration
    OLD_EXPIRATION_DAYS=$EXPIRE_DAYS
fi

NEW_EXPIRATION_DAYS=$(( OLD_EXPIRATION_DAYS + EXTRA_DAYS ))
NEW_EXPIRATION=$(date -d "@$((NEW_EXPIRATION_DAYS * 86400))" +%Y-%m-%d)

# --- APPLY NEW EXPIRATION ---
chage -E "$NEW_EXPIRATION_DAYS" "$USERNAME"

# --- SET MIN/MAX PASSWORD AGE TO PREVENT CHANGES ---
# Prevent user from changing password before expiration
chage -m "$EXTRA_DAYS" -M "$EXTRA_DAYS" "$USERNAME"

# --- LOG THE EXTENSION ---
echo "$(date '+%Y-%m-%d %H:%M:%S') | $USERNAME | Extended by $EXTRA_DAYS days | New Expiration: $NEW_EXPIRATION" >> "$BACKUP_FILE"

echo "✅ Access extended for '$USERNAME'"
echo "📆 New expiration date: $NEW_EXPIRATION"
echo "📄 Logged in: $LOG_FILE"
