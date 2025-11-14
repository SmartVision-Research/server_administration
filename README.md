# 🛠️ User Administration Tools

This repository contains a set of secure shell scripts for managing user accounts on a Linux server.

Scripts included:

- **`add_newuser.sh`** — Create a new system user with a random strong password  
- **`provide_access.sh`** — Generate a new temporary password with an expiration date  
- **`dangerzone/delete_user.sh`** — Permanently delete a user and their home directory  
- **`install.sh`** — Configure permissions for all scripts

> ⚠️ These tools must be executed by a **root** user or via **sudo**.

---

## 📦 Installation

Clone or copy the repository on your server, then run:

```bash
sudo ./install.sh
```

This script will:

Verify that all admin scripts exist

Apply secure permissions (chmod 750)

Ensure everything is ready for use

After installation, you should see:

Permissions updated for all scripts.

##🚀 Usage Guide

Below is the full workflow from creating users to deleting them.

###1️⃣ Create a New User

Script: add_newuser.sh

Description

Creates a new Linux user, assigns it to the researcher group, and generates a random secure password.
It also logs the credentials in user_passwords.txt.

Usage

sudo ./add_newuser.sh <username>

Example
sudo ./add_newuser.sh deepvision

Output (example)
📌 Creating user 'deepvision'
🔑 Password: 8dF#Yw32A!
📁 Home directory: /home/deepvision
📝 Saved to: user_passwords.txt

2️⃣ Provide Temporary Access to an Existing User

Script: provide_access.sh

Description

Assigns a new random password to an existing user and sets a password expiration policy.
The password and validity information are backed up in: user_passwords.txt.

Usage
sudo ./provide_access.sh <username> <validity_days>

Example
sudo ./provide_access.sh deepvision 10

Behavior

Generates a new password

Applies password expiration (chage -M)

Logs backup entry

Users will be forced to change password after it expires, and cannot open new sessions until they do.

3️⃣ Permanently Delete a User (DANGER ZONE)

Script: dangerzone/delete_user.sh

Description

⚠️ This script permanently deletes a user, their home directory, and all files owned by them anywhere on the system.

It includes:

Interactive confirmation

Logging in user_removal.log

Safety checks before execution

Usage
sudo ./dangerzone/delete_user.sh <username>

Example
sudo ./dangerzone/delete_user.sh deepvision

Safety Prompt

Before deleting the user, the script displays:

⚠️ DANGER ZONE ⚠️
This will permanently delete the user 'deepvision'
Type EXACTLY 'DELETE' to continue:


If you do not type DELETE, the operation is cancelled.

🧷 Log Files

Two log files are automatically maintained:

File	Description
user_passwords.txt	Stores generated passwords and validity dates
user_removal.log	Records deleted users with timestamp

Both files are created automatically when first needed.

🔐 Security Notes

Only root should run these scripts.

Password backup files contain sensitive information → limit permissions (the scripts handle this automatically).

These tools are intended for controlled internal environments, not public-facing services.

Password expiration may block SSH login after expiry but does not kill active sessions.

🧰 Recommended Workflow
1. Create the user
sudo ./add_newuser.sh newuser

2. Provide access with time restriction
sudo ./provide_access.sh newuser 7

3. When the project ends: delete user completely
sudo ./dangerzone/delete_user.sh newuser
