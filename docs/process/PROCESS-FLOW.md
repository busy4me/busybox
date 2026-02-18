# BusyBox — Complete Process Flow

> **Step-by-step description of everything that happens from installation to what you see on the VirtualBox screen.**

---

## Overview

BusyBox has two main flows:

1. **Installation Flow** — happens once, transforms a bare Debian into a running BusyBox
2. **Runtime Flow** — happens continuously after installation, 24/7

---

## PART 1: Installation Flow

### Prerequisites

- VirtualBox host machine (Linux/Windows/macOS)
- Fresh Debian 12 (bookworm) minimal install — base system, no GUI
- Internet connection
- ~10GB disk space, ~2GB RAM allocated to VM

### Stage 0 — Initial System Preparation (`initiv install` / `initiv 0`)

Triggered by: `wget https://raw.githubusercontent.com/busy4me/busybox/main/root/initiv && bash ./initiv install`

```
Step 1:  Self-update check (initiv downloads newer version of itself if available)
Step 2:  Check distro (Debian 12 / bookworm / amd64 detected)
Step 3:  Fix apt/dpkg issues (__fix)
Step 4:  Remove unnecessary packages (__remove_packages)
         Removed: acpi, acpid, eject, os-prober, laptop-detect, manpages, nano,
                  tasksel, traceroute, usbutils, vim, console-setup, kbd, pciutils, apparmor
Step 5:  Update apt repositories → Debian 12 bookworm sources configured
Step 6:  Install base packages (__install): grub2-splashimages, fbi, dbus, openssh-server
Step 7:  Install system utilities (__install_stuff1):
         locales, sudo, openssl, bc, xloadimage, xli, xosd-bin, parted
Step 8:  Configure system tuning (__tunning):
         - SSH: PermitRootLogin yes
         - APT: Install-Recommends false
         - GRUB: timeout=0, splash screen, quiet boot
         - systemd: minimal logging (emerg only), no status display
         - journald: Storage=none (no journal)
Step 9:  Extend disk partition to 10GB (__parted)
Step 10: Set hostname based on hardware UUID + MAC address
Step 11: Download animation files for boot screen
Step 12: Set up autologin:
         - tty1: autologin as 'busybox' user (triggers startx automatically)
         - tty2: autologin as 'root' (for maintenance)
Step 13: Set autostart: .profile → startx on tty1
Step 14: Set .xinitrc → runs anime.sh + xt.sh on X start
Step 15: Create recovery script (initivRecovery)
Step 16: System reboot → Stage 1 starts automatically after reboot
```

**Duration**: ~20 minutes  
**Result**: System ready to reboot into Stage 1

---

### Stage 1 — Software Installation (`initiv 1` or auto after Stage 0 reboot)

Triggered by: `initiv-1.service` OR root autologin on tty1 running `initiv -k 0`

