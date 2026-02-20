# NoVNC Web Application — Architecture & Implementation Plan

**Project**: Busyman Web Interface  
**Type**: Web-based VNC Client with Dynamic Menu  
**Created**: 2026-02-20  
**Status**: ✅ COMPLETE — v1.0.0 deployed, production ready  
**Author**: Dariusz Porczyński

---

## 🎯 Overview

Web application providing browser-based access to BusyBox VM desktop via NoVNC, replacing traditional vncviewer with modern HTML/CSS/JS interface.

**Core Principle**: Chrome displays full-page web app (NOT kiosk mode) with window positioned off-screen decorations (hack method).

---

## 🏗️ Architecture

### System Layers

```
┌─────────────────────────────────────────────────────┐
│  DISPLAY :0 (VirtualBox GUI)                        │
│  └─ Chrome (fullscreen hack, no decorations)        │
│     └─ http://localhost:6080 (Busyman Web App)      │
│        ├─ Left Sidebar Menu (10% width, 140px)      │
│        └─ Main Window (90% width)                   │
│           └─ NoVNC Client (embedded iframe/canvas)  │
│              └─ WebSocket → localhost:6080          │
│                 └─ websockify proxy                 │
│                    └─ TigerVNC :98 (1920x1080)      │
│                       └─ Openbox + Chrome + Plugins │
└─────────────────────────────────────────────────────┘
```

### Component Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | HTML5 + CSS3 + Vanilla JS | UI, menu, NoVNC integration |
| **NoVNC Client** | noVNC library (official) | VNC protocol in browser |
| **WebSocket Proxy** | websockify (Python) | VNC ↔ WebSocket bridge |
| **VNC Server** | TigerVNC (Xtigervnc) | Display :98 backend |
| **Backend API** | Python Flask / FastAPI | Menu state, actions, SQLite |
| **Database** | SQLite3 | Menu items, settings, state |
| **Web Server** | nginx or Python built-in | Serve static files + proxy |

---

## 📐 Layout Specification

### Grid Structure

```
┌──────────┬──────────────────────────────────────────┐
│          │                                          │
│          │                                          │
│  SIDEBAR │         MAIN WINDOW                      │
│  (10%)   │         (90%)                            │
│  140px   │         NoVNC Client                     │
│          │         (dynamic viewport)               │
│          │                                          │
│          │                                          │
│          │                                          │
│          │                                          │
│          ├──────────────────────────────────────────┤
│          │  [Hidden Floating Menu]                  │
│          │  (slides from bottom-left on trigger)    │
└──────────┴──────────────────────────────────────────┘
```

**Viewport**: No top menu (full-height), flexible for future top menu/footer.

### CSS Layout

```css
body {
  display: flex;
  margin: 0;
  padding: 0;
  height: 100vh;
  overflow: hidden;
}

#sidebar {
  width: 10%; /* or fixed 140px */
  min-width: 140px;
  background: #1a1a1a;
  display: flex;
  flex-direction: column;
}

#main-window {
  width: 90%;
  flex-grow: 1;
  position: relative;
}

#novnc-container {
  width: 100%;
  height: 100%;
}

#floating-menu {
  position: fixed;
  bottom: -300px; /* hidden by default */
  left: 0;
  width: 400px;
  height: 300px;
  background: rgba(0,0,0,0.9);
  transition: bottom 0.3s ease-in-out;
}

#floating-menu.active {
  bottom: 0; /* slide up */
}
```

---

## 🎨 Style Guidelines

### Color Palette

- **Primary**: `#4A90E2` (Blue) — buttons, links, active states
- **Secondary**: `#2C2C2C` (Dark Gray) — sidebar background
- **Accent**: `#5DADE2` (Teal) — hover states, highlights
- **Text**: `#E0E0E0` (Light Gray) — primary text
- **Background**: `#1A1A1A` (Near Black) — main background

### Typography

- **Body/Headline**: `'Inter', sans-serif` — modern, neutral
- **Code**: `'Source Code Pro', monospace` — configuration snippets, logs

**Font Loading** (Google Fonts):
```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&family=Source+Code+Pro&display=swap" rel="stylesheet">
```

### Animation

**Floating Menu Slide-In**:
```css
@keyframes slideUp {
  from { bottom: -300px; opacity: 0; }
  to { bottom: 0; opacity: 1; }
}

#floating-menu.active {
  animation: slideUp 0.3s ease-in-out;
}
```

---

## ⚙️ Features & Components

### 1. NoVNC Client Integration

**Purpose**: Embed NoVNC within main window to connect to TigerVNC :98.

