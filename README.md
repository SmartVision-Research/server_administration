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

