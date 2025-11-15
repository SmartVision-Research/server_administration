#!/bin/bash
set -e

# --- REQUIRE SCRIPT TO RUN AS ROOT -------------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root."
   echo "Run it with: sudo $0 <username>"
   exit 1
fi

# --- CHECK ARGUMENT -----------------------------------------------------------
if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/user_removal.log"

# --- CHECK IF USER EXISTS -----------------------------------------------------
if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

# --- DANGER ZONE --------------------------------------------------------------
echo ""
echo "============================================================"
echo "                  ⚠️  D A N G E R   Z O N E  ⚠️"
echo "============================================================"
echo "You are about to PERMANENTLY DELETE the user '$USERNAME'"
echo ""
echo "This will:"
echo "  ❗ REMOVE the user account"
echo "  ❗ DELETE the home directory /home/$USERNAME"
echo "  ❗ FORCE KILL all running processes"
echo "  ❗ DELETE all files owned by this user anywhere on the system"
echo "  ❗ This operation CANNOT be undone"
echo "============================================================"
echo ""

read -p "Type EXACTLY 'DELETE' to continue: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
  echo "❌ Aborted. User '$USERNAME' was NOT removed."
  exit 1
fi

echo ""
echo "🔥 Proceeding with deletion..."
echo ""

# --- LOG HEADER ---------------------------------------------------------------
echo "------------------------------------------------------" >> "$LOGFILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Removing user: $USERNAME" >> "$LOGFILE"

# --- FORCE KILL RUNNING PROCESSES -------------------------------------------
echo "🔍 Killing all running processes for $USERNAME..."
pkill -9 -u "$USERNAME" 2>/dev/null || true

# --- DELETE USER + HOME FOLDER ------------------------------------------------
echo "🗑 Removing user and home directory..."
userdel -r "$USERNAME" || true

# --- CLEAN LEFTOVER FILES OUTSIDE HOME ---------------------------------------
echo "🧹 Cleaning leftover files..."
LEFTOVERS=$(find / -user "$USERNAME" 2>/dev/null || true)

if [ -n "$LEFTOVERS" ]; then
  echo "$LEFTOVERS" >> "$LOGFILE"
  echo "Deleting leftover files..."
  echo "$LEFTOVERS" | xargs rm -f 2>/dev/null || true
else
  echo "No leftover files found."
fi

# --- LOG SUCCESS --------------------------------------------------------------
echo "✅ User $USERNAME removed successfully." | tee -a "$LOGFILE"
echo ""
echo "✔️ Done."