```
Step 1:  Install main package bundle (__install_stuff2):
         curl, wget, openbox, xdotool, wmctrl, netcat, xcompmgr, feh, bc, ntp,
         zenity, xclip, ntpdate, scrot, screen, sqlite3, xvfb, tint2, psmisc,
         ffmpeg, unzip, nginx

Step 2:  Install Google Chrome (__install_stuff3):
         - Add Google signing key
         - Add Google Chrome repository
         - Install google-chrome-stable

Step 3:  Install TigerVNC (__install_stuff4):
         - tigervnc-standalone-server, tigervnc-viewer, tigervnc-common, tigervnc-tools
         - Create ~/.vncserver script (manages VNC on display :98, port 5998)
         - Create /etc/systemd/system/vncserver.service (enabled, starts at boot)
         - Set VNC password: "busybox" (stored in ~/.vnc/passwd)
         - Disable vncconfig in Xtigervnc-session

Step 4:  Install Python + automation libraries (__install_stuff5):
         System packages: python3, python3-pip, python3-xlib, python3-tk,
                          python3-dev, python3-wheel, python3-setuptools,
                          python3-pillow, python3-venv
         Virtual env at: /opt/venv (owned by busybox user)
         Python packages in venv: numpy, config, pyyaml, opencv-contrib-python,
                                  imutils, tzupdate, pyautogui, sentry-sdk

Step 5:  Create busybox user:
         - useradd with groups: cdrom, floppy, dip, plugdev, netdev, audio, video, sudo
         - NOPASSWD sudo for all commands
         - Added to /etc/cron.allow
         - SSH keys copied from root → /home/busybox/.ssh/

Step 6:  Install busybox project (__install_project):
         - Set up logrotate for /var/log/busybox.log
         - Create /opt/busybox/data/{files,images,sounds,videos}
         - Configure bash aliases for busybox user
         - Set vm.swappiness=10
         - Download wallpapers from GitHub
         - Configure Openbox autostart:
             xrandr --output Virtual1 --mode 800x600
             feh --bg-scale wallpaper
             xset -dpms (disable screen blanking)
             tint2 (panels)
             vncviewer -fullscreen localhost:5998  ← KEY: shows :98 on :0
         - Run /opt/busybox/update -t full → downloads all busybox files
         - Clean up: remove exim4, autoremove, apt clean

Step 7:  ZeroTier installation (__zerotier):
         - Install ZeroTier
         - Join network 932df01efb1ebd71 (busybox mesh network)

Step 8:  NTP sync: ntpdate time.nist.gov
Step 9:  System reboot → Stage 2 (busybox runtime) starts
```

**Duration**: ~45 minutes  
**Result**: Full software stack installed, VNC configured, busybox user ready

---

### Stage 2 — Busybox Project Download & Runtime Start

```
Step 1:  /opt/busybox/update -t full runs:
         - Downloads all busybox scripts from GitHub
         - Installs: busy, busybox.py, busybox.sh, frame00, locate, menu-init,
                     mouse-move, plugins/*, etc.
         - Sets permissions and PATH

Step 2:  vncserver.service starts (systemd):
         - TigerVNC launches on DISPLAY :98
         - Password: "busybox"
         - Resolution: 800x600, depth 16
         - Openbox + tint2 + xcompmgr start on :98

Step 3:  tty1 autologin → busybox user → startx → DISPLAY :0:
         - Xorg starts on :0
         - .xinitrc runs:
             /opt/anime.sh &        ← animation in framebuffer
             /opt/xt.sh             ← xterm panels with time/IP/progress
         - Openbox starts on :0
         - vncviewer connects to :5998 → fullscreen on :0

Step 4:  busybox.service OR manual plugin start:
         screen -dmS fb:98 /opt/busybox/plugins/fb/fb
         screen -dmS fb-scroll:98 /opt/busybox/plugins/fb/fb-scroll
         screen -dmS fb-walking-around:98 /opt/busybox/plugins/fb/fb-walking-around
```

**Result**: System is live and running

---

## PART 2: Runtime Flow

### What You See on Screen

```
VirtualBox window (host machine)
  └── DISPLAY :0 (Xorg, 1280x768)
       └── VNC Viewer fullscreen
            └── DISPLAY :98 (TigerVNC, 800x600)
                 ├── Openbox desktop (black wallpaper or animated)
                 ├── tint2 panels (bottom bar)
                 └── Google Chrome (800x600 window, positioned at x=137, y=-81)
                      └── Currently showing: Facebook / YouTube / Twitch / Instagram
```

### The Automation Loop (fb-walking-around)

