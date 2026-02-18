# BusyBox — Vision & Philosophy

![Version](https://img.shields.io/badge/version-1.1.23--beta-blue) ![Status](https://img.shields.io/badge/status-Beta-orange) ![License](https://img.shields.io/badge/license-Apache%202.0-green)

> **"A fully automated virtual assistant that works for you — 24/7 — without your attention."**

---

## What Is BusyBox?

BusyBox is an open-source **Automated Virtual Assistant Platform** running on Linux. It executes repetitive internet tasks autonomously — browsing, interacting, monitoring — using a visible browser session inside a VNC-accessible virtual machine.

It is **not a bot in the traditional sense**. It is a **platform** — a distributed, plugin-driven execution environment for automated internet presence management.

---

## Core Philosophy

### 1. Transparency Through Visibility
Every action busybox takes is **visible**. The browser window is always rendered and observable via VNC. There are no hidden background processes — everything runs in a real X11 session with a real browser.

### 2. Human-Like Behavior
BusyBox simulates natural user behavior: random mouse movements, variable key delays, scroll patterns, time-of-day awareness (no activity at night), and reaction to platform alerts (cookie banners, blocks, language switches).

### 3. Distributed by Design
Each BusyBox instance is a **self-contained VM** distributed to end users as an OVA/VMDK image. There is no central server controlling instances. The entire ecosystem is **P2P and decentralized**. Under the hood, all machines communicate over a mesh network (ZeroTier/Tailscale/Nebula — NETOL underlay).

### 4. Plugin Architecture
All platform-specific behavior is encapsulated in **plugins** (`/opt/busybox/plugins/<name>/`). A plugin can be written in any language — Bash, Python, Go, Ruby — and even powered by an AI agent. The system auto-detects the plugin type and runs it accordingly.

### 5. Zero Platform API Dependency

**BusyBox does NOT use any social media platform APIs.**

> ❌ No Facebook API / Graph API  
> ❌ No Google OAuth / YouTube Data API  
> ❌ No Instagram API  
> ❌ No TikTok API, Twitter API, or any other platform SDK  

BusyBox interacts with platforms exclusively through a **real browser rendering real web pages**. All information is obtained by reading the screen (Computer Vision). All actions are performed by simulating keyboard and mouse input — exactly as a human would.

This makes BusyBox:
- **Platform-independent** — no app registrations, no API keys, no terms-of-service traps
- **Resilient** — platform UI changes are handled by updating CV templates, not code
- **Universal** — any website accessible in Chrome is automatable with BusyBox

BusyBox's own internal translation layer — **Busyman API** — maps high-level intents
("scroll feed", "detect blocked", "click like") to CV detections and input events.
See [AUTH-FLOW.md](architecture/AUTH-FLOW.md) and [ARCHITECTURE.md](architecture/ARCHITECTURE.md) for details.

### 6. Minimal Footprint
BusyBox is designed to run on minimal hardware: <2GB RAM, <2GB disk, sub-60s boot. It installs on top of a minimal Debian 12 base with no unnecessary packages.

---

## Target Users

| User Type | Use Case |
|-----------|----------|
| **Social media managers** | Automate engagement, posting, monitoring across multiple accounts |
| **Content creators** | Maintain consistent online presence without manual effort |
| **Agencies** | Distribute VM instances to clients, each instance = one client |
| **Developers** | Build custom automation plugins using any language or AI |
| **Researchers** | Study platform behavior, algorithm responses, UI changes |

---

## What BusyBox Does Today (Beta)

- ✅ Runs autonomously on Debian 12 in VirtualBox
- ✅ Opens Google Chrome in a dedicated X11 session (DISPLAY :98 via TigerVNC)
- ✅ Browses Facebook, YouTube, Instagram, Twitch in a loop (100 steps)
- ✅ Simulates natural scrolling, key presses, mouse movement
- ✅ Detects UI elements via Computer Vision (OpenCV + PyAutoGUI)
- ✅ Handles cookie banners, blocks, language prompts automatically
- ✅ Shows live view on physical screen via VNC Viewer (DISPLAY :0)
- ✅ Operates in pre-login and post-login modes

## What BusyBox Will Do (Roadmap)

- 🔲 Welcome screen + account configuration form (first run UX)
- 🔲 Chrome profile sync with user's real account
- 🔲 NoVNC web interface (view/control via HTTPS browser)
- 🔲 Multi-VNC-session support (multiple accounts per VM, multiple displays)
- 🔲 Plugin marketplace (community plugins)
- 🔲 AI Agent plugins (LLM-driven decision making)
- 🔲 Distributed coordination via mesh network
- 🔲 Go/Ruby plugin support alongside Bash/Python

---

## Architecture in One Picture

```
┌─────────────────────────────────────────────────────────┐
│                  Physical Host (VirtualBox)              │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VirtualBox VM (Debian 12)            │  │
│  │                                                   │  │
│  │  DISPLAY :0 (X11 / Xorg)                         │  │
│  │  └── VNC Viewer (fullscreen)                      │  │
│  │       └── shows DISPLAY :98 ───────────────────┐ │  │
│  │                                                 │ │  │
│  │  DISPLAY :98 (TigerVNC — port 5998)             │ │  │
│  │  ├── Openbox (window manager)                   │ │  │
│  │  ├── tint2 (panel)                              │ │  │
│  │  └── Google Chrome (800x600 incognito)          │ │  │
│  │       └── Browsing: FB / YT / IG / Twitch       │ │  │
│  │                                                 │ │  │
│  │  screen sessions (busybox user):                │ │  │
│  │  ├── fb:98           (main FB plugin)           │ │  │
│  │  ├── fb-scroll:98    (scroll behavior)          │ │  │
│  │  └── fb-walking-around:98  (URL navigation)     │ │  │
│  │                                                 │ │  │
│  │  Python venv (/opt/venv):                       │ │  │
│  │  └── locate (OpenCV + PyAutoGUI → CV engine)    │ │  │
│  │                                                 │ │  │
│  └─────────────────────────────────────────────────┘ │  │
│                                                         │
│  Future: NoVNC → HTTPS → User Browser ─────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Two Documentation Tracks

This documentation serves two audiences:

### 🔧 Developer Track
→ Start with [ARCHITECTURE.md](architecture/ARCHITECTURE.md)  
→ Then [PROCESS-FLOW.md](process/PROCESS-FLOW.md)  
→ Then [PLUGINS.md](plugins/PLUGINS.md)  

### 👤 End User Track *(coming soon)*
→ Download VM → Run → Configure → Done  

---

## Language Versions

This documentation is currently available in:

| Language | Status | Path |
|----------|--------|------|
| 🇬🇧 English | ✅ Active | `docs/` (default) |
| 🇪🇸 Spanish | 🔲 Planned | `docs/i18n/es/` |
| 🇩🇪 German | 🔲 Planned | `docs/i18n/de/` |
| 🇫🇷 French | 🔲 Planned | `docs/i18n/fr/` |
| 🇮🇹 Italian | 🔲 Planned | `docs/i18n/it/` |
| 🇷🇺 Russian | 🔲 Planned | `docs/i18n/ru/` |
| 🇨🇳 Chinese (Simplified) | 🔲 Planned | `docs/i18n/zh-CN/` |
| 🇯🇵 Japanese | 🔲 Planned | `docs/i18n/ja/` |
| 🇰🇷 Korean | 🔲 Planned | `docs/i18n/ko/` |
| 🇹🇼 Chinese (Traditional) | 🔲 Planned | `docs/i18n/zh-TW/` |

---

## Session History

All AI-assisted development sessions for this project:

| Session | Date | Topic |
|---------|------|-------|
| s001 | 2025-11-12 | Initial setup |
| s002 | 2025-11-20 | Session notes & planning |
| s003 | 2025-11-21 | First busybox installation |
| s004 | 2025-11-21 | Install documentation |
| s005 | 2025-11-22 | Roadmap notes |
| s006 | 2025-11-23 | Multi-runner & DevOps CI setup |
| s007 | 2025-12-16 | Debian 12 base image optimization |
| s008 | 2025-12-18 | `initiv` reboot test (Stage 1/2 flow) |
| s106 | 2026-02-07 | Project summary & v1.1.23-beta status |
| s119 | 2026-02-10 | Pipeline trigger analysis |
| s120 | 2026-02-11 | Beta release & repo rename |
| s126 | 2026-02-12 | GitHub Actions runners restoration (lab1) |
| s131 | 2026-02-18 | Live VM process analysis & /docs foundation |
| s132 | 2026-02-18 | Authentication flow design (6-digit pairing) |

→ Full plan and next steps: [PLAN.md](PLAN.md)

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Version**: 1.1.23-beta
