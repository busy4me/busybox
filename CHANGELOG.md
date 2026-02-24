# Changelog

All notable changes to BusyBox project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0-beta] - 2026-02-24

### Added
- **NoVNC Web Desktop**: Complete web-based desktop architecture using Flask, websockify, and NoVNC 1.5.0
- **Dynamic Settings Menu**: Webapp menu for changing VNC resolution, display mode (scale/clip), and quality with persistence (SQLite)
- **Systemd Services**: New service architecture: `vncserver@:98`, `busyman-flask`, `busyman-websockify`
- **Smart VM Management**: New CI/CD policy using snapshots ("success"/"failed") and disk-space-aware cleanup

### Fixed
- **Database Initialization**: Fixed `0 bytes` database issue by moving initialization to `__install_project` and adding `sync`
- **NoVNC Installation**: Fixed race condition where `initiv` update wiped NoVNC directory; added preservation logic
- **CI/CD Reliability**: Resolved false negatives in tests (`pip list` buffering) and false positives in workflow (stale marker files)
- **Xorg Stability**: Reverted `video` kernel parameter removal to prevent Xorg freeze/deadlock on VirtualBox
- **Dependencies**: Fixed `sqlite3` checks and enabled WAL mode for better database concurrency

## [1.1.23-beta] - 2026-02-10

### Fixed
- **CRITICAL**: Fixed deadlock in Stage 1 installation where `wait` command hung on background `tee` process (commit fa89a02)
- Fixed Stage 1 reboot reliability - now waits only for specific background jobs instead of all processes
- Fixed SSH key propagation - keys are now correctly copied from root to busybox user for remote access

### Changed
- Reorganized documentation structure - moved USAGE and Database Tables to separate files in `docs/`
- Updated version badges to reflect Beta status
- Improved CI/CD infrastructure naming (dev → DevOps repository)

### Added
- Comprehensive troubleshooting documentation in `docs/troubleshooting/`
- Detailed analysis of deadlock issue with root cause and resolution steps
- Documentation for known issues and workarounds

## [1.0.1] - 2025-11-24

### Fixed
- Fixed system reboot after Stage 1 by adding `wait` command to ensure all background processes complete before script exits
- Fixed URL construction for asset downloads - now uses VERSION_ID (e.g., "12") instead of full version (e.g., "12.1") and converts x86_64 to amd64 for Debian naming convention
- Fixed SKIP_AUTO_UPDATE environment variable positioning - now allows script to copy itself to /usr/bin/initiv while skipping GitHub update check, ensuring proper system operation during tests

### Added
- SKIP_AUTO_UPDATE environment variable support to control auto-update behavior
- Background execution (&) for all service disable/stop commands to prevent blocking

## [1.0.0] - 2025-11-12

### Added
- Initial release
- Automated Linux installation and configuration system
- Support for Debian 10+ environments
- VM compatibility (VirtualBox, VMware)
- Multi-stage installation process (install, stage 0, stage 1)
- Automatic package management and system optimization
- X.org and desktop environment setup
- Project-specific configuration and deployment
