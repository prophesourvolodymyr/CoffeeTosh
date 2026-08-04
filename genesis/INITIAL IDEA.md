# 🧭 G0 - Coffeetosh Vision (Project Soul)
**Date:** 2026-04-21
**Status:** 🟢 Active Source of Truth
**Classification:** Strategic / Brand Delta

---

## 1. 🔮 The One-Liner

**Coffeetosh** is a macOS menu bar app and CLI tool that keeps your MacBook alive with the lid closed — for SSH workflows, overnight tasks, and headless servers.

---

## 2. 🎯 The Mission

Empower developers, sysadmins, and power users to run their MacBooks as reliable headless servers without:
- Disabling sleep globally (battery destruction)
- Kernel extensions or SIP bypasses (security risks)
- Complex configuration or unsafe hacks

One command. Lid closes. Mac runs.

---

## 3. 🧩 The Two Modes

| Mode | Flag | Use Case | Admin |
|------|------|----------|-------|
| **Lid Closed (Headless)** | `--mode coffeetosh` / `--mode lid-closed` | SSH, overnight, server | Yes — `pmset` once at start, once at stop |
| **Keep Awake** | `--mode keep-awake` | Presentations, downloads | No |

---

## 4. 🛡️ Security Principles

- **Zero stored passwords** — Admin password piped via `sudo -S`, immediately discarded
- **No kernel extensions** — Uses only `pmset`, `caffeinate`, and IOKit APIs
- **Lid-open = instant lock** — `CGSession -suspend` enforced by `securityd`
- **Crash recovery** — Boot-time `lidcaf-cleanup` LaunchDaemon reverts any stuck `pmset` state

---

## 5. 👥 Target Audience

- **Primary:** Developers running local dev servers, SSH tunnels, or CI agents on MacBooks
- **Secondary:** Sysadmins, homelab enthusiasts, overnight task runners
- **Tertiary:** Anyone who needs a closed-lid Mac that "just keeps running"

---

## 6. 📦 Product Components

1. **Coffeetosh.app** — macOS menu bar app (popover UI, onboarding, settings)
2. **coffeetosh** CLI — Terminal tool (`start`, `stop`, `status`, `add`, `preset`, `battery`, `mac-temp`)
3. **coffeetosh-daemon** — Detached background process (countdown, lid monitoring)
4. **coffeetosh-cleanup** — Boot-time recovery daemon (LaunchDaemon)

---

## 7. 🚫 Out of Scope

- Windows/Linux support (macOS-only by design)
- Wake-on-LAN or remote wake features
- Battery health management beyond basic monitoring
- Scheduled start/stop (candidates for future)

---

## 8. 📈 Version History

- **V1:** Initial release — Dual-mode engine, menu bar app, CLI
- **V1.1:** DMG distribution, Homebrew tap
- **V2 (In Progress):** Timer-based lid-closed mode that auto-releases without password re-entry

---

*End of G0 — Core purpose and identity. G1 (Styles) defines the visual language. G2 (System) defines the architecture.*
