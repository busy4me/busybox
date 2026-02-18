# BusyBox Development Teams & Guidelines

> **Guide for AI Agents and Contributors.**
> This document defines the specialized teams, their responsibilities, and current task assignments.

---

## 🏗️ Team Structure

To manage the complexity of BusyBox, work is divided into 4 specialized teams. When starting a session, identify which team role you are fulfilling.

### 🟢 Team CORE OS (Linux & Bash)
**Focus**: The operating system, boot process, and resource management.
*   **Technologies**: Debian 12, Bash, systemd, X11, TigerVNC, `initiv`.
*   **Primary Goal**: A stable, lightweight VM that boots in <60s and uses <500MB RAM.
*   **Responsibilities**:
    *   Maintain the `initiv` installation script.
    *   Optimize OS packages (reduce size).
    *   Manage system services (`busybox.service`, `vncserver`).
    *   Ensure reboot reliability.

### 🔵 Team VISION & BRAIN (Python & CV)
**Focus**: The automation logic and "human" behavior.
*   **Technologies**: Python 3, OpenCV, PyAutoGUI, `locate` script.
*   **Primary Goal**: Reliable detection of UI elements across different platforms.
*   **Responsibilities**:
    *   Develop the **Busyman API** (core CV engine).
    *   Create and maintain `login-flow/*` scripts.
    *   Manage the ephemeral image template library.
    *   Implement "human-like" behavior algorithms (randomness, delays).

### 🟠 Team CLOUD & AUTH (Go & Web)
**Focus**: The pairing mechanism and external connectivity.
*   **Technologies**: Go (Golang), Redis, HTML/JS/CSS, Networking.
*   **Primary Goal**: Secure, password-less pairing between user's phone and VM.
*   **Responsibilities**:
    *   Build and maintain the `busybox.cc` relay API.
    *   Develop the mobile pairing page (`/pair`).
    *   Implement the 6-digit code generation and validation logic (RFC 8628).
    *   Ensure secure communication (ZeroTier/Headscale integration).

### 🟣 Team PRODUCT & DOCS (UX & Content)
**Focus**: The user experience and communication.
*   **Technologies**: Markdown, i18n tools, Python (tkinter for UI).
*   **Primary Goal**: Make the complex technology accessible to non-technical users ("Alice").
*   **Responsibilities**:
    *   Maintain documentation (White Paper, Architecture, Guides).
    *   Manage translations (i18n structure).
    *   Design the **First-Run Welcome Screen** (UI).
    *   Ensure the "Vision" is respected in technical implementations.

---

## 📋 Active Task Assignments (2026-02-18)

These tasks are currently "in progress" or planned. Agents should pick tasks based on their active team role.

| Task | Assigned Team | Priority | Context |
|------|---------------|----------|---------|
| **Implement Busyman API** | 🔵 VISION | 🔥 **Critical** | Define CLI and Python lib for CV operations. |
| **Build `login-flow/facebook`** | 🔵 VISION | 🔥 **Critical** | Create visual login sequence using Busyman. |
| **Merge `dev` → `main` (Deadlock fix)** | 🟢 CORE OS | 🔥 **Critical** | Fix `initiv` line 2524 bug blocking installs. |
| **Enable `busybox.service`** | 🟢 CORE OS | 🔥 **Critical** | Ensure plugins start automatically after boot. |
| **Build Relay API (Go)** | 🟠 CLOUD | High | Backend for 6-digit pairing. |
| **Build Welcome Screen UI** | 🟣 PRODUCT | High | Tkinter/HTML UI for VM display :98. |
| **Package Optimization (-350MB)** | 🟢 CORE OS | Medium | Remove unused Debian packages. |
| **Translate Docs to PL/ES** | 🟣 PRODUCT | Medium | Expand `docs/i18n/`. |

---

## 🧠 Guidelines for Agents

1.  **Respect the "No-API" Rule**: Never suggest or implement solution using Platform APIs. Use CV/Busyman.
2.  **Stay in Character**: If you are Team CORE OS, focus on bash and systemd. Don't touch the Python CV logic unless necessary.
3.  **Update Documentation**: If you change code, update the corresponding file in `docs/`.
4.  **Keep it Simple**: BusyBox runs on low-end hardware. Optimize for resources.

---

**Last Updated**: 2026-02-18
