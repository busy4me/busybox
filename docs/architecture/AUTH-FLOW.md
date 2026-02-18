# BusyBox — Authentication & Pairing Flow

> **6-digit code on phone → VM starts and logs into social media automatically.**
>
> Based on: **OAuth 2.0 Device Authorization Grant** (RFC 8628)  
> Used by: Google TV, Apple TV, GitHub CLI, Sony PlayStation — same proven pattern.

---

## Design Principles

1. **Zero password entry on VM** — passwords never touch the VM directly
2. **Zero password entry on keyboard** — user only taps on phone
3. **First run only** — pair once, run forever
4. **busybox.cc as stateless relay** — no persistent storage of credentials
5. **Social OAuth** — platform tokens (not passwords) flow to VM

---

## Complete Flow Diagram

```
VM (BusyBox)                busybox.cc (relay)           User's Phone
     │                             │                           │
     │──── POST /device/register ──→                           │
     │     {vm_id, mesh_ip, caps}  │                           │
     │←─── {code:"847 293",        │                           │
     │      expires:300s} ─────────│                           │
     │                             │                           │
     │  [Welcome Screen on :98]    │                           │
     │  ┌──────────────────────┐   │                           │
     │  │ busybox.cc/pair      │   │   opens busybox.cc/pair ──│
     │  │ code: 847 293        │   │←── POST {code:"847293"} ──│
     │  │ [QR CODE]            │   │                           │
     │  │ [████░░░] 4:32       │   │──→ {valid: true}          │
     │  └──────────────────────┘   │    show platform picker ──│→
     │                             │                           │  [Phone shows:]
     │                             │                           │  ┌───────────────┐
     │                             │                           │  │ Connect to:   │
     │                             │                           │  │ [f] Facebook  │
     │                             │                           │  │ [▶] YouTube   │
     │                             │                           │  │ [📸] Instagram│
     │                             │                           │  └───────────────┘
     │                             │                           │
     │                             │         [User taps FB]    │
     │                             │←── OAuth: open            │
     │                             │    facebook.com/oauth  ───│→
     │                             │                           │  [Facebook OAuth]
     │                             │                           │  "Allow BusyBox
     │                             │                           │   to access your
     │                             │                           │   account?"
     │                             │                           │  [Allow]
     │                             │←── FB returns token ──────│
     │                             │    {access_token,         │
     │                             │     cookies_b64,          │
     │                             │     profile_name}         │
     │                             │                           │
     │──── GET /device/status ─────→                           │
     │←─── {paired: true,          │                           │
     │      platform: "facebook",  │                           │
     │      cookies_b64: "...",    │                           │
     │      profile: "Jan K."} ────│                           │
     │                             │  [relay clears data]      │
     │                             │                           │
     │  [VM injects cookies        │                           │
     │   into Chrome profile]      │                           │
     │  [Chrome opens FB           │                           │
     │   → already logged in]      │                           │
     │  [busybox plugins start]    │                           │
     │                             │                           │
     │  [saves: ~/.busybox/        │                           │
     │   pairing.done]             │                           │
     │  [next boot: skips flow]    │                           │
```

---

## Component Specifications

### 1. VM — `welcome-screen` (first-run daemon)

**Trigger**: runs on first boot if `~/.busybox/pairing.done` does NOT exist.

**Script**: `/opt/busybox/welcome-screen` (Bash + Python)