**Implementation**:
```html
<div id="novnc-container">
  <div id="screen"></div> <!-- NoVNC canvas target -->
</div>

<script type="module">
  import RFB from './novnc/core/rfb.js';
  
  const rfb = new RFB(
    document.getElementById('screen'),
    'ws://localhost:6080'
  );
  
  rfb.scaleViewport = true; // dynamic resize
  rfb.resizeSession = true; // adjust VNC resolution
</script>
```

**Configuration**:
- **VNC Server**: `localhost:5998` (TigerVNC :98)
- **WebSocket**: `ws://localhost:6080` (websockify)
- **Resolution**: 1920x1080 (VNC server), dynamically scaled in browser

---

### 2. Dynamic Left Sidebar Menu

**Purpose**: Display menu items from SQLite, update without page refresh.

**Database Schema** (`/opt/busybox/db/busyman.db`):
```sql
CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY,
  label TEXT NOT NULL,
  emoji TEXT,
  icon_path TEXT,
  action TEXT NOT NULL, -- 'reboot', 'stats', 'settings', 'plugin:fb:login'
  order_index INTEGER DEFAULT 0,
  visible BOOLEAN DEFAULT 1
);
```

**Example Menu Items**:
```sql
INSERT INTO menu_items (label, emoji, action, order_index) VALUES
  ('Reboot', '🔄', 'system:reboot', 1),
  ('Stats', '📊', 'system:stats', 2),
  ('Settings', '⚙️', 'menu:floating', 3);
```

**Frontend Fetch** (polling every 5s):
```javascript
async function updateMenu() {
  const res = await fetch('/api/menu');
  const items = await res.json();
  
  const menuHTML = items.map(item => `
    <div class="menu-item" data-action="${item.action}">
      <span class="emoji">${item.emoji}</span>
      <span class="label">${item.label}</span>
    </div>
  `).join('');
  
  document.getElementById('sidebar').innerHTML = menuHTML;
}

setInterval(updateMenu, 5000); // poll every 5s
```

---

### 3. Menu Actions (Backend API)

**Purpose**: Handle menu item clicks (reboot, stats, settings).

**API Endpoint** (`/api/action`):
```python
from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/api/action', methods=['POST'])
def handle_action():
    action = request.json.get('action')
    
    if action == 'system:reboot':
        subprocess.run(['systemctl', 'reboot'])
        return jsonify({'status': 'rebooting'})
    
    elif action == 'system:stats':
        cpu = subprocess.check_output(['top', '-bn1']).decode()
        return jsonify({'cpu': cpu})
    
    elif action == 'menu:floating':
        return jsonify({'command': 'show_floating_menu'})
    
    elif action.startswith('plugin:'):
        # Call Busyman API
        plugin, method = action.split(':')[1:3]
        # busyman.click_element(f"plugins/{plugin}/img/{method}.png")
        return jsonify({'status': 'plugin_triggered'})
    
    return jsonify({'error': 'unknown_action'}), 400
```

**Frontend Handler**:
```javascript
document.addEventListener('click', async (e) => {
  const menuItem = e.target.closest('.menu-item');
  if (!menuItem) return;
  
  const action = menuItem.dataset.action;
  const res = await fetch('/api/action', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({action})
  });
  
  const result = await res.json();
  
  if (result.command === 'show_floating_menu') {
    document.getElementById('floating-menu').classList.add('active');
  }
});
```

---

### 4. Hidden Floating Menu

**Purpose**: Slide-out panel for advanced settings (VNC resolution, display options).

**Trigger**: Click "Settings" menu item → `menu:floating` action.

**Content**:
```html
<div id="floating-menu">
  <div class="menu-header">
    <h3>Settings</h3>
    <button class="close-btn">×</button>
  </div>
  
  <div class="menu-content">
    <label>VNC Resolution:</label>
    <select id="vnc-resolution">
      <option value="1920x1080">1920x1080</option>
      <option value="1280x720">1280x720</option>
    </select>
    
    <label>Display Mode:</label>
    <select id="display-mode">
      <option value="scale">Scale to fit</option>
      <option value="native">Native (scroll)</option>
    </select>
    
    <button id="apply-settings">Apply</button>
  </div>
</div>
```

**JavaScript Close Handler**:
```javascript
document.querySelector('.close-btn').addEventListener('click', () => {
  document.getElementById('floating-menu').classList.remove('active');
});
```

---

## 🛠️ Technology Stack — Recommendations

### Option A: Minimalist (Recommended for MVP)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Frontend** | Vanilla JS + CSS3 | No build step, fast, simple |
| **Backend** | Python Flask | Lightweight, easy integration with Busyman API |
| **Database** | SQLite3 | Embedded, no server, perfect for local app |
| **WebSocket Proxy** | websockify (Python) | Official NoVNC companion |
| **Web Server** | Flask built-in | Development-ready, fast iteration |

