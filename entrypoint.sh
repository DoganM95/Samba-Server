#!/bin/bash
set -e

# Default environment variables
SAMBA_USER=${SAMBA_USER:-root}
SAMBA_PASS=${SAMBA_PASS:-pass}

# Create Linux user with UID 0 to access root-owned folders
if ! id "$SAMBA_USER" &>/dev/null; then
    useradd -u 0 -o -g 0 "$SAMBA_USER"
fi

# Set the password for Linux user
echo "$SAMBA_USER:$SAMBA_PASS" | chpasswd

# Add Samba password
(echo "$SAMBA_PASS"; echo "$SAMBA_PASS") | smbpasswd -s -a "$SAMBA_USER"

# Remove user from Samba "blocked users" list if needed
sed -i "/^$SAMBA_USER$/d" /etc/samba/smbusers 2>/dev/null || true

# Start Samba in foreground
exec /usr/sbin/smbd -FS -s /etc/samba/smb.conf