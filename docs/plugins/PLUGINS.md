# BusyBox — Plugin System

> **How plugins work, how to write them, and what platforms are supported.**

---

## What Is a Plugin?

A plugin is a self-contained automation script (or program) that controls a specific platform or performs a specific task. Plugins run inside the BusyBox X11 session (DISPLAY :98) via GNU Screen.

**Core principle**: One plugin = one behavior unit. Platform plugins handle one platform. Action plugins handle one type of action (e.g., scrolling, liking, posting).

---

## Plugin Directory Structure

```
/opt/busybox/plugins/
├── fb/                        ← Facebook plugin (ACTIVE)
│   ├── fb                     # Entry point — opens Chrome, initial setup
│   ├── fb-scroll              # Scroll behavior script
│   ├── fb-walking-around      # Navigation + interaction loop
│   ├── img/                   # CV image templates for Facebook UI
│   └── data/                  # Runtime data (screenshots, temp files)
└── yo/                        ← YouTube plugin (SKELETON)
    └── ...
```

### Planned Plugins

| Plugin Dir | Platform | Status | Priority |
|-----------|----------|--------|---------|
| `fb/` | Facebook / Meta | ✅ Active | — |
| `yo/` | YouTube | 🔲 Skeleton | High |
| `ig/` | Instagram | 🔲 Planned | High |
| `tt/` | TikTok | 🔲 Planned | Medium |
| `tw/` | Twitter / X | 🔲 Planned | Medium |
| `li/` | LinkedIn | 🔲 Planned | Low |
| `tc/` | Twitch | 🔲 Planned | Medium |

---

## Plugin Contract

Every plugin MUST follow these rules:

### Required

```bash
# 1. Source global config and functions
source /opt/busybox/busybox.cfg
source /opt/busybox/busybox.sh

# 2. Set display variables
export DISPLAY=:98
export XAUTHORITY=/home/busybox/.Xauthority

# 3. Identify itself
SCRIPT="my-plugin"   # used in log lines
PROJECT="busybox"    # always busybox

# 4. Write status
echo "start" > /opt/busybox/tmp/${SCRIPT}${DISPLAY}-status
# ... do work ...
echo "done" > /opt/busybox/tmp/${SCRIPT}${DISPLAY}-status

# 5. Log via logline (pipe output through it)
echo "Starting..." | logline
```

### Logging Format

All log lines follow this format (handled by `logline` function):
```
2026-02-18 23:45:01 busybox fb-walking-around [ INFO ] message text
```

### Launch Method

Plugins are always launched via screen:
```bash
screen -dmS <plugin-name>:<display> /opt/busybox/plugins/<name>/<script>
```

Example:
```bash
screen -dmS fb:98 /opt/busybox/plugins/fb/fb
screen -dmS yo:99 /opt/busybox/plugins/yo/yo
```

---

## Multi-Language Plugin Support

The system is designed to run plugins in any language:

### Bash Plugin (current standard)

```bash
#!/bin/bash
source /opt/busybox/busybox.cfg
source /opt/busybox/busybox.sh
# ... logic
```

### Python Plugin

```python
#!/opt/venv/bin/python
import subprocess, os

os.environ['DISPLAY'] = ':98'
os.environ['XAUTHORITY'] = '/home/busybox/.Xauthority'

# Use busybox Python libraries
import pyautogui
import cv2
# ... logic
```

### Go Plugin (planned)

```bash
# Compile on host, deploy binary
go build -o /opt/busybox/plugins/my-go-plugin/my-go-plugin .

# Plugin manifest (planned)
cat > /opt/busybox/plugins/my-go-plugin/manifest.yml << EOF
name: my-go-plugin
language: go
entry: my-go-plugin
display: ":98"
EOF
```

### AI Agent Plugin (planned)

```yaml
# manifest.yml — defines an AI-driven plugin
name: ai-fb-commenter
language: ai-agent
model: gpt-4o           # or local: ollama/llama3
entry: agent.py         # LangChain / CrewAI based
display: ":98"
capabilities:
  - screenshot          # take screenshots for context
  - pyautogui           # execute actions
  - locate              # CV element detection
```

---

## The `locate` CV Engine

The core tool for all plugins that need to interact with UI elements:

```bash
/opt/venv/bin/python /opt/busybox/locate -i <template.png> -a <action>
```

### Usage Examples

```bash
# Find and click "Accept cookies" button
/opt/venv/bin/python /opt/busybox/locate \
  -i fb-button-allow-all-cookies.jpg -a click

# Find post frame edge and move mouse there
/opt/venv/bin/python /opt/busybox/locate \
  -i fb--post-frame--left-bottom-edge.png -a move

# Debug: circle around found element
/opt/venv/bin/python /opt/busybox/locate \
  -i fb--logo.png -a circle

# Click with offset from center
/opt/venv/bin/python /opt/busybox/locate \
  -i fb-watch--push-button-red--live.jpg -a click --offx=100 --offy=100
```

### Return Value

- `0` = element found and action executed
- `1` = element not found

```bash
if /opt/venv/bin/python /opt/busybox/locate -i element.png -a click; then
    echo "Found and clicked"
else
    echo "Element not found, skip"
fi
```