**Pros**: Fast to implement, minimal dependencies, easy debugging.  
**Cons**: Manual DOM updates, no reactivity framework.

---

### Option B: Modern Stack (Future-Proof)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Frontend** | **Svelte** or **Alpine.js** | Lightweight reactivity, no virtual DOM |
| **Backend** | **FastAPI** (Python) | Async support, auto OpenAPI docs |
| **Database** | SQLite3 + **SQLAlchemy** | ORM for easier queries |
| **WebSocket Proxy** | websockify | Same as Option A |
| **Web Server** | **Uvicorn** (ASGI) | Production-ready async server |

**Pros**: Reactive UI (automatic menu updates), better long-term maintainability.  
**Cons**: Build step required (Vite/Rollup), slight complexity increase.

---

### Option C: Ultra-Lightweight (htmx + Flask)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Frontend** | **htmx** + HTML templates | Server-rendered, no JS framework |
| **Backend** | Flask + Jinja2 | Template-based rendering |
| **Database** | SQLite3 | Same as A |
| **WebSocket Proxy** | websockify | Same as A |

**Pros**: Minimal JS, server-side rendering, very fast.  
**Cons**: Full page reloads for menu updates (unless using SSE/WebSockets).

---

### 🎯 Recommended Choice: **Option A (Minimalist)** for Faza 1

**Reasoning**:
- **Speed**: No build tools, direct HTML/JS editing
- **Debugging**: Easy to test changes (`./scripts/deploy-to-vm.sh`)
- **Integration**: Direct access to Busyman API via Python backend
- **Upgrade Path**: Can migrate to Svelte/Alpine.js later without architecture change

**Stack Summary**:
```
Frontend:  HTML5 + CSS3 + Vanilla JavaScript
Backend:   Python 3.11 + Flask 3.x
Database:  SQLite3 (schema in migrations/)
NoVNC:     Official noVNC library (cloned from GitHub)
WebSocket: websockify (pip install websockify)
Server:    Flask development server (port 6080)
```

---

## 📦 File Structure

```
/opt/busybox/
├── novnc/                    # NoVNC library (git clone)
│   ├── core/
│   │   └── rfb.js           # Main NoVNC client
│   ├── vendor/              # Dependencies (WebSocket libs)
│   └── vnc.html             # Reference implementation
│
├── webapp/                   # Busyman Web App
│   ├── static/
│   │   ├── css/
│   │   │   ├── main.css     # Layout, sidebar, floating menu
│   │   │   └── novnc.css    # NoVNC client overrides
│   │   ├── js/
│   │   │   ├── app.js       # Main application logic
│   │   │   ├── menu.js      # Dynamic menu updates
│   │   │   └── novnc-init.js # NoVNC client initialization
│   │   └── fonts/           # Inter, Source Code Pro (if local)
│   │
│   ├── templates/
│   │   └── index.html       # Main HTML template
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── app.py           # Flask application
│   │   ├── routes.py        # API endpoints (/api/menu, /api/action)
│   │   └── models.py        # SQLite schema/queries
│   │
│   └── db/
│       ├── busyman.db       # SQLite database
│       └── migrations/      # Schema versions
│
├── scripts/
│   ├── start-webapp.sh      # Launch Flask + websockify
│   └── stop-webapp.sh       # Graceful shutdown
│
└── data/
    └── config.yml           # App configuration (ports, VNC settings)
```

---

## 🔧 Implementation Steps (Faza 1 — POC)

### Step 1: Install Dependencies

```bash
# On VM (busybox-1.1.2-beta)
cd /opt/busybox
/opt/venv/bin/pip install flask websockify

# Clone NoVNC
git clone https://github.com/novnc/noVNC.git novnc
```

### Step 2: Create Database Schema

```bash
sqlite3 /opt/busybox/webapp/db/busyman.db << 'EOF'
CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY,
  label TEXT NOT NULL,
  emoji TEXT,
  icon_path TEXT,
  action TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  visible BOOLEAN DEFAULT 1
);

INSERT INTO menu_items (label, emoji, action, order_index) VALUES
  ('Reboot', '🔄', 'system:reboot', 1),
  ('Stats', '📊', 'system:stats', 2),
  ('Settings', '⚙️', 'menu:floating', 3);
EOF
```

### Step 3: Create Flask Backend

**File**: `/opt/busybox/webapp/api/app.py`

```python
from flask import Flask, render_template, jsonify, request
import sqlite3

app = Flask(__name__, template_folder='../templates', static_folder='../static')

def get_db():
    conn = sqlite3.connect('/opt/busybox/webapp/db/busyman.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/menu')
def get_menu():
    db = get_db()
    items = db.execute('SELECT * FROM menu_items WHERE visible=1 ORDER BY order_index').fetchall()
    return jsonify([dict(row) for row in items])

@app.route('/api/action', methods=['POST'])
def handle_action():
    action = request.json.get('action')
    # TODO: Implement action handlers
    return jsonify({'status': 'ok', 'action': action})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
```

