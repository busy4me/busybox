# BusyBox — System Architecture

> **Technical deep-dive for developers and contributors.**

---

## ⚠️ Fundamental Design Constraint — No Platform APIs

**BusyBox does NOT use any social media or third-party platform APIs.**

```
❌ FORBIDDEN                          ✅ ALLOWED
─────────────────────────────────     ─────────────────────────────────────
Facebook Graph API                    Chrome rendering facebook.com
Google OAuth / YouTube Data API       Chrome rendering youtube.com
Instagram API / Meta for Developers   CV reading pixels from Chrome screen
TikTok API, Twitter API, etc.         xdotool/pyautogui simulating input
Any platform SDK or token             Screenshot analysis via OpenCV
```

All platform interaction happens through:
1. **Chrome browser** — renders the real website as a human would see it
2. **Computer Vision** (`locate` / `busyman`) — reads what is on screen
3. **Input simulation** (`xdotool`, `pyautogui`) — clicks and types like a human

BusyBox's own **Busyman API** is the internal translation layer between
high-level plugin intents and low-level CV + input operations.
See [AUTH-FLOW.md](AUTH-FLOW.md) for full Busyman specification.

---

## Table of Contents

1. [System Users & Roles](#1-system-users--roles)
2. [Display Architecture (X11 + VNC)](#2-display-architecture-x11--vnc)
3. [Process Map](#3-process-map)
4. [Screen Sessions](#4-screen-sessions)
5. [Plugin Architecture](#5-plugin-architecture)
6. [Computer Vision Engine — Busyman](#6-computer-vision-engine--busyman)
7. [Configuration System](#7-configuration-system)
8. [Database Layer](#8-database-layer)
9. [Network Architecture](#9-network-architecture)
10. [Deployment Model](#10-deployment-model)

---

## 1. System Users & Roles

BusyBox uses a strict user separation model:

| User | Role | Home | Key Permissions |
|------|------|------|-----------------|
| `root` | System management, installation | `/root` | Full system access |
| `busybox` | Automation executor — runs all plugins | `/home/busybox` | sudo NOPASSWD, X11 sessions, cron |
| `vi` | CI/CD runner, infrastructure ops | `/home/vi` | VirtualBox management, GitHub runners |
| `admin` | Reserved for future use | — | — |

**Critical**: The `busybox` user is **not** the end-user's social media account. It is purely an execution context. The user's online identity is managed through Chrome profiles and credentials stored separately.

---

## 2. Display Architecture (X11 + VNC)

BusyBox runs two parallel X11 display sessions:

```
DISPLAY :0  — Physical X11 session (visible on VirtualBox screen)
DISPLAY :98 — TigerVNC virtual display (automation runs here)
```

### DISPLAY :0 — The "Window"

- Started by `busybox` user via autologin on `tty1` → `startx`
- Runs Openbox window manager
- Contains: **VNC Viewer in fullscreen mode** (`vncviewer -fullscreen localhost:5998`)
- Acts as a "window" into what is happening on DISPLAY :98
- Resolution: 1280x768 (VirtualBox VM default)
- The physical VirtualBox screen shows exactly this

### DISPLAY :98 — The "Engine"

- Started by `vncserver.service` (systemd, enabled at boot)
- TigerVNC server: `Xtigervnc :98` on port **5998** (localhost only)
- Runs independently of :0 — survives if :0 restarts
- Resolution: 800x600 (configured in `/home/busybox/.vncserver`)
- Contains: Openbox + tint2 + Chrome + all automation scripts
- **All plugins operate in this display** (`DISPLAY=:98`)

### Why This Architecture?

```
Problem: Chrome automation must run in a real X11 session (not Xvfb)
         but the user must be able to see what's happening remotely.

Solution:
  :98 = Real VNC session with Chrome (full X11, GPU-less but real)
  :0  = VNC Viewer showing :98 (the "monitor" for the VM)
  
Future: NoVNC → user watches :98 stream from any web browser via HTTPS
```

### Port Map

| Service | Protocol | Bind Address | Port | Description |
|---------|----------|--------------|------|-------------|
| TigerVNC | TCP | 127.0.0.1 | 5998 | VNC server (display :98) |
| SSH | TCP | 0.0.0.0 | 22 | SSH access (in VM) |
| SSH (host) | TCP | 0.0.0.0 | 2201 | VirtualBox NAT forward to VM:22 |
| NoVNC | TCP | 0.0.0.0 | 443 | **Planned** — HTTPS web access |

---

## 3. Process Map

Full process tree of a running BusyBox instance (annotated):

```
systemd (PID 1)
├── vncserver.service          # Starts TigerVNC on boot
│   └── vncserver :98          # TigerVNC perl wrapper
│       ├── Xtigervnc :98      # X server on port 5998 (DISPLAY :98 engine)
│       ├── Xtigervnc-session  # Session startup script
│       │   ├── openbox        # Window manager for :98
│       │   ├── tint2 (mask)   # Panel — task bar (mask config)
│       │   ├── tint2 (panel)  # Panel — main panel (panel config)
│       │   └── xcompmgr       # Compositor (transparency effects)
│       └── ssh-agent          # SSH agent for :98 session
│
├── getty@tty1 (autologin: busybox)
│   └── bash (.profile)        # Autologin triggers startx
│       └── startx             # Starts DISPLAY :0
│           └── xinit
│               ├── Xorg :0    # X server for physical screen
│               └── .xinitrc   # Runs xt.sh → xterm panels
│                   ├── openbox (DISPLAY :0)
│                   ├── xcompmgr
│                   └── vncviewer -fullscreen localhost:5998  # KEY: shows :98 on :0
│
└── screen sessions (user: busybox, all on DISPLAY :98):
    ├── fb:98                  # Main Facebook plugin
    │   └── /opt/busybox/plugins/fb/fb
    │       ├── google-chrome  # Browser (incognito, no GPU)
    │       └── cat (pipe)     # stdout/stderr pipes
    ├── fb-scroll:98           # Scroll behavior plugin
    │   └── /opt/busybox/plugins/fb/fb-scroll
    └── fb-walking-around:98   # URL navigation plugin
        └── /opt/busybox/plugins/fb/fb-walking-around
            ├── xclip          # Clipboard management
            └── zenity         # UI dialogs (pause notifications)
```

### Process Lifecycle

```
Boot
 │
 ├─[1]─ systemd starts vncserver.service
 │      └─ TigerVNC :98 starts (DISPLAY :98 ready)
 │         └─ Openbox + tint2 start on :98
 │
 ├─[2]─ tty1 autologin → busybox user → startx
 │      └─ Xorg :0 starts
 │         └─ vncviewer launches → connects to :98 → fullscreen
 │
 ├─[3]─ busybox.service OR manual:
 │      screen -dmS fb:98 /opt/busybox/plugins/fb/fb
 │      └─ Chrome opens on DISPLAY :98
 │         └─ fb-scroll and fb-walking-around start
 │
 └─[4]─ Runtime loop (100 iterations):
        walking_around_wall() → random URL → locate elements
        → human-like keys → pause → repeat
```

---

## 4. Screen Sessions

GNU Screen is used as a process supervisor for automation scripts. Each session is bound to a specific display:

| Session Name | Display | Script | Purpose |
|-------------|---------|--------|---------|
| `fb:98` | :98 | `plugins/fb/fb` | Main plugin: opens Chrome, positions window, initial setup |
| `fb-scroll:98` | :98 | `plugins/fb/fb-scroll` | Scrolls content feed, memory-aware |
| `fb-walking-around:98` | :98 | `plugins/fb/fb-walking-around` | Navigates between URLs, simulates browsing |
| `mouse-move:98` | :98 | `mouse-move` | Random mouse movement (anti-detection) |
| `windows-uneeded-close:98` | :98 | `windows-uneeded-close.sh` | Closes unexpected popup windows |

**Naming convention**: `<plugin>:<display>` — allows multiple plugins on multiple displays simultaneously.

---

## 5. Plugin Architecture

Plugins live in `/opt/busybox/plugins/<name>/` and are launched by the busybox service.

### Current Plugin Structure

```
/opt/busybox/plugins/
├── fb/                        # Facebook plugin
│   ├── fb                     # Main script (entry point)
│   ├── fb-scroll              # Scroll behavior
│   ├── fb-walking-around      # URL navigation + interaction
│   ├── img/                   # CV templates for FB UI elements
│   │   ├── fb-button-allow-all-cookies.jpg
│   │   ├── fb--post-frame--left-bottom-edge.png
│   │   ├── fb-alert--push-button-blue--back-to-safety.jpg
│   │   └── ... (screenshot templates)
│   └── data/                  # Plugin runtime data
└── yo/                        # YouTube plugin (planned/skeleton)
```

### Plugin Contract

Every plugin MUST:
1. Read global config: `source /opt/busybox/busybox.cfg`
2. Read global functions: `source /opt/busybox/busybox.sh`
3. Set `DISPLAY` and `XAUTHORITY` for X11 operations
4. Write status to: `/opt/busybox/tmp/<plugin_name><DISPLAY>-status`
5. Write logs to: `/var/log/busybox.log`

### Plugin Language Support (Roadmap)

| Language | Status | Detection Method |
|----------|--------|-----------------|
| Bash | ✅ Current | Shebang `#!/bin/bash` |
| Python | ✅ Current | Via `/opt/venv/bin/python` |
| Go | 🔲 Planned | Binary detection + exec |
| Ruby | 🔲 Planned | Shebang `#!/usr/bin/ruby` |
| AI Agent | 🔲 Planned | Special manifest + LLM API call |

### Adding a New Plugin

```bash
# Create plugin directory
mkdir -p /opt/busybox/plugins/myplatform/

# Create entry script
cat > /opt/busybox/plugins/myplatform/myplatform << 'EOF'
#!/bin/bash
source /opt/busybox/busybox.cfg
source /opt/busybox/busybox.sh
SCRIPT="myplatform"
# ... plugin logic
EOF
chmod +x /opt/busybox/plugins/myplatform/myplatform

# Launch via screen
screen -dmS myplatform:98 /opt/busybox/plugins/myplatform/myplatform
```

---

## 6. Computer Vision Engine — Busyman

BusyBox reads all information from the browser screen using Computer Vision.
It never calls any platform API. The **Busyman API** is the internal translation
layer between plugin intents and CV + input operations.

```
Plugin intent: "accept cookies"
      │
      ▼
Busyman: locate fb-button-allow-all-cookies.jpg → found at (320, 450)
      │
      ▼
xdotool mousemove 320 450 && xdotool click 1
```

### The `locate` script — low-level CV primitive

Location: `/opt/busybox/locate`

```
/opt/venv/bin/python /opt/busybox/locate -i <image.png> -a <action>
```

### Actions

| Action | Description |
|--------|-------------|
| `move` | Move mouse to found element location |
| `click` | Click on found element |
| `circle` | Draw circle around element (debug/visual) |
| `squere` | Draw square around element |
| `x-corner` | Mark corners of element |
| `x-edge` | Mark edges of element |

### Image Template Naming Convention

Templates use descriptive names for maintainability:

```
<platform>--<context>--<element-type>--<description>.<ext>

Examples:
  fb--post-frame--left-bottom-edge.png
  fb-alert--push-button-blue--back-to-safety.jpg
  fb-button-allow-all-cookies.jpg
  fb--message-you-are-temporarily-blocked.png
```

### Screenshot Lifecycle

Templates are **operational, not permanent**:
- Created with `scrot` during sessions
- Used for element detection during current run
- Cleaned/rotated regularly (same day)
- Not version-controlled (excluded via `.gitignore`)

---

## 7. Configuration System

### `/opt/busybox/busybox.cfg` — Global Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PROJECT` | `busybox` | Project name |
| `BUSYUSER` | `busybox` | Execution user |
| `BR01` | `google-chrome` | Browser executable |
| `SPOT01` | `meta` | Target platform name |
| `SPOT01url` | `https://meta.com` | Starting URL |
| `BR01x` / `BR01y` | `1160 / 852` | Browser window size |
| `POSITION_x/y` | `137 / -81` | Browser window position |
| `kd` | `200` | Key delay [ms] |
| `kds` | `50` | Key delay short [ms] |
| `kdl` | `1000` | Key delay long [ms] |
| `sql_engine` | `sqlite3` | Database engine |
| `pause_time` | `5` | Initial pause duration [s] |

### `/opt/busybox/busybox.yml` — Extended Configuration

YAML config parsed by `parse_yaml()` function. Used for structured configuration beyond simple variables.

### `/opt/busybox/busybox.sh` — Global Functions Library

Provides: `echoinfo`, `echoerror`, `echofunc`, `echopause`, `gen_random`, `busybox_log` and all color variables.

---

## 8. Database Layer

### Current State (Beta)

- Engine: SQLite3
- Location: `/opt/busy/fb/db/fb_<login>.db` (per-account)
- Schema: Prototype — subject to complete redesign

### Planned Tables (from README)

| Table | Platform | Purpose |
|-------|----------|---------|
| `fb_user` | Facebook | Account credentials and profile data |
| `fb_posts` | Facebook | Content queue for posting |
| `fb_groups` | Facebook | Group membership and targets |
| `fb_pages` | Facebook | Page management |
| `fb_plan` | Facebook | Action scheduling |
| `yo_user` | YouTube | YouTube account data |
| `in_user` | Instagram | Instagram account data |
| `socialmedia` | All | Shared cross-platform data |

### Future Considerations

- SQLite → more scalable solution for distributed use case
- Blockchain-based account synchronization (under consideration)
- No sensitive credentials in database (credential management TBD)

---

## 9. Network Architecture

### VM Network (Current)

```
Host machine
└── VirtualBox NAT
    ├── host:2201 → VM:22  (SSH access to VM)
    └── VM has internet access via NAT
```

### Distributed Mesh (Future)

All BusyBox VMs will be connected via underlay mesh network:

```
BusyBox VM (user A, Poland)
BusyBox VM (user B, Germany)      ← All connected via ZeroTier/Tailscale/Nebula
BusyBox VM (user C, Brazil)          (NETOL infrastructure)
         └────────── P2P coordination, task exchange, telemetry
```

### NoVNC (Planned)

```
User's browser (HTTPS)
    ↓
NoVNC WebSocket server (VM)
    ↓
DISPLAY :98 (TigerVNC stream)
    ↓
Chrome automation running
```

---

## 10. Deployment Model

### Current: Developer/CI Mode

```
1. Fresh Debian 12 VM
2. wget initiv && bash initiv install  → Stage 0 (~20 min)
3. Reboot → Stage 1 auto (~45 min)
4. Reboot → Stage 2 auto (~20 min)
5. Running busybox VM
```

### Target: End User Mode

```
1. Download busybox.ova / busybox.vmdk
2. Import into VirtualBox / VMware
3. Boot VM → Welcome Screen appears
4. Fill in: select platforms, configure accounts
5. BusyBox starts automatically
```

### Scale Model

Each VM is a **self-contained unit**:
- One VM = one `busybox` user = multiple Chrome profiles (multiple accounts)
- One display = one account session
- Multiple displays (`:98`, `:99`, `:100`) = multiple simultaneous accounts
- VMs are independent — no central server required for operation

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Version**: 1.1.23-beta
