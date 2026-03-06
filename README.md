# Intro

This is a non-strict samba server for linux hosts running on operating systems that do everything as root (like Ubuntu Server) to keep the permission structure homogenous, without having to ever `chmod` or `chown` anything.

## Notes

- Allows full RW access to the mounted docker folder
- Uses UID 0 & GID 0
- Specifically made for systems, where `chmod` or `chown` are not an option
- Never changes permissions of the host system's data
- Allows any username to be used (including `root`)

## Setup

### Server

```shell
docker run -d \
    --name doganm95-samba \
    -e "SAMBA_USER=any_user_name" \
    -e "SAMBA_PASS=anyPassword" \
    -e "SAMBA_SHARE=myshare" \
    -p 137-139:137-139 \
    -p 445:445 \
    --pull always \
    -v "/homes/root/:/storage/:rw" \
    ghcr.io/doganm95/samba-server:latest
```

- `SAMBA_USER`: Any username of your choice, used to authenticate. Default: `root`
- `SAMBA_PASS`: The respective password. Default: `pass`
- `SAMBA_SHARE`: A share-name of your choice, in this example `myshare`. Default: `SHARE`
- `.../:/storage/:rw `: The folder to be bound, with RW access, replace left path (...) with the parent folder to be served

### Client

On windows you can just map a new network drive, with a connection to `\\<server-ip>\<share-name>`, e.g. `\\192.168.0.50\myshare`

## Warning

The builders of ftp, smb, etc put effort into not allowing root users from authenticating due to security reasons. This container is not meant to be exposed (port-forwarded) to the internet ever. To use it from anywhere outside your home network, create a VPN connection using e.g. Wireguard / Wg-Easy and it should work fine.  
  
If your host is not running a root-only OS, you should probably not use this and check out [dockurr/samba](https://github.com/dockur/samba) instead.
