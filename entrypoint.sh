#!/bin/sh
set -e

# Default credentials
SAMBA_USER=${SAMBA_USER:-root}
SAMBA_PASS=${SAMBA_PASS:-pass}

# Create the Linux user if it doesn't exist
if ! id "$SAMBA_USER" >/dev/null 2>&1; then
    useradd -u 0 -o -g 0 "$SAMBA_USER"
fi

# Set Samba password from env var
(echo "${SAMBA_PASS}"; echo "${SAMBA_PASS}") | smbpasswd -s -a "${SAMBA_USER}"

# Ensure storage directory exists
mkdir -p /storage

# Option A
# Start smbd in foreground (PID 1)
# exec /usr/sbin/smbd -F --no-process-group -s /etc/samba/smb.conf

# Option B
# Start Samba in background
/usr/sbin/smbd -D --no-process-group -s /etc/samba/smb.conf
# Dummy foreground process to keep container alive
tail -f /dev/null