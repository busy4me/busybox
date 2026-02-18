# BusyBox — Authentication & Pairing Flow

> **6-digit code on phone → VM starts → Chrome opens → user logs in visually.**

---

## ⚠️ Core Design Constraint

**BusyBox does NOT use any social media platform APIs.**

This is a fundamental, non-negotiable design principle:

- ❌ No Facebook API / Graph API
- ❌ No Google OAuth for YouTube
- ❌ No Instagram API
- ❌ No platform SDK of any kind
- ❌ No cookies imported from external services

**Why**: Platform APIs require app registration, terms of service compliance, approval
processes, and can be revoked at any time. BusyBox operates independently of all platforms.

**How BusyBox works instead**:
> BusyBox opens a real browser (Google Chrome), renders the actual platform website,
> reads the screen using Computer Vision, and performs actions by simulating
> keyboard and mouse input — exactly like a human would.

The browser IS the interface. No API needed.

---

## Design Principles

1. **Screen-only** — all information comes from reading the browser screen (CV)
2. **Input-only** — all actions are keyboard/mouse simulation (xdotool, pyautogui)
3. **Zero API calls** — BusyBox never calls any platform API endpoint
4. **Zero password storage** — credentials are entered by the user once, visually
5. **Pair once** — after first setup, VM runs fully automatically
6. **busybox.cc as relay only** — relay pairs phone with VM, never touches platform credentials

---

## How Login Actually Works

BusyBox logs into social media platforms the same way a human does:

```
1. Chrome opens facebook.com (or youtube.com, instagram.com...)
2. BusyBox detects the login form via Computer Vision (locate script)
3. BusyBox fills in credentials using keyboard simulation (xdotool type)
4. BusyBox clicks the login button via CV detection + mouse click
5. Chrome session is saved to disk profile
6. On next boot: Chrome loads saved session → already logged in
```

No API. No tokens. No OAuth. Just a browser and a camera.

---

## The Busyman API — BusyBox's Own Translation Layer

> **"Busyman translates human-readable actions into CV-detected screen operations."**

BusyBox has its **own internal API** called **Busyman**. It is the bridge between
high-level intent ("scroll down", "click like", "check if blocked") and low-level
screen operations (CV detection + keyboard/mouse events).

### What Busyman Does

```
High-level action (intent)
        │
        ▼
  ┌─────────────────────────────────────────┐
  │              BUSYMAN API                │
  │                                         │
  │  1. Take screenshot of current screen   │
  │  2. Run CV detection (locate script)    │
  │  3. Identify UI elements on screen      │
  │  4. Map intent → detected element       │
  │  5. Execute: xdotool / pyautogui        │
  └─────────────────────────────────────────┘
        │
        ▼
Low-level execution (keyboard/mouse on DISPLAY :98)
```

### Busyman Action Examples

| Intent | CV Detection | Action Executed |
|--------|-------------|-----------------|
| `accept_cookies` | find `fb-button-allow-all-cookies.jpg` | mouse click on found coords |
| `scroll_feed` | window is active | `xdotool key Down` × N |
| `detect_blocked` | find `fb--message-you-are-temporarily-blocked.png` | pause + wait |
| `close_popup` | find `fb-cross-icon-black-cross-grey-circle.png` | click |
| `navigate_to` url | Chrome address bar | `Ctrl+L` → type url → `Return` |
| `detect_login_form` | find login input field | type credentials |
| `watch_video` | find play button or LIVE indicator | click + wait |
| `check_language` | clipboard analysis + CV | switch to English if needed |

### Busyman is Platform-Agnostic

The same Busyman interface works for any platform — Facebook, YouTube, Instagram, TikTok —
because it only reads pixels and sends keystrokes. The platform-specific knowledge
(what buttons look like, what text to search for) lives in **plugin image templates**.

---

## Complete Pairing Flow (6-digit code)

```
VM (BusyBox)                busybox.cc (relay)           User's Phone
     │                             │                           │
     │──── POST /device/register ──→                           │
     │     {vm_id, mesh_ip}        │                           │
     │←─── {code:"847 293",        │                           │
     │      expires:300s}          │                           │
     │                             │                           │
     │  [Welcome Screen on :98]    │                           │
     │  ┌──────────────────────┐   │   opens busybox.cc/pair ──│
     │  │ busybox.cc/pair      │   │←── POST {code:"847293"} ──│
     │  │ code: 847 293        │   │──→ {valid: true}          │
     │  │ [QR CODE]            │   │    show platform picker ──│→
     │  │ [████░░░] 4:32       │   │                           │
     │  └──────────────────────┘   │                           │
     │                             │                           │
     │                             │    [Phone shows:]         │
     │                             │    ┌───────────────┐      │
     │                             │    │ Start for:    │      │
     │                             │    │ [f] Facebook  │      │
     │                             │    │ [▶] YouTube   │      │
     │                             │    │ [📸] Instagram│      │
     │                             │    └───────────────┘      │
     │                             │                           │
     │                             │    [User selects FB]      │
     │                             │←── POST {platform:"fb"}───│
     │                             │──→ {status:"ok"}    ──────│→
     │                             │                           │  [Phone shows:]
     │                             │                           │  "✅ BusyBox starting
     │                             │                           │   for Facebook.
     │                             │                           │   You can close this."
     │                             │                           │
     │──── GET /device/status ─────→                           │
     │←─── {paired:true,           │                           │
     │      platform:"facebook",   │  [relay forgets           │
     │      start:true}            │   everything]             │
     │                             │                           │
     │  [Chrome opens              │                           │
     │   facebook.com]             │                           │
     │  [CV detects login form]    │                           │
     │  [Busyman fills login]      │                           │
     │  [Logged in visually]       │                           │
     │  [Session saved to disk]    │                           │
     │  [Plugins start]            │                           │
     │                             │                           │
     │  [saves pairing.done]       │                           │
     │  [next boot: auto]          │                           │
```