```bash
#!/bin/bash
# Welcome screen — runs only on first boot
PROJECT="busybox"
PAIRING_DONE="/home/$PROJECT/.busybox/pairing.done"
RELAY="https://busybox.cc/api"
VM_ID=$(cat /etc/machine-id)
MESH_IP=$(zerotier-cli listnetworks 2>/dev/null | grep 932df01efb1ebd71 | awk '{print $NF}' | head -1)

[[ -f "$PAIRING_DONE" ]] && exit 0  # already paired, skip

# Step 1: Register VM with relay
response=$(curl -sf -X POST "$RELAY/device/register" \
  -H "Content-Type: application/json" \
  -d "{\"vm_id\":\"$VM_ID\",\"mesh_ip\":\"$MESH_IP\"}" )
CODE=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['code'])")
EXPIRES=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['expires'])")

# Step 2: Show welcome screen with code
/opt/busybox/welcome-screen-ui "$CODE" "$EXPIRES" &

# Step 3: Poll relay for pairing confirmation
while true; do
  status=$(curl -sf "$RELAY/device/status?vm_id=$VM_ID")
  paired=$(echo "$status" | python3 -c "import sys,json; print(json.load(sys.stdin).get('paired','false'))")
  [[ "$paired" == "true" ]] && break
  sleep 3
done

# Step 4: Extract received data
COOKIES=$(echo "$status" | python3 -c "import sys,json; print(json.load(sys.stdin)['cookies_b64'])")
PLATFORM=$(echo "$status" | python3 -c "import sys,json; print(json.load(sys.stdin)['platform'])")
PROFILE=$(echo "$status" | python3 -c "import sys,json; print(json.load(sys.stdin)['profile'])")

# Step 5: Inject cookies into Chrome profile
/opt/busybox/auth-inject-cookies "$PLATFORM" "$COOKIES"

# Step 6: Mark as paired and start busybox
mkdir -p /home/$PROJECT/.busybox
echo "{\"platform\":\"$PLATFORM\",\"profile\":\"$PROFILE\",\"paired_at\":\"$(date -Iseconds)\"}" \
  > "$PAIRING_DONE"
kill %1  # close welcome screen UI

# Step 7: Start plugins
screen -dmS fb:98 /opt/busybox/plugins/fb/fb
```

---

### 2. VM — `welcome-screen-ui` (visual display on :98)

Full-screen welcome window shown on DISPLAY :98 (visible via VNC on physical screen):

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│                🤖 BusyBox — First Run                 │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │                                                  │  │
│  │   Step 1: Open on your phone                    │  │
│  │                                                  │  │
│  │            busybox.cc/pair                       │  │
│  │                                                  │  │
│  │   Step 2: Enter this code                       │  │
│  │                                                  │  │
│  │         ┌───┬───┬───┐   ┌───┬───┬───┐          │  │
│  │         │ 8 │ 4 │ 7 │   │ 2 │ 9 │ 3 │          │  │
│  │         └───┴───┴───┘   └───┴───┴───┘          │  │
│  │                                                  │  │
│  │   [████████████░░░░░░░░░░░░░] expires in 4:32  │  │
│  │                                                  │  │
│  │              ┌─────────────┐                    │  │
│  │              │  [QR CODE]  │                    │  │
│  │              │             │                    │  │
│  │              └─────────────┘                    │  │
│  │         scan to open busybox.cc/pair            │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  Waiting for pairing... ⠋                             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Implementation options** (choose one):
- `zenity` — simplest, already installed, limited styling
- `python3 tkinter` — available in venv, full control
- `HTML + python3 http.server + xdg-open` — modern, mobile-friendly preview

---

### 3. busybox.cc — Relay API

**Stateless relay** — Redis with 5-minute TTL. No persistent storage.

#### Endpoints

```
POST /api/device/register
  Body:  { vm_id, mesh_ip }
  Returns: { code: "847 293", expires: 300, qr_url: "https://busybox.cc/pair?c=847293" }

GET  /api/pair?code=847293                          ← phone opens this
  Returns: HTML page (platform picker)

POST /api/pair/confirm
  Body:  { code, platform, cookies_b64, profile }  ← after OAuth on phone
  Returns: { status: "ok" }

GET  /api/device/status?vm_id=<id>                 ← VM polls this
  Returns: { paired: false }
        OR { paired: true, platform, cookies_b64, profile }
  Note: data is deleted from Redis immediately after first successful read
```

