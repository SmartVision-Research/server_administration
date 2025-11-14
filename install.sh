#!/bin/bash
set -e

echo "🔧 Setting executable permissions for admin scripts..."

# Paths to your scripts
SCRIPT1="add_newuser.sh"
SCRIPT2="provide_access.sh"
SCRIPT3="dangerzone/delete_user.sh"

# Ensure scripts exist before chmod
for script in "$SCRIPT1" "$SCRIPT2" "$SCRIPT3"; do
  if [ ! -f "$script" ]; then
    echo "❌ ERROR: Script not found: $script"
    exit 1
  fi
done

# Apply permissions
chmod 750 "$SCRIPT1"
chmod 750 "$SCRIPT2"
chmod 750 "$SCRIPT3"

echo "✅ Permissions updated:"
echo "   - $SCRIPT1"
echo "   - $SCRIPT2"
echo "   - $SCRIPT3"
echo "🔐 Mode set to 750 (rwx for owner, rx for group, none for others)"

