#!/bin/bash
set -e

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root."
  exit 1
fi

# --- ARGUMENT CHECK ---
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <username> <validity_days>"
  exit 1
fi

USERNAME="$1"
VALIDITY_DAYS="$2"

# --- SCRIPT DIRECTORY ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_FILE="$SCRIPT_DIR/user_passwords.log"

touch "$BACKUP_FILE"

# --- ENSURE USER EXISTS ---
if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

# --- GENERATE RANDOM PASSWORD ---
PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%&*_' </dev/urandom | head -c 12)

# --- SET NEW PASSWORD ---
echo "$USERNAME:$PASSWORD" | chpasswd

# --- COMPUTE EXPIRATION DATE ---
# --- SET PASSWORD EXPIRATION AND MIN AGE ---
# -M : max days until password expires
# -m : min days before user can change password (prevent user changes)
# -E : account expiration date (block login after expiration)
EXPIRATION_DATE=$(date -d "+$VALIDITY_DAYS days" +%Y-%m-%d)
chage -M "$VALIDITY_DAYS" -m "$VALIDITY_DAYS" -E "$EXPIRATION_DATE" "$USERNAME"

# --- LOG PASSWORD CHANGE ---
echo "$(date '+%Y-%m-%d %H:%M:%S') | $USERNAME | $PASSWORD | Valid $VALIDITY_DAYS days | Expiration: $EXPIRATION_DATE" >> "$BACKUP_FILE"


# --- OUTPUT ---
echo "✅ Password for user '$USERNAME' updated."
echo "🔑 New password: $PASSWORD"
echo "⏳ Valid for $VALIDITY_DAYS days (until $EXPIRATION_DATE)"
echo "📄 Saved in: $BACKUP_FILE"
