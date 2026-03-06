FROM ubuntu:24.04

# Install Samba
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y samba samba-common-bin pwgen && \
    rm -rf /var/lib/apt/lists/*

# Copy Samba config
COPY smb.conf /etc/samba/smb.conf

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["/entrypoint.sh"]