### What the relay passes to VM

```json
{
  "paired": true,
  "platform": "facebook",
  "start": true
}
```

**That's all.** No credentials. No tokens. No cookies.
The relay only tells the VM **which platform to open**. The VM does the rest visually.

---

## Credential Flow — Visual Only

After VM receives `{platform: "facebook"}`:

```
Step 1: Chrome opens https://www.facebook.com
Step 2: locate -i fb-login-form-email-field.png → found
Step 3: xdotool click <coords> && xdotool type <email>
Step 4: locate -i fb-login-form-password-field.png → found
Step 5: xdotool click <coords> && xdotool type <password>
Step 6: locate -i fb-login-button.png → found
Step 7: xdotool click <coords>
Step 8: wait for page load (CV detects home feed elements)
Step 9: Chrome profile saved to disk with active session
Step 10: On next boot → Chrome loads profile → already logged in
```

### Where are credentials stored?

Credentials are stored **locally on the VM only**, in encrypted files:

```
/opt/busy/<platform>/fb-login        ← email (read by busybox.cfg)
/opt/busy/<platform>/fb-password     ← password (file permission 600)
```

These files are:
- **Never sent to busybox.cc** (relay has zero knowledge of credentials)
- **Never committed to git** (in .gitignore)
- **Readable only by busybox user** (chmod 600)
- **Set once** during first-run setup

### First-Run Credential Entry

On first run, after pairing, the VM shows a simple credential entry form:

```
[Welcome Screen — Step 2 of 2]

Enter your Facebook credentials:
(stored locally on this VM only, never sent anywhere)

Email:    [________________________]
Password: [________________________]

              [Start BusyBox →]
```

This form is displayed on DISPLAY :98 (visible via VNC/NoVNC).
After submission, credentials are saved locally and Chrome performs visual login.

---

## State Machine

```
VM Boot
  │
  ├─ [pairing.done exists?] ──YES──→ [credentials exist?] ──YES──→ Start Plugins
  │                                          │
  │                                          NO
  │                                          │
  │                                   Show credential form
  │                                   → save → Start Plugins
  NO
  │
  ├─→ Register with relay → Get code
  ├─→ Show welcome screen (code + QR + countdown)
  ├─→ Poll relay (every 3s, timeout 300s)
  │        │
  │    [paired?] ──NO──→ sleep 3s → poll
  │        │
  │       YES → receive: {platform: "facebook"}
  │        │
  ├─→ Show credential entry form
  ├─→ Save credentials locally (chmod 600)
  ├─→ Chrome opens platform URL
  ├─→ Busyman: CV login flow
  ├─→ Session saved to Chrome profile
  ├─→ Write pairing.done
  └─→ Start Plugins
```

---

## Security Model

| Item | Approach |
|------|---------|
| Credentials | Stored locally on VM only, chmod 600, never transmitted |
| Relay knowledge | Only knows: vm_id, platform choice — zero credentials |
| Platform access | Via real browser session, same as human user |
| Session persistence | Chrome profile on disk, standard browser session |
| Session expiry | If platform logs out: Busyman detects login form → re-login automatically |
| VM compromise | Only local credentials at risk — revoke platform session from phone |
| Code brute-force | Rate limiting (10/h/IP) + 5min expiry + single-use |

---

## What Needs to be Built

### busybox.cc relay (minimal)

```
POST /api/device/register  → returns {code, expires}
GET  /api/pair?code=NNN    → returns HTML (platform picker)
POST /api/pair/confirm     → receives {code, platform} → stores in Redis TTL 60s
GET  /api/device/status    → returns {paired, platform} — deletes from Redis after read
```

No OAuth integration. No platform credentials. Pure pairing relay.

### VM components

| Component | Description | Language |
|-----------|-------------|---------|
| `welcome-screen` | Shows code + QR + countdown on DISPLAY :98 | Bash + Python tkinter |
| `credential-form` | Simple form to enter login/password locally | Python tkinter |
| `busyman` | CV → action translation API (core engine) | Python |
| `login-flow/<platform>` | Platform-specific CV login sequence | Bash + Python |

### Busyman — CV Action API

```python
# busyman: translate intent → CV detection → keyboard/mouse
# Usage: /opt/venv/bin/python /opt/busybox/busyman <action> [args]

busyman detect fb-login-form        # returns: found|not_found + coords
busyman click  fb-login-button      # CV detect + mouse click
busyman type   "email@example.com"  # keyboard input at cursor
busyman scroll down 20              # xdotool key Down × 20
busyman wait   fb-home-feed         # wait until element appears (timeout)
busyman read   clipboard            # return current clipboard content
```

---

**Author**: Dariusz Porczyński
**Last Updated**: 2026-02-18
**Status**: Design Proposal — awaiting implementation
**Version**: 1.1.23-beta
