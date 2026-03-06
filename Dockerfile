FROM ubuntu:24.04

# Install Samba
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y samba samba-common-bin pwgen && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 137 138 139 445

ENTRYPOINT ["/entrypoint.sh"]