#### Code Generation

```
6-digit code = random, human-friendly
Format: "NNN NNN" (3+3 with space for readability)
Collision avoidance: check Redis before issuing
Expiry: 300 seconds (5 minutes)
No sequential codes (random only)
```

#### Security

```
- HTTPS only (TLS 1.3)
- Rate limiting: 10 register attempts per IP per hour
- Code is single-use (deleted after pairing)
- cookies_b64 deleted from Redis after VM reads them (one-time access)
- No logging of cookies or tokens
- busybox.cc never stores account credentials persistently
```

---

### 4. busybox.cc — Mobile Pair Page (`/pair`)

Progressive Web App (works in any mobile browser):

```
busybox.cc/pair

┌─────────────────────────┐
│  🤖 BusyBox Pair        │
│─────────────────────────│
│                         │
│  [8][4][7] - [2][9][3] │  ← 6 numeric inputs, auto-focus
│                         │
│       [Pair Device]     │
│                         │
└─────────────────────────┘

After code verified:

┌─────────────────────────┐
│  ✅ Code accepted!      │
│                         │
│  Connect your account:  │
│                         │
│  [f] Continue with      │
│      Facebook           │
│                         │
│  [▶] Continue with      │
│      YouTube            │
│                         │
│  [📸] Continue with     │
│       Instagram         │
└─────────────────────────┘

After platform OAuth:

┌─────────────────────────┐
│  ✅ Connected!           │
│                         │
│  Account: Jan Kowalski  │
│  Platform: Facebook     │
│                         │
│  Your BusyBox is now    │
│  starting...            │
│                         │
│  You can close this tab │
└─────────────────────────┘
```

---

### 5. VM — `auth-inject-cookies` (cookie injection)

After receiving `cookies_b64` from relay, inject into Chrome:

```python
#!/opt/venv/bin/python
# auth-inject-cookies: injects platform session cookies into Chrome profile
import sys, json, base64, sqlite3, os, time

platform = sys.argv[1]   # "facebook", "youtube", "instagram"
cookies_b64 = sys.argv[2]
cookies = json.loads(base64.b64decode(cookies_b64))

# Chrome cookies database location
chrome_profile = "/home/busybox/.config/google-chrome/Default"
cookies_db = f"{chrome_profile}/Cookies"

# Platform domain mapping
domains = {
    "facebook": [".facebook.com", ".meta.com"],
    "youtube":  [".youtube.com", ".google.com"],
    "instagram": [".instagram.com"],
}

conn = sqlite3.connect(cookies_db)
cursor = conn.cursor()

for cookie in cookies:
    cursor.execute("""
        INSERT OR REPLACE INTO cookies
        (creation_utc, host_key, top_frame_site_key, name, value,
         encrypted_value, path, expires_utc, is_secure, is_httponly,
         last_access_utc, has_expires, is_persistent, priority,
         samesite, source_scheme, source_port, is_same_party)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, (
        int(time.time() * 1000000),  # creation_utc (microseconds)
        cookie['domain'],
        "",
        cookie['name'],
        cookie['value'],
        b"",          # encrypted_value (Chrome will re-encrypt on next start)
        cookie['path'],
        int(cookie.get('expiry', 0) * 1000000),
        cookie.get('secure', True),
        cookie.get('httpOnly', False),
        int(time.time() * 1000000),
        1, 1, 1, 0, 1, 443, 0
    ))

conn.commit()
conn.close()
print(f"[AUTH] Injected {len(cookies)} cookies for {platform}")
```

---

## How Social OAuth Works on Phone

When user taps "Continue with Facebook" on busybox.cc/pair:

