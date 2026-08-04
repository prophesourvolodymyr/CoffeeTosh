# ⚙️ G2 - Coffeetosh System Architecture (Technical Law)
**Date:** 2026-04-21
**Status:** 🟢 Active Source of Truth
**Classification:** Technical Architecture

---

## 1. 🏗️ Package Structure

```
Coffeetosh (Swift Package)
├── CoffeetoshCore          — Shared Swift library (Models, Engine, State, Monitors)
├── coffeetosh-daemon       — Detached background process (countdown + lid monitor)
├── coffeetosh              — CLI tool (start, stop, status, add, preset...)
└── coffeetosh-cleanup      — Boot-time recovery (LaunchDaemon)

CoffeeTosh.app (Xcode)
├── CoffeeTosh (Mac App)   — Menu bar app (SwiftUI)
├── CoffeetoshTests
└── CoffeetoshUITests
```

**Minimum Requirements:** macOS 13 Ventura, Swift 5.9, Xcode 15+

---

## 2. 🔄 Execution Flow

### CLI Start Sequence
```
coffeetosh start
├── Capture original pmset state (sudo, once)
├── Spawn coffeetosh-daemon (fully detached, no wait)
│   ├── Start caffeinate -is (Mode B)
│   └── Begin lid polling (every 5s via IOKit)
├── Write ~/.coffeetosh/status.json
└── Exit immediately
```

### Timer Expiry / Stop Sequence
```
coffeetosh stop  OR  timer expires
├── Daemon receives signal / timer fires
├── Restore pmset to original snapshot (sudo, once)
├── Kill caffeinate subprocess
├── Restore display brightness
└── Write status.json (active: false)
```

### Lid Open Event
```
IOKit detects lid open
├── Save current brightness to status.json
├── Call CGSession -suspend (locks screen)
├── Restore saved brightness
└── Continue countdown (session still active)
```

---

## 3. 🔌 Core Components

### CoffeetoshCore Library

| Module | File | Responsibility |
|--------|------|-----------------|
| **Engine** | `SleepManager.swift` | Dual-mode engine: IOPMAssertion (A) vs pmset+caffeinate (B) |
| **Engine** | `CaffeinateProcess.swift` | Subprocess wrapper for `caffeinate -is` |
| **Engine** | `DaemonLauncher.swift` | Spawns detached daemon process |
| **Engine** | `SudoersInstaller.swift` | Installs `/etc/sudoers.d/coffeetosh` for password-free sudo |
| **Engine** | `CleanupInstaller.swift` | Registers lidcaf-cleanup as LaunchDaemon |
| **State** | `StatusFileManager.swift` | Reads/writes `~/.coffeetosh/status.json` |
| **State** | `PrefsFileManager.swift` | User preferences (Quick Preset, SSH monitor flag) |
| **State** | `FileSystemWatcher.swift` | KQueue/FSEvents watcher for status.json changes |
| **Monitors** | `LidStateMonitor.swift` | IOKit polling for AppleClamshellState (5s tick) |
| **Monitors** | `ACPowerMonitor.swift` | Charger connect/disconnect events |
| **Monitors** | `SSHMonitor.swift` | syslog polling for SSH connections |
| **Models** | `CoffeetoshStatus.swift` | Atomic status struct (active, mode, startTime, daemonPid, etc.) |
| **Models** | `HistoryManager.swift` | Session history storage |
| **Utilities** | `BrightnessHelper.swift` | Display brightness save/restore |
| **Utilities** | `PowerSavingHelper.swift` | Low Power Mode toggle |
| **Utilities** | `ShellHelper.swift` | sudo, pmset, system() wrappers |

---

## 4. 📁 File System Layout

```
~/.coffeetosh/
├── status.json          # Atomic state (CLI ↔ Daemon ↔ GUI)
└── prefs.json           # User preferences

/etc/sudoers.d/
└── coffeetosh          # Password-free sudo for pmset commands

/Library/LaunchDaemons/
└── com.coffeetosh.cleanup.plist  # Boot-time recovery
```

### status.json Schema
```json
{
  "active": true,
  "mode": "headless",
  "startTime": "2026-04-21T10:00:00Z",
  "durationSeconds": 28800,
  "daemonPid": 12345,
  "caffeinatePid": 12346,
  "originalPmset": "...",
  "sshMonitorEnabled": true,
  "expiredAt": null
}
```

---

## 5. 🔐 Security Architecture

### Password Handling
- Admin password requested **exactly twice** per session: start + stop
- Piped to `sudo -S` via stdin with echo disabled
- Sudo token caching means prompts may not appear if recently authenticated
- **Alternative:** Pre-installed sudoers file allows password-free `pmset` for authorized users

### Lid Open Protection
- `CGSession -suspend` = identical to Ctrl+Cmd+Q (enforced by `securityd`)
- **Not bypassable** by killing Coffeetosh — OS-level lock screen

### Crash Recovery
- Daemon traps `SIGTERM/SIGINT/SIGHUP`
- GUI `willTerminate` handler cleans up
- `lidcaf-cleanup` LaunchDaemon runs at boot to revert any stuck `pmset disablesleep 1`

---

## 6. 🌐 V2 Improvement: Auto-Expiring Lid-Closed Mode

### Current Problem (V1)
When user selects 30 minutes in Lid Closed mode → goes unlimited because unlocking requires admin password.

### Proposed Solution (V2)
1. User enters admin password **once** to start timed session
2. Daemon counts down internally
3. On expiry, daemon **auto-reverts** `pmset` without requiring password again
4. Session ends cleanly, system returns to normal sleep behavior

### Technical Approach
- Store original `pmset` state at session start (already implemented)
- On timer expiry, daemon calls `restorePmset()` which runs `sudo pmset ...` — **but if sudo token is still valid, no password prompt appears**
- If sudo token expired, user is prompted once to re-authenticate (acceptable UX since session is ending)

### Implementation Notes
- `SleepManager.swift:activate(mode:durationSeconds:skipAdmin:)` already has `skipAdmin` parameter
- Timer logic lives in `coffeetosh-daemon/main.swift`
- V2 adds: when timer expires in headless mode, call `SleepManager.shared.deactivate()` with appropriate flags

---

## 7. 🧪 Testing Contract

**Definition of Done:**
1. `coffeetosh start 1 --mode coffeetosh` → lid closed Mac stays awake for 1 hour
2. `coffeetosh stop` → restores exact original pmset state
3. Session timer expires → auto-restore without manual `stop`
4. Lid opens mid-session → screen locks immediately
5. App killed / CLI closed → daemon survives and continues countdown
6. Mac reboots with orphaned pmset state → cleanup daemon reverts it

---

*End of G2 — Technical architecture and implementation contracts.*
