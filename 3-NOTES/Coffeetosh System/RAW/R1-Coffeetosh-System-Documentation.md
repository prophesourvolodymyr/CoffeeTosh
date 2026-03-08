# 🧪 R1 - Coffeetosh System (LidCaf Core Engine)
**Date:** 2026-03-02
**Status:** 🟢 Approved Research (Precursor to F1)
**Classification:** Logic Feature
**Source:** N1 + Audit-R1 Feedback

---

## 1. 👁️ The Vision

LidCaf is a macOS utility that prevents a MacBook from sleeping when the lid is closed, enabling persistent SSH access for headless operation. Apple provides no first-party solution for this on battery — the standard `IOPMAssertion` API is bypassed on lid-close. LidCaf solves this with `pmset -a disablesleep 1` combined with `caffeinate`, wrapped in a clean dual-mode architecture. Mode A (Keep Awake) handles everyday idle-sleep prevention with zero privileges required. Mode B (LidCaf/Headless SSH) handles full lid-closed operation for developers and sysadmins.

The app ships as both a Menu Bar GUI (`LidCaf.app`) and a CLI tool (`lidcaf`), sharing state via a local JSON file so both stay perfectly in sync — whether the user starts from the menu bar or over SSH from their phone.

---

## 2. 🧠 Locked Decisions

| Decision | Value | Source |
|---|---|---|
| State sync mechanism | Local status file: `~/.lidcaf/status.json` | Q1 |
| Privilege model | Per-toggle (admin prompt on Start; auto-restore uses same process privileges — ~1 prompt/day) | Q2 |
| CLI architecture | Background daemon — detached process, survives SSH disconnect, owns countdown + caffeinate + pmset restore | Q3 |
| Crash recovery | Both: signal traps (`SIGINT`, `SIGTERM`, `SIGHUP`) + launchd plist boot-time cleanup | Q4 |
| macOS minimum | macOS 13 (Ventura) | Q5 |
| Code signing | Ad-hoc signing. README instructs `xattr -cr LidCaf.app`. Build script has Developer ID placeholders for future upgrade. | Q6 |
| App naming | `LidCaf.app` (bundle), `lidcaf` (CLI binary), `~/.lidcaf/` (state dir), `Coffeetosh/` (GitHub repo/brand) | Other Notes |
| Mode A | Keep Awake — `IOPMAssertion` only, no admin required, idle-sleep prevention | Other Notes |
| Mode B | LidCaf/Headless — `pmset disablesleep 1` + `caffeinate`, admin required, lid-close override | Other Notes |
| Timer expiry behavior | Auto-restore pmset silently, then open menu bar popover: "Session ended — Restart?" with Restart button | Idea #3 |
| SSH Session Monitor | Toggleable in Settings. Poll `netstat` port 22 every 30s. Restore sleep after 2 consecutive zero-connection checks. | Idea #2 |
| AC Power detection | Toggleable in Settings. Auto-activate on AC connect, deactivate on battery. | Idea #1 |
| CLI self-installer | `lidcaf install-cli` symlinks binary to `/usr/local/bin/lidcaf` | Idea #4 |

---

## 3. 🏗️ Sub-System Breakdown

### Sub-System 1: Dual-Mode Engine (`SleepManager.swift`)

**What it does:** The core logic that activates/deactivates sleep prevention in two modes.

**Mode A — Keep Awake:**
- Creates a `kIOPMAssertionTypePreventUserIdleSystemSleep` assertion via `IOPMAssertionCreateWithName`
- No `pmset` changes, no admin required
- Stores assertion ID in memory; releasing it restores sleep
- CLI: `lidcaf start [hours] --mode keep-awake`

**Mode B — LidCaf / Headless SSH:**
- Runs `sudo pmset -a disablesleep 1` via `NSAppleScript` with `"administrator privileges"`
- Spawns `caffeinate -dis` as a subprocess (display + idle + system sleep assertions)
- Writes `caffeinate` PID to state file for guaranteed cleanup
- CLI: `lidcaf start [hours]` (default mode)

