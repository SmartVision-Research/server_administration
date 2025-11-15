# 🛠️ User Administration Tools

This repository contains a set of secure shell scripts for managing user accounts on a Linux server.

Scripts included:

- **`add_newuser.sh`** — Create a new system user with a random strong password. The credentials are saved in `new_users.log`.
- **`grant_access.sh`** — Generate a new temporary password for an existing user with an expiration date. Updates `user_passwords.log`.
- **`extend_access.sh`** — Extend the expiration date of an existing user's password without changing the password. Updates `user_passwords.log`.
- **`dangerzone/delete_user.sh`** — Permanently delete a user and their home directory, kill all running processes, and clean up files owned by the user. Logs actions to `dangerzone/user_removal.log`.
- **`install.sh`** — Prepare the environment by checking required groups (`researcher` and `docker`), verifying the existence of scripts, setting executable permissions, and creating log files.

> ⚠️ These tools must be executed by a **root** user or via **sudo**.

---

## 📦 Installation

Clone or copy the repository on your server, then run:

```bash
sudo ./install.sh
```

## 🚀 Usage Guide

Below is the full workflow from creating users to deleting them.

### 1️⃣  Create a New User

**Script:** add_newuser.sh

**Description**

Creates a new Linux user, assigns it to the researcher and docker groups, and generates a random secure password.
It also logs the credentials in user_passwords.log.

**Usage**
```bash
sudo ./add_newuser.sh <username>
```
**Example**
```bash 
sudo ./add_newuser.sh smartvision
```
**Output** (example)
📌 Creating user 'smartvision'
🔑 Password: 8dF#Yw32A!
📁 Home directory: /home/smartvision
📝 Saved to: user_passwords.log

### 2️⃣  Provide Temporary Access to an Existing User

**Script:** grant_access.sh

**Description**

Assigns a new random password to an existing user and sets a password expiration policy.
The password and validity information are backed up in: user_passwords.log.

**Usage**
```bash
 sudo ./grant_access.sh <username> <validity_days>
 ```

Example
```bash 
sudo ./grant_access.sh smartvision 10
```
**Behavior**

Generates a new password

Applies password expiration (chage -M)

Logs backup entry

Users will be forced to change password after it expires, and cannot open new sessions until they do.

### 3️⃣  Extend Access for an Existing User

**Script:** extend_access.sh

**Description**

Extends the expiration date of an existing user's password without changing the current password.  
The updated expiration information is backed up in: `user_passwords.log`.

**Usage**
```bash
sudo ./extend_access.sh <username> <additional_days>
```

### 4️⃣  Permanently Delete a User (DANGER ZONE)

**Script:** dangerzone/delete_user.sh

Description

⚠️ This script permanently deletes a user, their home directory, and all files owned by them anywhere on the system.

It includes:

Interactive confirmation

Logging in user_removal.log

Safety checks before execution

**Usage**
```bash 
sudo ./dangerzone/delete_user.sh <username>
```
**Example**
```bash 
sudo ./dangerzone/delete_user.sh smartvision
```
Safety Prompt

Before deleting the user, the script displays:

⚠️ DANGER ZONE ⚠️
This will permanently delete the user 'smartvision'
Type EXACTLY 'DELETE' to continue:


If you do not type DELETE, the operation is cancelled.

### 🧷 Log Files

Two log files are automatically maintained:

File	Description
new_users.log Stores generated passwords for new users
user_passwords.log	Stores generated passwords and validity dates
dangerzone/user_removal.log	Records deleted users with timestamp

All these files are created automatically when first needed.

### 🧰 Recommended Workflow
1. Create the user
sudo ./add_newuser.sh newuser

2. Grant access with time restriction
sudo ./grant_access.sh newuser 7

3. Extend access if needed 
sudo ./extend_access.sh newuser 3

3. When the project ends: delete user completely
sudo ./dangerzone/delete_user.sh newuser
