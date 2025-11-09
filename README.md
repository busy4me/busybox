<div align="center">

# 🚀 BusyBox

**Automated Virtual Assistant Platform for Linux**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/busy4me/busybox)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://github.com/busy4me/busybox)

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## 📋 Overview

**BusyBox** is an open-source automation platform that runs continuously on Linux machines, handling routine online tasks through a virtual assistant. It provides internet-based control via web, smartphone, and tablet interfaces, operating securely behind firewalls without exposed ports.

Built on clean Linux architecture with minimalist code, BusyBox offers:
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
   wget busy4.me/initiv && bash ./initiv install
   ```

3. Wait for browser and login window to appear (several minutes)

4. Enter your credentials - the system will simulate natural user behavior

5. Your host becomes operational via busy4.me

#### Option 2: Debian 8 Jessie (Legacy)

```bash
wget busy4.me/init-0 && bash ./init-0
```

## 📖 Usage

### Basic Syntax

```bash
busy [--option=value]... [:place]
```

or

```bash
busy [sub_command] [--option=value]... [:place]
```

### Command Examples

#### Social Media Operations

**Like a post:**
```bash
busy --like="https://socialportal.com/fanpage/post" :0
```

**Follow a profile:**
```bash
busy --follow="https://socialportal.com/profile" :2
```

**Share content:**
```bash
busy --share="https://example.com" --url="https://socialportal.com/group_name" :1
```

**Comment on a post:**
```bash
busy --comment="Great content!" --url="socialportal.com/groups/example/post/123456"
```

**Join a group:**
```bash
busy --join="https://socialportal.com/group_name" :1
```

#### Content Publishing

**Publish a post:**
```bash
busy --post="database.table.record" :5
```
> Posts are fetched from database. Without value, uses oldest post from default table.

**Subscribe to a channel:**
```bash
busy --subscribe="https://example.com" :1
```

#### Live Streaming

**Start streaming:**
```bash
busy --live=start --url="rtmp://live-api.platform.com:80/api=1&key=YOUR_KEY" :0
```

**Stop streaming:**
```bash
busy --live=stop :0
```

**Check stream status:**
```bash
busy --live=status :0
```

#### Database Operations

**Show all tables:**
```bash
busy --db=show
```

**Show table records:**
```bash
busy --db=show --table="database.table"
```

**Add record:**
```bash
busy --db=add --table="database.table" --data="field1,field2,field3"
```

**Update record:**
```bash
busy --db=update --table="database.table.record_id" --data="new_data"
```

**Drop table:**
```bash
busy --db=drop --table="database.table"
```

#### System Operations

**Clear clipboard:**
```bash
busy --clip-clear
# or
busy -cc
```

**Restart display:**
```bash
busy --restart :5        # restart DISPLAY:5
busy --restart=all       # restart all displays
```

**Screen management:**
```bash
busy --screen=status                    # show screen sessions
busy --screen=on --cmd="htop"          # run htop in screen
```

**Cron management:**
```bash
busy --cron=on           # enable cron
busy --cron=off          # disable cron
busy --cron=status       # check cron status
```

### Authentication

**Login to a portal:**
```bash
busy --login --url="https://socialportal.com" :1
```

## 🗄️ Database Tables

BusyBox manages various database tables for different platforms:

- `socialmedia` - General social media data
- `fb_user` - Facebook user profiles
- `fb_posts` - Facebook posts queue
- `fb_groups` - Facebook groups
- `fb_group__metadata` - Group metadata
- `fb_people` - People database
- `fb_friends` - Friends list
- `fb_pages` - Facebook pages
- `fb_page__metadata` - Page metadata
- `fb_plan` - Scheduling plans
- `yo_user` - YouTube user data
- `in_user` - Instagram user data

## 🔐 Remote Access

Access your BusyBox instance via SSH:

```bash
ssh 192.168.1.23 -p 22
su busybox
```

## 🏗️ Architecture

### Deployment Models

**Classic User Flow:**
```
User → Social Media → Advertisement → Control
```

**With BusyBox:**
```
User (iPhone/Android/Web) → BusyBox Host → Social Media
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

Update BusyBox components:

```bash
update --full              # Update all files
update --binaries          # Update binary files only
update --busy              # Update busy executable
update --cron_task         # Update cron tasks
update --logrotate         # Update log rotation config
update --tint2rc           # Update tint2 configuration
update --openbox           # Update OpenBox config
update [path/]file         # Update specific file
update -h                  # Display help
```

## 📚 Documentation

For detailed documentation, visit the [BusyBox Wiki](https://github.com/busy4me/busybox/wiki).

### Quick Links

- [Installation Guide](https://github.com/busy4me/busybox/wiki#install-on-linux-debian-10)
- [Command Reference](https://github.com/busy4me/busybox/wiki#commands)
- [Configuration](https://github.com/busy4me/busybox/wiki#configuration)
- [Architecture Details](https://github.com/busy4me/busybox/wiki#architecture)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📄 License

BusyBox is open-source software licensed under the **Apache License 2.0**.

```
Copyright © busy4.me
Licensed under Apache License v.2
```

See [LICENSE](LICENSE) file for details.

## 🌐 Links

- **Website**: [busy4.me](https://busy4.me)
- **Repository**: [github.com/busy4me/busybox](https://github.com/busy4me/busybox)
- **Wiki**: [Documentation](https://github.com/busy4me/busybox/wiki)
- **Issues**: [Bug Reports](https://github.com/busy4me/busybox/issues)

---

<div align="center">

**Made with ❤️ by the busy4.me team**

⭐ Star us on GitHub if you find this project useful!

</div>
