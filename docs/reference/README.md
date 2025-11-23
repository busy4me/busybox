# Reference Documentation

Command reference for BusyBox project.

## Core Scripts

| Command | Description |
|---------|-------------|
| [initiv](initiv.md) | Main installation and bootstrap script |
| [busybox](busybox.md) | Python automation application (TODO) |

## Installation Stages

| Stage | Script | Description |
|-------|--------|-------------|
| install | `initiv install` | Initial system preparation |
| 0 | `initiv -S 0` | X.org and desktop setup |
| 1 | `initiv -S 1` | Final configuration |

## Commands

See [commands/](commands/) for individual command references.

## Services

| Service | Description |
|---------|-------------|
| `busybox.service` | Main watchdog service |
| `busy-anime.service` | Framebuffer animation |
| `initiv-1.service` | Stage 1 trigger service |

---

[Back to main docs](../README.md)
# Test commit 1 - ndz 23 lis 19:55:30 2025 CET
# Test commit 2 - ndz 23 lis 19:56:54 2025 CET
# Test commit 3 - ndz 23 lis 19:58:43 2025 CET
