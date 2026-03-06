#!/bin/sh
set -e

# Default credentials
SAMBA_USER=${SAMBA_USER:-root}
SAMBA_PASS=${SAMBA_PASS:-pass}
SAMBA_SHARE=${SAMBA_SHARE:-SHARE}

# Create the Linux user if it doesn't exist
if ! id "$SAMBA_USER" >/dev/null 2>&1; then
    useradd -u 0 -o -g 0 "$SAMBA_USER"
fi

# Set Samba password
(echo "${SAMBA_PASS}"; echo "${SAMBA_PASS}") | smbpasswd -s -a "$SAMBA_USER"

# Ensure storage directory exists
mkdir -p /storage

# Generate smb.conf dynamically
cat > /etc/samba/smb.conf <<EOL
[global]
   workgroup = WORKGROUP
   server string = Docker Samba Server
   log file = /var/log/samba/log.%m
   max log size = 1000
   security = user
   map to guest = bad user

[$SAMBA_SHARE]
   comment = Docker Storage Share
   path = /storage
   browseable = yes
   read only = no
   guest ok = no
   valid users = $SAMBA_USER
EOL

# Start Samba in background
/usr/sbin/smbd -D --no-process-group -s /etc/samba/smb.conf

# Dummy foreground process to keep container alive
tail -f /dev/null
