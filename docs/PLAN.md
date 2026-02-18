# BusyBox — Implementation Plan

> **Working document — updated per session. Next steps, priorities, open decisions.**

---

## Status: 2026-02-18 (current)

| Area | Status |
|------|--------|
| Core automation (fb plugin, VNC, screen) | ✅ Working in beta |
| Installation (initiv Stage 0/1/2) | ✅ Working (~85 min) |
| Documentation | ✅ Foundation created (EN) |
| Authentication / pairing | 🔲 Designed, not implemented |
| Welcome screen (first run) | 🔲 Not implemented |
| busybox.service (auto-start) | 🔲 Disabled — plugins start manually |
| NoVNC (web access) | 🔲 Planned |
| Multi-account per VM | 🔲 Not designed |
| Plugin marketplace | 🔲 Concept only |
| AI agent plugins | 🔲 Concept only |

---

## Priority 1 — Authentication (6-digit pairing)

**Design**: [docs/architecture/AUTH-FLOW.md](architecture/AUTH-FLOW.md)  
**Pattern**: OAuth 2.0 Device Authorization Grant (RFC 8628) — same as Google TV, GitHub CLI

> ⚠️ **No platform APIs used.** BusyBox does NOT use Facebook API, Google OAuth,
> Instagram API or any other platform API. Login is performed visually by Chrome +
> Computer Vision — the same way a human would log in.

### How it works (30 seconds)

```
VM boots → shows code "847 293" on screen
User opens busybox.cc/pair on phone → types code → selects platform
busybox.cc relay tells VM: "start for Facebook"
VM opens Chrome → CV detects login form → fills credentials locally → logged in
Next boot: Chrome session already active → automatic
```

### What needs to be built

| Component | Team | Language | Size | Priority |
|-----------|------|----------|------|---------|
| `busybox.cc` relay API | 🟠 CLOUD | Go + Redis | ~300 lines | 🔥 |
| `busybox.cc/pair` mobile page | 🟠 CLOUD | HTML/JS | ~200 lines | 🔥 |
| `welcome-screen` daemon (VM) | 🟣 PRODUCT | Bash + Python tkinter | ~150 lines | 🔥 |
| `credential-form` (VM) | 🟣 PRODUCT | Python tkinter | ~80 lines | 🔥 |
| `busyman` CV action API (VM) | 🔵 VISION | Python | ~300 lines | 🔥 |
| `login-flow/facebook` (VM) | 🔵 VISION | Bash + busyman | ~100 lines | 🔥 |
| `login-flow/youtube` (VM) | 🔵 VISION | Bash + busyman | ~100 lines | High |
| `login-flow/instagram` (VM) | 🔵 VISION | Bash + busyman | ~100 lines | High |
| Fix `initiv` deadlock | 🟢 CORE OS | Bash | ~10 lines | 🔥 |
| Enable `busybox.service` | 🟢 CORE OS | systemd | ~20 lines | 🔥 |

### Team Structure

See [TEAMS.md](TEAMS.md) for detailed responsibilities.

- 🟢 **CORE OS** (System, Install, Boot)
- 🔵 **VISION** (CV, Busyman, Logic)
- 🟠 **CLOUD** (Auth, Relay, Network)
- 🟣 **PRODUCT** (UX, Docs, i18n)

### Open decisions

- [ ] Where to host `busybox.cc` relay? (NETOL infra → Docker Swarm?)
- [ ] Redis or SQLite for relay state? (Redis preferred — TTL built-in)
- [ ] What happens when Chrome session expires? (Busyman auto-detects login form → re-login)
- [ ] Credential encryption at rest on VM? (currently chmod 600 plain text)

---

## Priority 2 — busybox.service (auto-start)

Currently plugins are started **manually**. After reboot nothing starts automatically (except VNC).

**Fix**: Enable `busybox.service` to auto-start plugins after VNC is ready.