```
LOOP (100 iterations):
│
├─ [1] Pick random URL from list:
│       https://www.facebook.com/
│       https://www.facebook.com/videos
│       https://www.facebook.com/watch/
│       https://www.facebook.com/watch/live/
│       https://www.youtube.com/watch
│       https://instagram.com/
│       https://tiktok.com/
│       https://www.twitch.tv/
│       (+ others)
│
├─ [2] Navigate Chrome to URL:
│       xdotool key Ctrl+l → type URL → Return
│
├─ [3] Wait for page load (random 1-5s)
│
├─ [4] Take screenshot for CV detection
│
├─ [5] check_alerts():
│       - Detect cookie banner → click Accept
│       - Detect "temporarily blocked" → pause 30-360s
│       - Detect "Leave This Page" → handle
│       - Detect security alerts → navigate back
│
├─ [6] video() — if URL is video page:
│       - Detect LIVE button → click + watch 2-12 min
│       - Detect Share button → copy link → navigate to video URL
│
├─ [7] locate_elements():
│       CV detection of known UI elements (post frames, cross icons)
│       → move mouse to them (natural interaction)
│
├─ [8] Human behavior simulation:
│       press_keys_01/02/03/04():
│         - Random Tab/Escape sequences
│         - Random Down/Up/Page_Down sequences
│         - Random mouse movements
│         - Delays: 200-1200ms between keystrokes
│
├─ [9] Time-aware Enter key (press_enter_morning_and_afternoon_01):
│       Only press Enter between: 9AM-12PM and 3PM-6PM
│
├─ [10] detect_input_field():
│        - Copy to clipboard and check if URL bar or input field focused
│        - If input field: press Escape to exit
│
├─ [11] switch_to_english():
│        - Detect language settings → switch to English (US) if needed
│
├─ [12] page_probe():
│        - Full clipboard-based page content check
│        - Pattern matching for: restricted, blocked, follow, cookies
│
├─ [13] extra_pause():
│        - Check current hour
│        - If outside hours (5-10h, 13-16h, 17-22h): sleep 1 hour
│        - If inside hours: continue immediately
│
├─ [14] Random pause 1-60 seconds (zenity progress dialog)
│
└─ Repeat from [1]
```

### The Scroll Loop (fb-scroll)

```
LOOP (while memory < 1024MB):
│
├─ Activate Chrome window (xdotool)
├─ Set window opacity to 70% (transset)
├─ Scroll down 20 steps (xdotool key Down × 20)
├─ Check memory usage (free -m)
├─ Show progress in zenity dialog
├─ If scroll_count > 200: stop
└─ Scroll back to top (Page_Up × 3, Home)
```

### Wallpaper Animation (fb main plugin)

The wallpaper cycles through images (wall00.png → wall03.png) every ~1 second during active operations. This is not just cosmetic — it provides:
- Visual confirmation that the script is running
- Natural-looking screen changes (anti-detection)
- Debugging signal (if wallpaper stops changing, script may be stuck)

---

## Key State Machine

```
STATUS FILES: /opt/busybox/tmp/<script><DISPLAY>-status

fb:98          → "start" (initializing) | "done" (sleeping 86400s = 1 day)
fb-scroll:98   → "start" | "done" (sleeping 3600s = 1 hour)
fb-walking-around:98 → no explicit status file
```

---

## Error Handling & Recovery

| Scenario | Detection | Response |
|----------|-----------|---------|
| Cookie banner | CV detect `fb-button-allow-all-cookies.jpg` | Click it |
| Temporarily blocked | CV detect blocked message OR text in clipboard | Pause 30-360s, gradually reduce pause |
| Input field focused | Random char injected + clipboard check | Press Escape + Tab |
| URL bar focused | Clipboard starts with "https://" | Press Tab × 4 |
| Window closed | `xdotool search` returns empty | Re-open Chrome, navigate |
| Memory > 1024MB | `free -m` check | Stop scrolling, scroll back to top |
| Security alert | CV detect blue "Back to Safety" button | Click it |
| "Leave This Page" dialog | Clipboard text match | Type URL in find bar, dismiss |

---

## Log Files

| File | Content | Rotation |
|------|---------|---------|
| `/var/log/busybox.log` | All colored log output from all scripts | 7 days, 2MB max |
| `/var/log/busybox-nocolor.log` | Plain log (no ANSI codes) for time-series DB | — |

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Version**: 1.1.23-beta
