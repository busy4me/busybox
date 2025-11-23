# initiv - Installation and Bootstrap Script

Main installation and bootstrap script for BusyBox project.

## Synopsis

```bash
initiv [-options] <action>
```

## Description

The `initiv` script is used to slim Linux distributions, remove unnecessary packages, files, and prepare the system for specific tasks. It manages the multi-stage installation process from a base Debian system to a fully configured BusyBox environment.

## Installation Stages

| Stage | Command | Description |
|-------|---------|-------------|
| install | `initiv install` | Initial preparation (ready for cloning) |
| 0 | `initiv 0` | X.org and desktop setup |
| 1 | `initiv 1` | Final configuration with all packages |
| 2 | `initiv 2` | Download and install busybox project |

### Stage Details

**install** - Prepares a fresh Debian installation:
- Reads system data
- Removes unnecessary packages
- Updates apt repositories
- Installs base packages
- Sets up services
- Downloads animation files
- Sets autologin/autostart

**Stage 0** - X server and interface setup:
- Installs X.org server
- Creates user account
- Expands partition
- Downloads interface files
- Sets up animation and OSD

**Stage 1** - Final software installation:
- Installs Chrome, VNC, Python packages
- Downloads and installs busybox project
- Performs final configuration
- Triggers system reboot

## Options

| Option | Argument | Description |
|--------|----------|-------------|
| `-a` | `<user>` | Set autologin for specified user |
| `-h` | | Display help message |
| `-k` | | Skip automatic update |
| `-n` | `<theme>` | Set theme: `dark` or `light` |
| `-S` | | Show execution in xterm on DISPLAY :0 |
| `-T` | `<hostname>` | Set custom hostname |
| `-u` | `[no]` | Update initiv itself (use `-u no` to skip) |
| `-U` | `<username>` | Add user, set autologin/autostart, reset tty1 |
| `-v` | | Display script version |
| `-x` | | Run command in xterm during first interface |
| `-X` | | Install X server and reset tty1 |

## Actions

| Action | Description |
|--------|-------------|
| `install` | Prepare system for distribution |
| `0` | Stage 0 installation (X.org setup) |
| `1` | Stage 1 installation (final config) |
| `2` | Download and install busybox project |
| `update` | Update initiv itself from GitHub |
| `apt` | Update apt repositories |
| `remove-packages` | Remove unnecessary packages |
| `remove-files` | Remove unnecessary files |
| `autologin` | Set autologin user |
| `autostart` | Set autostart programs |
| `tunning` | Apply visual tuning |
| `apt1` | Install stuff1 packages |
| `apt2` | Install stuff2 packages |
| `apt3` | Install stuff3 (Chrome) |
| `installX` | Install X.org server |
| `parted` | Expand partition |
| `reset` | Reset xinit and tty1 |
| `prepare` | Prepare for distribution |
| `service` | Create busybox service |
| `netol` | Add node to Netol network (ZeroTier) |

## Examples

```bash
# Full installation on fresh Debian
initiv install

# Stage 0 after reboot
initiv 0

# Stage 1 in X session
initiv 1

# Create user and configure
initiv -U kate

# Set autologin for existing user
initiv -a kate

# Install with light theme
initiv -n light install

# Update initiv itself
initiv update
```

## Log File

All output is logged to `/var/log/busybox.log`

## Services Created

| Service | Description |
|---------|-------------|
| `busybox.service` | Main watchdog service |
| `busy-anime.service` | Framebuffer animation |
| `initiv-1.service` | Stage 1 trigger service |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `_LOGFILE` | `/var/log/busybox.log` | Log file path |
| `_USER` | `busybox` | Default username |
| `_THEME` | `dark` | Installation theme |
| `_SERVER` | `http://busy4.me` | Download server |

## Files

| Path | Description |
|------|-------------|
| `/usr/bin/initiv` | Main script location |
| `/usr/bin/bashcolors` | Color definitions |
| `/opt/busybox/` | Busybox project files |
| `/opt/xt.sh` | Xterm display script |
| `/opt/osd.sh` | OSD display script |

## Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | Error (function not found or failure) |

## See Also

- [busybox](busybox.md) - Python automation application
- [Services documentation](../guides/services.md)

---

[Back to Reference](README.md) | [Back to Docs](../README.md)