**Activation flow (both modes):**
1. Write `status.json` with `{ mode, startTime, duration, pid, caffeinatePid }`
2. Start background daemon (detached from parent process)
3. Daemon sets up signal traps
4. Daemon enters countdown loop
5. On expiry → restore → update status file → trigger popover (GUI) or print message (CLI)

**Deactivation flow:**
1. Kill `caffeinate` subprocess using stored PID
2. Mode B: run `sudo pmset -a disablesleep 0`
3. Remove/update `status.json` to `{ active: false }`
4. Daemon exits cleanly

**Data Schema (`~/.lidcaf/status.json`):**
```json
{
  "active": true,
  "mode": "lidcaf",
  "startTime": "2026-03-02T08:00:00Z",
  "durationSeconds": 28800,
  "daemonPid": 12345,
  "caffeinatePid": 12346,
  "originalPmset": "Sleep On Power Button Enabled: 1\ndisablesleep 0"
}
```

**Original pmset capture:** Before activating Mode B, run `pmset -g` and store the relevant values so restore is exact, not assumed.

---

### Sub-System 2: Background Daemon

**What it does:** A detached process (spawned by both GUI and CLI) that outlives its parent and manages the session lifecycle.

**Implementation:** Swift executable compiled separately as `lidcaf-daemon`. Parent spawns it with `Process()`, then detaches (`process.launch()` without waiting).

**Daemon responsibilities:**
1. Register signal handlers: `SIGINT`, `SIGTERM`, `SIGHUP` → all trigger clean restore
2. Watch `status.json` for external stop signals (if file is removed or `active` set to false by another process)
3. Count down the timer using a `sleep()` loop or `DispatchQueue.asyncAfter`
4. On expiry: restore pmset, kill caffeinate, update status file, send popover trigger (write `expiredAt` field to status file — GUI polls this)
5. Exit

**Daemon PID tracking:** Daemon writes its own PID to `status.json` on start. On stop (any path), PID is cleared. Cleanup scripts use this PID to verify the daemon is dead.

---

### Sub-System 3: CLI Tool (`lidcaf`)

**What it does:** A Swift command-line executable exposing the full feature set for SSH use.

**Commands:**
```
lidcaf start [hours]             # Start Mode B (LidCaf), default 8h
lidcaf start [hours] --mode keep-awake   # Start Mode A
lidcaf stop                      # Stop active session, restore settings
lidcaf status                    # Print current state from status.json
lidcaf install-cli               # Symlink /usr/local/bin/lidcaf → app bundle binary
```

**`lidcaf status` output format:**
```
LidCaf: ACTIVE (Mode: LidCaf/Headless)
Started: 2026-03-02 08:00:00
Duration: 8h | Remaining: 5h 42m
Daemon PID: 12345
```
or:
```
LidCaf: INACTIVE
```

**`lidcaf install-cli` flow:**
1. Determine own path via `CommandLine.arguments[0]` or bundle lookup
2. Check if `/usr/local/bin/` exists (create if not)
3. Create symlink: `ln -sf /Applications/LidCaf.app/Contents/MacOS/lidcaf /usr/local/bin/lidcaf`
4. Print: "✅ lidcaf installed. Run: lidcaf status"

**SSH usage:**
```bash
ssh user@macbook.local
lidcaf start 8          # Start 8h LidCaf session
lidcaf status           # Check
lidcaf stop             # Stop when done
exit
```

---

### Sub-System 4: State File Watcher (GUI ↔ Daemon Sync)

**What it does:** Keeps the Menu Bar GUI in sync with the daemon state even when the daemon was started by the CLI.

**Implementation:** `FileSystemWatcher` using `DispatchSource.makeFileSystemObjectSource` on `~/.lidcaf/status.json`. On any file change → re-read JSON → update `@Published` state in `SleepManager` → SwiftUI menu bar icon and status text auto-update.

**Polling fallback:** If FSEvents misses a change (e.g., file written over SSH), a 10s `Timer` poll reads the file as a safety net.