```bash
# /etc/systemd/system/busybox.service
[Unit]
Description=BusyBox automation service
After=vncserver.service
Requires=vncserver.service

[Service]
Type=forking
User=busybox
ExecStart=/opt/busybox/busybox start
ExecStop=/opt/busybox/busybox stop
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

---

## Priority 3 — Merge dev → main (bug fix)

**Bug**: Deadlock in `initiv` at line 2524 — blocks Stage 1 in some cases.  
**Fix**: Already on `dev` branch.  
**Action**: Review diff, merge to main, tag v1.1.24.

---

## Priority 4 — Documentation (Phase 2)

| Document | Description | Status |
|----------|-------------|--------|
| `docs/CONTRIBUTING.md` | How to contribute code, open PRs | 🔲 |
| `docs/development/DEVELOPMENT.md` | Dev environment setup, testing | 🔲 |
| `docs/development/TESTING.md` | How CI/CD tests work | 🔲 |
| `docs/QUICK-START.md` | End-user: download VM → run in 5 min | 🔲 (after UX design) |
| `docs/TROUBLESHOOTING.md` | Common issues + fixes | 🔲 |

---

## Priority 5 — First-Run UX (Welcome Screen)

After pairing is implemented, design the welcome screen UI shown on VM:

- **Technology**: Python tkinter (already in venv) or HTML served locally
- **Elements**: Code display, QR code, countdown timer, status indicator
- **Transitions**: Waiting → Paired → Starting... → Running

---

## Priority 6 — NoVNC Web Access

Allow user to see and control the VM from any browser over HTTPS:

```
User browser (HTTPS) → busybox.cc/vnc/<vm_id> → NoVNC WebSocket → DISPLAY :98
```

- NoVNC is open-source, runs as a web server proxy
- Integrates with pairing flow (after 6-digit code → phone shows VM screen)
- Requires busybox.cc to act as WebSocket proxy

---

## Priority 7 — Multi-Account Per VM

One VM serving multiple accounts simultaneously on separate displays:

```
DISPLAY :98 → account A (Facebook)
DISPLAY :99 → account B (Instagram)
DISPLAY :100 → account C (YouTube)
```

Each display has its own:
- VNC server port (5998, 5999, 6000...)
- Screen sessions (`fb:98`, `ig:99`, `yo:100`)
- Chrome profile (`/home/busybox/.config/chrome-98/`, etc.)

---

## Future: Plugin Ecosystem

| Plugin | Platform | Status |
|--------|----------|--------|
| `fb` | Facebook / Meta | ✅ Active |
| `yo` | YouTube | 🔲 Skeleton |
| `ig` | Instagram | 🔲 Planned |
| `tt` | TikTok | 🔲 Planned |
| `tw` | Twitter/X | 🔲 Planned |
| `li` | LinkedIn | 🔲 Planned |

**Plugin language support roadmap**:
- ✅ Bash (current)
- ✅ Python (via /opt/venv)
- 🔲 Go (binary + manifest)
- 🔲 Ruby
- 🔲 AI Agent (LLM-driven, manifest-based)

---

## Session History — All BusyBox Sessions

Complete history of all AI-assisted work sessions on this project:

| Session | Date | Topic | Key Outcome |
|---------|------|-------|------------|
| [s001](https://github.com/busy4me/busybox) | 2025-11-12 | Initial setup | Project started |
| [s002](https://github.com/busy4me/busybox) | 2025-11-20 | Session notes | Planning |
| [s003](https://github.com/busy4me/busybox) | 2025-11-21 | Busybox installation | First install |
| [s004](https://github.com/busy4me/busybox) | 2025-11-21 | Final summary | Install documented |
| [s005](https://github.com/busy4me/busybox) | 2025-11-22 | Next session notes | Roadmap notes |
| [s006](https://github.com/busy4me/busybox) | 2025-11-23 | Multi-runner & devops | CI/CD setup |
| [s007](https://github.com/busy4me/busybox) | 2025-12-16 | deb12 optimization | Debian 12 base image |
| [s008](https://github.com/busy4me/busybox) | 2025-12-18 | initiv reboot test | Stage 1/2 reboot flow tested |
| [s106](https://github.com/busy4me/busybox) | 2026-02-07 | Project summary & status | Status review, v1.1.23-beta |
| [s119](https://github.com/busy4me/busybox) | 2026-02-10 | Project status & pipeline trigger | Pipeline trigger analysis |
| [s120](https://github.com/busy4me/busybox) | 2026-02-11 | Beta release & repo rename | v1.1.23-beta tagged |
| [s126](https://github.com/busy4me/busybox) | 2026-02-12 | GitHub runners restoration | All 3 runners online on lab1 |
| [s131](https://github.com/busy4me/busybox) | 2026-02-18 | Process analysis & documentation | Live VM analyzed, /docs created |
| **s132** | 2026-02-18 | Auth flow design | 6-digit pairing designed (RFC 8628) |

---

## Deferred / Under Consideration

- **Blockchain account sync** — considered for distributed identity (no decision)
- **Headless Chrome mode** — vs visible VNC session (current: visible, intentional)
- **ARM support** (Raspberry Pi) — listed in README but not tested on deb12
- **PostgreSQL / time-series DB** — for telemetry (replace SQLite)

---

**Author**: Dariusz Porczyński  
**Last Updated**: 2026-02-18  
**Version**: 1.1.23-beta
