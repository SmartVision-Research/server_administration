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

# --- SCRIPT DIRECTORY (for relative log file) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_FILE="$SCRIPT_DIR/user_passwords.txt"

touch "$BACKUP_FILE"

# --- ENSURE USER EXISTS ---
if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

# --- GENERATE RANDOM PASSWORD (NO OPENSSL) ---
PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%&*_' </dev/urandom | head -c 12)

# --- SET NEW PASSWORD ---
echo "$USERNAME:$PASSWORD" | chpasswd

# --- SET PASSWORD VALIDITY ---
chage -M "$VALIDITY_DAYS" "$USERNAME"

# --- LOG PASSWORD CHANGE ---
echo "$(date '+%Y-%m-%d %H:%M:%S') | $USERNAME | $PASSWORD | Valid $VALIDITY_DAYS days" >> "$BACKUP_FILE"

# --- OUTPUT ---
echo "✅ Password for user '$USERNAME' updated."
echo "🔑 New password: $PASSWORD"
echo "⏳ Validity: $VALIDITY_DAYS days"
echo "📄 Saved in: $BACKUP_FILE"