**GUI-triggered changes:** When user clicks Start/Stop from the menu bar, the GUI writes to `status.json` first (optimistic update), then spawns/kills the daemon. The daemon's own write confirms the action.

---

### Sub-System 5: SSH Session Monitor

**What it does:** Replaces the timer with active SSH session detection. Keeps Mac awake while any SSH session is live; restores sleep after sessions end.

**Toggle location:** Settings panel → "SSH Session Monitor" toggle (Mode B only).

**When enabled:** Timer picker is hidden/disabled. Duration becomes "Until last SSH session ends."

**Detection mechanism:**
```swift
// Every 30 seconds:
let output = shell("netstat -an | grep '\\.22 ' | grep -c ESTABLISHED")
let count = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
```

**Grace period:** Counter tracks consecutive zero-hits. After 2 consecutive checks (60s) with 0 ESTABLISHED connections → trigger deactivation flow.

**State file entry when monitoring:**
```json
{
  "mode": "lidcaf",
  "sshMonitorEnabled": true,
  "consecutiveZeroCount": 0,
  "lastCheckTime": "2026-03-02T10:30:00Z"
}
```

---

### Sub-System 6: AC Power / Battery Monitor

**What it does:** Optionally auto-activates sleep prevention when AC power is connected, and deactivates when switching to battery.

**Toggle location:** Settings panel → "Auto-activate on AC power" (both modes).

**Implementation:** Register for `NSWorkspace.didWakeNotification` and use `IOPSGetPowerSourceDescription` to query power source. Or use `NSPowerStateDidChangeNotification` from `IOKit`.

**Behavior:**
- AC connected + toggle ON + LidCaf not active → auto-start with last-used duration/mode
- Battery only + toggle ON + LidCaf active → auto-stop (restore pmset)
- Never auto-starts if the toggle is OFF (default)

---

### Sub-System 7: Crash Recovery (Signal Traps + Launchd)

**What it does:** Guarantees `pmset disablesleep` is never left stuck on after app death.

**Layer 1 — Signal Traps (daemon):**
```swift
signal(SIGINT)  { _ in SleepManager.shared.restore(); exit(0) }
signal(SIGTERM) { _ in SleepManager.shared.restore(); exit(0) }
signal(SIGHUP)  { _ in SleepManager.shared.restore(); exit(0) }
```

**Layer 2 — GUI `applicationWillTerminate`:**
```swift
func applicationWillTerminate(_ notification: Notification) {
    SleepManager.shared.restore()
}
```

**Layer 3 — Launchd Boot-Time Cleanup:**
- Plist installed at: `~/Library/LaunchAgents/com.coffeetosh.lidcaf.cleanup.plist`
- Runs `lidcaf-cleanup` script at login
- Script checks `~/.lidcaf/status.json` — if `active: true` but `daemonPid` is dead (checked via `kill -0 PID`) → run `pmset -a disablesleep 0`, kill caffeinate PID if alive, write `active: false` to status file
- Installed by `lidcaf install-cli` (or first app launch)

**Cleanup script implementation:** Shell script (or compiled Swift) at `LidCaf.app/Contents/Resources/lidcaf-cleanup`.

---

### Sub-System 8: Build System (`build.sh`)

**What it does:** Compiles all Swift sources, assembles the `.app` bundle, and packages a distributable DMG.

**Steps:**
1. **Compile GUI app:** `swiftc` sources → binary at `build/LidCaf.app/Contents/MacOS/LidCaf`
2. **Compile CLI binary:** `swiftc Sources/CLI/*.swift` → binary at `build/LidCaf.app/Contents/MacOS/lidcaf`
3. **Compile daemon:** `swiftc Sources/Daemon/*.swift` → `build/LidCaf.app/Contents/MacOS/lidcaf-daemon`
4. **Compile cleanup script:** `build/LidCaf.app/Contents/Resources/lidcaf-cleanup`
5. **Assemble bundle:** Copy `Info.plist`, `Assets.xcassets` (app icon), `LidCaf.entitlements`
6. **Ad-hoc sign:** `codesign --force --deep --sign - build/LidCaf.app`
   - *[FUTURE: Replace `-` with `"Developer ID Application: Your Name (TEAMID)"` for distribution]*
