#!/bin/bash

set -e

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# --- USER ARGUMENT CHECK ---
if [[ -z "${1-}" ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"

# --- SCRIPT DIRECTORY ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log file next to this script
LOGFILE="$SCRIPT_DIR/new_users.log"
touch "$LOGFILE"
#chmod 600 "$LOGFILE"

# --- CHECK IF USER EXISTS ---
if id "$USERNAME" &>/dev/null; then
    echo "❌ User '$USERNAME' already exists."
    exit 1
fi

# --- GENERATE SECURE PASSWORD (NO OPENSSL!) ---
PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+?' </dev/urandom | head -c 12)

# --- CREATE USER WITH BASH SHELL AND HOME ---
useradd -m -s /bin/bash -G researcher,docker "$USERNAME"

# --- COPY SKELETON FILES (if needed) ---
cp -a /etc/skel/. "/home/$USERNAME/"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

# --- OPTIONAL: ensure bash-completion is loaded ---
BASHRC_FILE="/home/$USERNAME/.bashrc"
if ! grep -q "bash_completion" "$BASHRC_FILE"; then
    echo 'if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi' >> "$BASHRC_FILE"
fi




# --- SET PASSWORD ---
echo "${USERNAME}:${PASSWORD}" | chpasswd

# --- OPTIONAL: force password change on first login ---
# chage -d 0 "$USERNAME"

# --- SAVE PASSWORD IN LOG FILE ---
echo "$(date '+%Y-%m-%d %H:%M:%S')  $USERNAME  $PASSWORD" >> "$LOGFILE"

# --- OUTPUT ---
echo "✅ User '$USERNAME' created successfully."
echo "🔑 Temporary password: $PASSWORD"
echo "📄 Logged in: $LOGFILE"