---

## Image Template Management

### Naming Convention

```
<platform>--<context>--<element-type>--<description>.<ext>

Where:
  platform  = fb, yo, ig, tt, tw ...
  context   = post, alert, button, message, watch, chat ...
  type      = push-button-blue, icon, frame, message ...
  desc      = descriptive-name-with-dashes
  ext       = .png (preferred) or .jpg

Examples:
  fb-button-allow-all-cookies.jpg
  fb--post-frame--left-bottom-edge.png
  fb-alert--push-button-blue--back-to-safety--connection-is-not-private.jpg
  fb--message-you-are-temporarily-blocked.png
  fb-watch--push-button-red--live.jpg
```

### Creating a Template

```bash
# Screenshot full screen
scrot /opt/busybox/plugins/fb/img/full.png

# Screenshot specific region: x,y,width,height
scrot -a 300,150,700,400 /opt/busybox/plugins/fb/img/video-area.jpg

# Crop with ImageMagick (if available)
convert full.png -crop 200x50+400+300 element.png
```

### Template Lifecycle

- Templates are **ephemeral** — created/updated as needed
- Production templates live in `plugins/<name>/img/`
- Runtime screenshots go to `plugins/<name>/data/` or `/opt/busybox/tmp/`
- Templates are NOT committed to git (excluded in .gitignore)

---

## Current Plugin: `fb` (Facebook)

### Entry Point: `fb`

```
fb (main)
├── Reads config (busybox.cfg)
├── Kills existing Chrome/plugin windows
├── Runs feh (set wallpaper)
├── Launches Google Chrome:
│     google-chrome --window-size=900,768
│                   --window-position=140,0
│                   --incognito
│                   --disable-gpu
│                   --disable-notifications
│                   --mute-audio
│                   https://meta.com
├── Waits for Chrome window (xdotool search)
├── Sets window transparency (transset)
├── Positions/resizes window (spot01_position_size):
│     - Reset zoom (Ctrl+0)
│     - Resize to 1160×852
│     - Move to position 137,-81
│     - CV detection of window edges
│     - Click "Allow cookies" button
└── Sleeps 86400s (1 day) → "done" status
```

### Sub-script: `fb-scroll`

```
fb-scroll
├── Checks memory usage
├── Shows current memory in zenity dialog
├── Scrolls down (20 steps × up to 200 iterations)
│     while memory < 1024MB
├── Monitors memory during scroll
├── Shows progress in zenity dialog (always on top)
└── Scrolls back to top → reports "done"
```

### Sub-script: `fb-walking-around`

```
fb-walking-around (100-iteration loop)
├── Picks random URL (Facebook sections + YouTube + Instagram + Twitch)
├── Navigates Chrome to URL
├── check_alerts() — handles all popups/blocks
├── video() — watches/interacts with video if on video page
├── locate_elements() — CV detection + interaction
├── press_keys_01/02/03/04() — human-like keyboard interaction
├── press_enter_morning_and_afternoon_01() — time-aware Enter key
├── detect_input_field() — avoids typing in wrong places
├── switch_to_english() — language detection/switching
├── page_probe() — clipboard-based page content analysis
├── extra_pause() — time-of-day gating (no activity outside hours)
└── Random pause 1-60s
```

---

## Plugin Development Guide

### Step 1: Create Directory

```bash
mkdir -p /opt/busybox/plugins/myplatform/img
mkdir -p /opt/busybox/plugins/myplatform/data
```

### Step 2: Create Entry Script

```bash
cat > /opt/busybox/plugins/myplatform/myplatform << 'SCRIPT'
#!/bin/bash
PROJECT="busybox"
source /opt/${PROJECT}/${PROJECT}.cfg
source /opt/${PROJECT}/${PROJECT}.sh
SCRIPT="myplatform"
LOGFILE=/var/log/${PROJECT}.log

echo "start" > /opt/${PROJECT}/tmp/${SCRIPT}${DISPLAY}-status
echo "${SCRIPT} started" | logline

# Set target URL
TARGET_URL="https://myplatform.com"

# Open browser
$BR01 --window-size="900,768" --incognito --disable-gpu \
  --disable-notifications --mute-audio $TARGET_URL &

# Wait for browser window
xdotool search --sync --onlyvisible --class "$BR01" windowactivate

# Main loop
while true; do
    echo "doing something on myplatform..." | logline
    sleep $(gen_random 30 120)
    xdotool key --delay $kd Down Down Down
done

echo "done" > /opt/${PROJECT}/tmp/${SCRIPT}${DISPLAY}-status
SCRIPT
chmod +x /opt/busybox/plugins/myplatform/myplatform
```

### Step 3: Launch

```bash
# Launch plugin
screen -dmS myplatform:98 /opt/busybox/plugins/myplatform/myplatform

# Monitor
screen -r myplatform:98

# Check status
cat /opt/busybox/tmp/myplatform:98-status
```

### Step 4: Add CV Templates

```bash
# Take screenshot of element to detect
scrot -a 100,200,150,40 /opt/busybox/plugins/myplatform/img/myplatform-button-accept.png
```

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Version**: 1.1.23-beta