7. **Create DMG:** `hdiutil create -volname LidCaf -srcfolder build/LidCaf.app -ov -format UDZO LidCaf.dmg`

**Info.plist keys:**
```xml
<key>LSUIElement</key><true/>          <!-- No Dock icon -->
<key>NSPrincipalClass</key><string>NSApplication</string>
<key>CFBundleIdentifier</key><string>com.coffeetosh.lidcaf</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
```

---

## 4. 🤖 AI Behavior Master Table

| Action | Trigger | Ask First? | What happens |
|---|---|---|---|
| Start Mode B | User clicks Start in GUI (Mode B) | No — runs pmset via AppleScript which triggers system auth dialog | Admin dialog appears, pmset set, daemon spawned |
| Start Mode A | User clicks Start (Mode A) | No | IOPMAssertion created, daemon spawned, no auth |
| Stop (any) | User clicks Stop, or timer expires | No | Restore pmset/assertion, kill caffeinate, update state file |
| SSH Monitor fires | 2 consecutive 0-connection checks | No | Triggers same stop flow |
| AC power connected | Power source change detected | No (if toggle enabled) | Auto-starts with last duration/mode |
| Crash detected at boot | Launchd cleanup script on login | No | Silently restores pmset if stale state found |
| Timer expiry popover | Timer hits zero | No | Popover from menu bar: "Session ended — Restart?" |

---

## 5. 📐 State File Schema (Complete)

| Field | Type | Meaning |
|---|---|---|
| `active` | Boolean | Is a session currently running? |
| `mode` | String | `"lidcaf"` or `"keep-awake"` |
| `startTime` | ISO8601 String | When the session started |
| `durationSeconds` | Int | Total session duration (0 = indefinite) |
| `daemonPid` | Int | PID of the background daemon |
| `caffeinatePid` | Int | PID of caffeinate subprocess (Mode B only) |
| `originalPmset` | String | Raw `pmset -g` output captured before activation |
| `sshMonitorEnabled` | Boolean | Is SSH monitor mode active? |
| `consecutiveZeroCount` | Int | SSH monitor: consecutive zero-connection polls |
| `expiredAt` | ISO8601 String | Written when timer expires; GUI reads to trigger popover |

---

## 6. 🔗 Cross-Feature Dependencies

| Dependency | Feature | Why |
|---|---|---|
| Menu bar popover UI | Coffeetosh UI | SleepManager writes `expiredAt` to status.json; GUI reads it to open the restart popover |
| Settings toggles UI | Coffeetosh UI | SSH Monitor, AC Power, battery threshold, display sleep toggles all map to SleepManager settings |
| Icon state (active/inactive) | Coffeetosh UI | GUI reads `active` field from status.json via FileSystemWatcher to toggle icon |

---

## 7. ⚠️ Risks & Open Questions

- [ ] **pmset API stability:** `pmset -a disablesleep 1` is undocumented behavior on battery without display. Apple may change this in future macOS versions. Mitigate with a macOS version check and a warning in the UI if `pmset` output doesn't reflect the expected state.
- [ ] **caffeinate orphan:** If daemon dies without cleanup, caffeinate process continues. Mitigated by writing PID to status.json and checking it in launchd cleanup script.
- [ ] **AppleScript auth in sandboxed environments:** If Apple ever sandboxes this app (App Store), AppleScript admin escalation will fail. Current approach (ad-hoc, no sandbox) avoids this. Do not submit to App Store without rearchitecting the privilege model.
- [ ] **SSH monitor false positives:** TCP keepalive can make a dropped SSH connection appear ESTABLISHED for up to ~2 minutes. 2-miss grace period (60s) may not be enough — consider making the grace period configurable (1–5 minutes).
- [ ] **`netstat` deprecation:** `netstat` is technically soft-deprecated on macOS in favor of `ss` or `lsof`. `lsof -i :22` is a more reliable alternative. Either works now; document the choice.
