#!/bin/bash
set -e

# Default credentials
SAMBA_USER=${SAMBA_USER:-root}
SAMBA_PASS=${SAMBA_PASS:-pass}

# Ensure /storage exists
mkdir -p /storage

# Create Linux user with UID 0 (root equivalent)
if ! id "$SAMBA_USER" &>/dev/null; then
    useradd -u 0 -o -g 0 "$SAMBA_USER"
fi

# Set password for Linux user
echo "$SAMBA_USER:$SAMBA_PASS" | chpasswd

# Add Samba password
(echo "$SAMBA_PASS"; echo "$SAMBA_PASS") | smbpasswd -s -a "$SAMBA_USER"

# Start smbd in foreground (PID 1)
exec /usr/sbin/smbd -FS --no-process-group