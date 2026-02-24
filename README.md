<div align="center">

# BusyBox 🤖 by busy4me ™️

**Automated Virtual Assistant Platform for Linux**

[![Version](https://img.shields.io/badge/version-1.2.0--beta-blue.svg)](https://github.com/busy4me/busybox/releases)
[![Status](https://img.shields.io/badge/status-Beta-orange.svg)](https://github.com/busy4me/busybox)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://github.com/busy4me/busybox)

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## 📚 Documentation Index (Developer Track)

| Document | Description |
|----------|-------------|
| [WHITEPAPER.md](WHITEPAPER.md) | **Start Here** — White Paper (PL), vision & business model |
| [VISION.md](VISION.md) | Philosophy, goals, architecture overview, session history |
| [PLAN.md](PLAN.md) | Implementation plan, priorities, open decisions |
| [architecture/ARCHITECTURE.md](architecture/ARCHITECTURE.md) | Deep dive: displays, processes, plugins, config |
| [architecture/AUTH-FLOW.md](architecture/AUTH-FLOW.md) | 6-digit pairing design (OAuth RFC 8628) |
| [process/PROCESS-FLOW.md](process/PROCESS-FLOW.md) | Step-by-step: installation → runtime → what's on screen |
| [plugins/PLUGINS.md](plugins/PLUGINS.md) | Plugin system, CV engine, writing new plugins |
| [i18n/README.md](i18n/README.md) | Multi-language documentation plan (12 languages) |
| [reference/initiv.md](reference/initiv.md) | `initiv` installation script reference |

---

## 📋 Overview

**BusyBox 🤖 by busy4me ™️** is an open-source automation platform that runs continuously on Linux machines, handling routine online tasks through a virtual assistant. It provides internet-based control via web, smartphone, and tablet interfaces, operating securely behind firewalls without exposed ports.

Built on clean Linux architecture with minimalist code, Busybox offers:
- 🔐 Encrypted local data storage with firewall protection
- 🌐 Remote access without port forwarding
- ⚡ Low resource consumption (minimal storage and memory)
- 🎯 Click-and-Play accessibility
- 🛠️ Developer-oriented configuration
- 📜 Apache v.2 licensed open-source

## ✨ Features

- **Continuous Automation** - Run tasks 24/7 without manual intervention
- **Secure & Private** - Encrypted connections and firewall-protected data
- **Platform Agnostic** - Works on VMs, dedicated hardware, ARM, Raspberry Pi
- **Social Media Automation** - Automated posting, commenting, sharing, and engagement
- **Database Management** - Built-in database operations for content management
- **Live Streaming** - Stream desktop to multiple platforms
- **Remote Console** - SSH access for advanced management
- **Cron Integration** - Schedule tasks with flexible timing options

## 🚀 Quick Start

### Prerequisites

- VirtualBox or VMware (for VM installation)
- Debian-based Linux system (Debian 10+ recommended)
- Internet connection

### Installation

#### Option 1: Debian 10 Buster (Recommended)

1. Install minimal Debian 10 Buster in [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
   - Download ISO: [debian-10.4.0-amd64-netinst.iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.4.0-amd64-netinst.iso) (336MB)
   - Use base installation, skip additional software

2. Run the installation script:
   ```bash
   wget https://raw.githubusercontent.com/busy4me/busybox/main/root/initiv && bash ./initiv install
   ```

3. Wait for browser and login window to appear (several minutes)

4. Enter your credentials - the system will simulate natural user behavior

5. Your host becomes operational

#### Option 2: Debian 8 Jessie (Legacy)

```bash
wget https://raw.githubusercontent.com/busy4me/busybox/main/root/init-0 && bash ./init-0
```

## 📖 Usage

### Quick Examples

**Social Media Operations:**
```bash
busy --like="https://socialportal.com/fanpage/post" :0  # Like a post
busy --follow="https://socialportal.com/profile" :2     # Follow profile
busy --comment="Great!" --url="socialportal.com/post"   # Comment
```

**Content Publishing:**
```bash
busy --post="database.table.record" :5  # Publish from database
busy --share="https://example.com" :1   # Share content
```

**Database Operations:**
```bash
busy --db=show                          # Show all tables
busy --db=show --table="fb_posts"       # Show table records
busy --db=add --table="fb_posts" --data="content"  # Add record
```

**System Operations:**
```bash
busy --restart :5       # Restart display :5
busy --cron=status      # Check cron status
busy --clip-clear       # Clear clipboard
```

📚 **Full documentation**: See [Usage Guide](docs/usage.md) for complete command reference.

## 🗄️ Database Tables

Busybox uses local databases to manage content and platform interactions:

- **Facebook**: `fb_user`, `fb_posts`, `fb_groups`, `fb_pages`, `fb_plan`
- **YouTube**: `yo_user`
- **Instagram**: `in_user`
- **General**: `socialmedia` (shared data)

📚 **Full documentation**: See [Database Tables](docs/database-tables.md) for detailed schema and operations.

## 🔐 Remote Access

Access your Busybox instance via SSH:

```bash
ssh 192.168.1.23 -p 22
su busybox
```

📚 **Documentation**: See [Usage Guide](docs/usage.md#remote-access) for advanced access methods.

## 🏗️ Architecture

### Deployment Models

**Classic User Flow:**
```
User → Social Media → Advertisement → Control
```

**With Busybox:**
```
User (iPhone/Android/Web) → Busybox Host → Social Media
                          ↓
                    Status Reporting
```

### System Users

- **busybox** - Executes user commands and shell scripts (DISPLAY :1)
- **root** - System-level operations
- **admin** - Reserved
- **vi** - Reserved

### Platform Support

- ✅ Virtual Machines (VMware, VirtualBox, QEMU)
- ✅ Dedicated Hardware (x86/x64 PCs)
- ✅ ARM Devices (Raspberry Pi, etc.)
- ✅ Headless Systems

## 🎯 Design Goals

1. **Clean Implementation** - Simple, maintainable Linux distribution
2. **Minimalist Architecture** - Reduced code complexity
3. **Resource Efficiency** - Low storage and memory footprint
4. **Independence** - Standalone operation without external dependencies
5. **Automation** - Automatic process management
6. **Security** - High-standard encrypted internet connections

## 🛠️ Update System

Update Busybox components:

```bash
update --full              # Update all files
update --binaries          # Update binary files only
update --busy              # Update busy executable
update -h                  # Display help
```

📚 **Full documentation**: See [Usage Guide](docs/usage.md#update-system) for all update options.

## 📚 Documentation

### Local Documentation

- [Reference Documentation](reference/README.md) - Command and script references
  - [initiv](reference/initiv.md) - Installation and bootstrap script
  - [Commands](reference/commands/) - Individual command references

### Online Resources

For additional documentation, visit the [Busybox Wiki](https://github.com/busy4me/busybox/wiki).

- [Installation Guide](https://github.com/busy4me/busybox/wiki#install-on-linux-debian-10)
- [Command Reference](https://github.com/busy4me/busybox/wiki#commands)
- [Configuration](https://github.com/busy4me/busybox/wiki#configuration)
- [Architecture Details](https://github.com/busy4me/busybox/wiki#architecture)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

See [docs/TEAMS.md](docs/TEAMS.md) for team structure and active tasks.

## 📄 License

BusyBox 🤖 by busy4me ™️ is open-source software licensed under the **Apache License 2.0**.

```
Copyright © busy4me ™️
Licensed under Apache License v.2
```

See [LICENSE](LICENSE) file for details.

## 🌐 Links

- **Repository**: [github.com/busy4me/busybox](https://github.com/busy4me/busybox)
- **Wiki**: [Documentation](https://github.com/busy4me/busybox/wiki)
- **Issues**: [Bug Reports](https://github.com/busy4me/busybox/issues)

---

<div align="center">

**Made with ❤️ by BusyBox 🤖 by busy4me ™️**

⭐ Star us on GitHub if you find this project useful!

</div>