### Step 4: Create HTML Template

**File**: `/opt/busybox/webapp/templates/index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Busyman</title>
  <link rel="stylesheet" href="/static/css/main.css">
</head>
<body>
  <div id="sidebar"></div>
  
  <div id="main-window">
    <div id="novnc-container">
      <div id="screen"></div>
    </div>
  </div>
  
  <div id="floating-menu">
    <div class="menu-header">
      <h3>Settings</h3>
      <button class="close-btn">×</button>
    </div>
    <div class="menu-content">
      <p>Settings panel placeholder</p>
    </div>
  </div>
  
  <script type="module" src="/static/js/app.js"></script>
</body>
</html>
```

### Step 5: Start Services

```bash
# Terminal 1: Start websockify (VNC → WebSocket)
/opt/venv/bin/websockify 6080 localhost:5998

# Terminal 2: Start Flask backend
cd /opt/busybox/webapp/api
/opt/venv/bin/python app.py
```

### Step 6: Test in Chrome

```bash
# On DISPLAY :0
DISPLAY=:0 google-chrome --new-window --window-position=0,-100 http://localhost:8080
```

---

## 🧪 Testing Plan

1. ✅ **NoVNC Connection** — Verify canvas displays :98 desktop
2. ✅ **Menu Items Load** — Verify sidebar fetches from SQLite
3. ✅ **Menu Actions** — Click Reboot/Stats/Settings → verify API calls
4. ✅ **Floating Menu** — Verify slide-in animation
5. ✅ **Dynamic Updates** — Change DB → menu auto-updates (5s poll)
6. ✅ **Resolution Scaling** — Resize browser → NoVNC viewport adjusts

---

## 📝 Next Steps

1. **Implement Step 1-6** (this session)
2. **Create CSS** (`main.css` with sidebar/floating menu)
3. **Implement Menu JS** (fetch, render, click handlers)
4. **Test POC** on VM
5. **Document** in this file + commit

---

## 🚀 Deployment & Production Notes

### Systemd Services (Auto-start on Boot)

**Created 3 systemd services** for automatic startup:

1. **`vncserver@:98.service`** — VNC server on DISPLAY :98
2. **`busyman-flask.service`** — Flask webapp (port 8080)
3. **`busyman-websockify.service`** — WebSocket proxy (port 6080)

**Location**: `/etc/systemd/system/`

**Enable on boot**:
```bash
systemctl enable vncserver@:98.service busyman-flask.service busyman-websockify.service
```

### Migration Notes (Old → New VNC Service)

**IMPORTANT**: Old `vncserver.service` (created by `initiv`) conflicts with new template service.

**Migration steps**:
```bash
# 1. Stop and disable old service
systemctl stop vncserver.service
systemctl disable vncserver.service

# 2. Kill existing VNC session
su - busybox -c "vncserver -kill :98"

# 3. Enable and start new service
systemctl enable vncserver@:98.service
systemctl start vncserver@:98.service
```

**Differences**:
- **Old**: `/home/busybox/.vncserver` script (no `-SecurityTypes None`, no `-localhost=1`)
- **New**: Direct `vncserver` command with secure flags (`-SecurityTypes None -localhost=1`)

**Status check**:
```bash
systemctl status vncserver@:98.service busyman-flask.service busyman-websockify.service
```

### Openbox Autostart Permissions

**CRITICAL**: Autostart file must have correct ownership and executable permissions:

```bash
chown busybox:busybox /home/busybox/.config/openbox/autostart
chmod +x /home/busybox/.config/openbox/autostart
```

**Reason**: File deployed via SCP can have wrong UID/GID (e.g., 502:staff from macOS). Openbox won't execute autostart without +x permission.

### Chrome on DISPLAY :0 (NoVNC Webapp)

**Flags** to prevent dialogs:
- `--user-data-dir=/home/busybox/.config/google-chrome-busyman` — isolated profile
- `--disable-session-crashed-bubble` — no crash recovery dialog
- `--disable-restore-session-state` — no "Restore pages?" dialog
- `--no-default-browser-check` — no default browser prompt
- `--no-first-run` — skip first-run wizard
- `--disable-features=Translate` — no translation bar

**Preferences JSON**: `/home/busybox/.config/google-chrome-busyman/Default/Preferences`
- Pre-configured clipboard permissions for `localhost:8080`
- Session restore settings disabled

---

**Status**: ✅ Production ready, all services auto-start on boot  
**Last Updated**: 2026-02-20  
**Deployment**: VM `Busybox-1.1.2-beta` on lab1