```
1. busybox.cc redirects → facebook.com/dialog/oauth
   params: client_id=BUSYBOX_APP_ID
           redirect_uri=https://busybox.cc/oauth/callback/facebook
           scope=public_profile,email
           response_type=code

2. User sees Facebook's own login/consent screen on phone
   (standard Facebook OAuth — user sees and trusts Facebook UI)

3. Facebook redirects → busybox.cc/oauth/callback/facebook?code=XYZ

4. busybox.cc exchanges code for access_token (server-side)

5. busybox.cc uses token to get session cookies via Graph API
   OR fetches cookies from Facebook's cookie endpoint

6. busybox.cc stores {cookies_b64, profile_name} in Redis (TTL 60s)
   linked to the pairing code

7. VM reads cookies via /api/device/status
```

**Important**: busybox.cc needs **Facebook App registration** (free, developer.facebook.com).  
Same for YouTube (Google OAuth) and Instagram (Meta for Developers).

---

## State Machine

```
VM Boot
  │
  ├─ [pairing.done exists?] ──YES──→ Skip to: Start Plugins
  │
  NO
  │
  ├─→ Register with relay → Get code
  │
  ├─→ Show welcome screen (code + QR)
  │
  ├─→ Poll relay (every 3s, timeout 300s)
  │        │
  │    [paired?] ──NO──→ sleep 3s → poll again
  │        │
  │       YES
  │        │
  ├─→ Inject cookies into Chrome
  │
  ├─→ Write pairing.done
  │
  └─→ Start Plugins (screen sessions)
          │
          └─→ fb:98 / fb-scroll:98 / fb-walking-around:98
```

---

## Security Summary

| Risk | Mitigation |
|------|------------|
| Code brute-force | Rate limiting (10/h/IP) + 5min expiry |
| Cookies in transit | HTTPS only, one-time read |
| Credentials on relay | Never stored — relay only brokers OAuth tokens |
| Credentials on VM | Not stored — only session cookies (expire naturally) |
| VM impersonation | vm_id = /etc/machine-id (unique per VM) |
| Replay attack | Code deleted after use |
| Long-term access | Chrome session expires naturally (platform-enforced) |
| VM stolen/lost | User revokes access on Facebook/Google directly |

---

## Implementation Roadmap

### Phase 1 — MVP (minimum viable pairing)

```
Week 1-2:
  ✅ busybox.cc relay API (Go/Node.js, Redis, basic endpoints)
  ✅ welcome-screen bash script (zenity dialog with code)
  ✅ Cookie injection script (Python + SQLite)

Week 3-4:
  ✅ Mobile pair page (HTML/JS, code input)
  ✅ Facebook OAuth integration
  ✅ End-to-end test: code → pair → cookies → Chrome logged in
```

### Phase 2 — Full Product

```
Week 5-6:
  ✅ YouTube OAuth
  ✅ Instagram OAuth
  ✅ QR code generation on welcome screen
  ✅ Progress bar + countdown on welcome screen
  ✅ "Already paired" detection + skip logic

Week 7-8:
  ✅ Session expiry detection (auto re-pair when FB logs out)
  ✅ Multiple accounts per VM (multiple platforms)
  ✅ NoVNC integration (phone sees VM screen after pairing)
```

### Phase 3 — Production

```
  ✅ busybox.cc production deployment (NETOL infrastructure)
  ✅ busybox.cc/pair PWA (installable on phone homescreen)
  ✅ Analytics: how many VMs paired, platforms, success rate
  ✅ Admin panel: monitor VM fleet
```

---

## Technology Stack Recommendation

| Component | Language | Why |
|-----------|----------|-----|
| Relay API | **Go** | Fast, low memory, single binary, easy deploy |
| Redis | Redis 7 | Ephemeral storage, TTL built-in, fast |
| Mobile page | **Vanilla JS + Alpine.js** | No build step, fast mobile load |
| Welcome screen UI | **Python tkinter** | Already in venv, full control, no extra deps |
| Cookie injector | **Python** | sqlite3 built-in, same venv |

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Status**: Design Proposal — awaiting implementation  
**Version**: 1.1.23-beta
