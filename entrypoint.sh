#!/bin/sh
set -e

# Default credentials
SAMBA_USER=${SAMBA_USER:-root}
SAMBA_PASS=${SAMBA_PASS:-pass}
# Format: name1:/path1,name2:/path2,...
SAMBA_SHARES=${SAMBA_SHARES:-SHARE:/storage}

# Create the Linux user if it doesn't exist
if ! id "$SAMBA_USER" >/dev/null 2>&1; then
    useradd -u 0 -o -g 0 "$SAMBA_USER"
fi

# Set Samba password
(echo "${SAMBA_PASS}"; echo "${SAMBA_PASS}") | smbpasswd -s -a "$SAMBA_USER"

# Base smb.conf
cat > /etc/samba/smb.conf <<EOL
[global]
   workgroup = WORKGROUP
   server string = Docker Samba Server
   log file = /var/log/samba/log.%m
   max log size = 1000
   security = user
   map to guest = bad user
EOL

# Append one share block per entry in SAMBA_SHARES
OLD_IFS=$IFS
IFS=','
for entry in $SAMBA_SHARES; do
    share_name=${entry%%:*}
    share_path=${entry#*:}
    mkdir -p "$share_path"
    cat >> /etc/samba/smb.conf <<EOL

[$share_name]
   comment = Docker Storage Share
   path = $share_path
   browseable = yes
   read only = no
   guest ok = no
   valid users = $SAMBA_USER
EOL
done
IFS=$OLD_IFS

# Start Samba in background
/usr/sbin/smbd -D --no-process-group -s /etc/samba/smb.conf

# Dummy foreground process to keep container alive
tail -f /dev/null
