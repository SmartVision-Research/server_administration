#!/bin/bash
set -e

echo "🔍 Checking required groups..."

# --- REQUIRED GROUPS ---
REQUIRED_GROUPS=("researcher" "docker")
MISSING_GROUPS=()

for GROUP in "${REQUIRED_GROUPS[@]}"; do
    if getent group "$GROUP" > /dev/null 2>&1; then
        echo "✅ Group '$GROUP' exists."
    else
        echo "❌ Group '$GROUP' is missing!"
        MISSING_GROUPS+=("$GROUP")
    fi
done

if [ "${#MISSING_GROUPS[@]}" -ne 0 ]; then
    echo ""
    echo "⚠️ Installation cannot continue because the following required groups are missing:"
    for g in "${MISSING_GROUPS[@]}"; do
        echo "   - $g"
    done
    echo ""
    echo "🛑 Please report this issue to the system administrator."
    exit 1
fi

echo ""
echo "🔧 Setting executable permissions for admin scripts..."

# --- PATHS TO SCRIPTS ---
SCRIPT1="add_newuser.sh"
SCRIPT2="provide_access.sh"
SCRIPT3="dangerzone/delete_user.sh"
SCRIPT4="extend_access.sh"

SCRIPTS=("$SCRIPT1" "$SCRIPT2" "$SCRIPT3" "$SCRIPT4")

# Ensure scripts exist before chmod
for script in "${SCRIPTS[@]}"; do
  if [ ! -f "$script" ]; then
    echo "❌ ERROR: Script not found: $script"
    exit 1
  fi
done

# Apply permissions
for script in "${SCRIPTS[@]}"; do
    chmod 750 "$script"
done

echo "✅ Permissions updated for all admin scripts:"
for script in "${SCRIPTS[@]}"; do
    echo "   - $script"
done
echo "🔐 Mode set to 750 (rwx for owner, rx for group, none for others)"

# --- CREATE LOG FILES ---
LOG_FILES=("user_passwords.log" "new_users.log" "dangerzone/user_removal.log")

for log in "${LOG_FILES[@]}"; do
    LOG_DIR=$(dirname "$log")
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
    fi

    if [ ! -f "$log" ]; then
        touch "$log"
        chmod 600 "$log"
        echo "✅ Created log file: $log (readable only by owner)"
    else
        echo "ℹ️ Log file already exists: $log"
    fi
done

echo ""
echo "🎉 Installation complete! All scripts are ready to use."

