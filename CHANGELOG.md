# Changelog

All notable changes to BusyBox project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
