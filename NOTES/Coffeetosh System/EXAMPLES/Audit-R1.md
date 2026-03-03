# 🔍 Audit for R1 - Coffeetosh System (LidCaf Core Engine)
**Date:** 2026-03-02
**Source:** N1 - Coffeetosh System
**Classification:** Logic Feature
**Status:** ✅ Approved → R1 Generated

---

## ❓ Questions
*Please answer the following to clarify your requirements:*

### Q1: State Sync Mechanism — UserDefaults vs Status File?
The CLI and GUI need a shared state. **UserDefaults** requires both to share an App Group (more Apple-native but requires provisioning). A **local status file** (e.g., `~/.lidcaf/status.json`) is simpler and works universally, including over SSH without signing.
**Your Response:**
- Yes tahts will be good. We will be using the status file

### Q2: Privilege Persistence — Per-Session or Re-prompt Each Toggle?
`pmset` needs root. Should the app request admin privileges **once per app launch** and cache the authorization, or **every time** the user toggles Start/Stop? Once-per-launch is smoother but requires keeping an auth reference. Per-toggle is more secure but adds friction.
**Your Response:**
- ✅ **Per-toggle.** One admin prompt on Start. Auto-restore on timer expiry uses the already-running process's privileges (no second prompt). Manual Stop may re-prompt. Effectively 1 password per day for normal use.

### Q3: CLI Daemon vs One-Shot?
Should `lidcaf start 4` spawn a **background daemon process** that counts down, or should it simply write to the state file and rely on the GUI app (or a launchd agent) to manage the timer? If the GUI isn't running when someone uses the CLI over SSH, who manages the countdown?
**Your Response:**
- ✅ **Background daemon.** Both CLI and GUI spawn the same detached background daemon process that owns the countdown, caffeinate process, and pmset restore. Survives SSH disconnect. Writes PID + state to `~/.lidcaf/status.json`. GUI reads state file to reflect status.

### Q4: Crash Recovery — Launchd Watcher or Boot-Time Cleanup?
If the app crashes and `pmset disablesleep 1` is stuck, should we: (a) install a **launchd plist** that runs a cleanup script on boot/login, (b) rely on signal traps only, or (c) both? Option (c) is safest.
**Your Response:**
- Both because its safest.

### Q5: macOS Minimum Target?
`MenuBarExtra` requires macOS 13 (Ventura). Should we target **macOS 13+** as the minimum, or do you need support for older versions (which would require a different menu bar approach like `NSStatusItem`)?
**Your Response:**
- Okay MAc OS 13 will be the minimum.

### Q6: Code Signing & Notarization?
The DMG will need to be distributed. Should the build script include steps for **ad-hoc code signing** (for personal use), or should it include placeholders for a proper **Developer ID** signing + notarization flow?
**Your Response:**
- ✅ **Ad-hoc signing** for now. README will instruct users to run `xattr -cr LidCaf.app` after download. Build script will include **placeholder comments** for Developer ID signing + notarization so it's easy to upgrade later without restructuring.

---

## 💡 Ideas & Suggestions
*Optional enhancements not in your original request:*

1. **Auto-Detect AC Power:** Automatically activate sleep prevention when plugging into AC power, and deactivate when switching to battery (optional toggle in settings).
   - **Complexity:** Medium
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - Its already like that I beleive, but yes make taht toggble in settings

2. **SSH Session Monitor:** Instead of a timer, detect active SSH sessions and keep the Mac awake only while an SSH connection is live. Auto-sleep when the last session disconnects.
   - **Complexity:** Medium (simple polling via `netstat` on port 22, 30s interval, 2-miss grace period before restore)
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - ✅ Approved. Toggleable in Settings. Scoped to standard SSH (port 22). Poll every 30s, restore sleep after 2 consecutive zero-connection checks.

3. **Popover on Timer Expiry (Restart Prompt):** When the timer expires, auto-restore pmset settings AND show a menu bar popover: "Session ended. Restart for another X hours?" with a Restart button. Popover instead of notification — harder to miss.
   - **Complexity:** Low
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - ✅ Approved. Use popover from menu bar, not macOS notification (easy to miss). Popover shows restart option with same duration.

4. **`lidcaf install-cli`:** A self-installer command that symlinks the CLI binary to `/usr/local/bin/lidcaf` so users don't have to do it manually.
   - **Complexity:** Low
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - ✅ Approved. Required — CLI lives inside the .app bundle and won't be in PATH otherwise. `lidcaf install-cli` symlinks it to `/usr/local/bin/lidcaf`.

---

## ⚠️ Problems

- **Problem:** `pmset -a disablesleep 1` on battery without an external display is technically an unsupported Apple configuration. Apple can change the behavior of `pmset` in future macOS updates, which could break this approach silently.
  - **Suggested Solution:** Include a version check and test the `pmset` behavior on launch. If the expected behavior doesn't work, warn the user and suggest updating the app.

- **Problem:** Running `caffeinate` as a subprocess — if the parent process dies, the caffeinate process may become orphaned.
  - **Suggested Solution:** Use process groups or write the PID to the state file so any cleanup path can `kill` it explicitly.

---

## 📝 Other Notes
*Anything else you want to add? Additional context, changes, or clarifications:*

**Your Response:**
- ✅ **Naming resolved:** **Coffeetosh** = repo/brand umbrella (future macOS utilities). **LidCaf** = this specific app. App bundle = `LidCaf.app`, CLI binary = `lidcaf`, state file = `~/.lidcaf/status.json`, GitHub repo = `Coffeetosh/`. All references in R1 and code should follow this convention.

- ✅ **"Basic Keep Awake" Mode (Amphetamine Replacement) — Approved as Mode A:**

  LidCaf should support two distinct operating modes, not just the lid-closed SSH use case:

  **Mode A — Keep Awake (Standard)**
  Uses `IOPMAssertion` (Apple's official API) to prevent **idle sleep only**. The display stays on and the system stays awake, but lid-close behavior is untouched. No `pmset` changes, no admin password required. This is the mode for everyday use — keeping Mac awake during a long task, a presentation, or while monitoring something.

  **Mode B — LidCaf / Headless SSH (Power Mode)**
  Uses `pmset -a disablesleep 1` + `caffeinate`. Overrides lid-close sleep. Requires admin prompt. Designed specifically for headless SSH access with lid closed.

  The user picks the mode from the menu bar popover. Both modes share the same daemon/state file architecture, same CLI commands (`lidcaf start [hours] --mode keep-awake` vs default LidCaf mode), and same Settings panel.

  **Settings panel (from Amphetamine screenshot + our additions):**
  - `[ ]` Quit when activation duration is over
  - `[ ]` Allow the display to sleep (Mode A only — keep system awake but let screen dim)
  - `[ ]` Activate when an external display is connected
  - `[ ]` Deactivate when switched to another user account
  - `[ ]` Deactivate on battery level below [X]% (e.g., 20%) — our addition
  - `[ ]` SSH Session Monitor (Mode B only — auto-stop when last SSH session ends)
  - `[ ]` Auto-activate on AC power (toggleable)

  **Why this matters:** Makes LidCaf a full **Amphetamine replacement** — a genuinely useful open-source app for anyone, not just SSH users. Mode A has zero privilege requirements and works out of the box. Mode B is the power feature for developers.

---

**Next Step:** Once you've filled in your responses, say "Approved" to proceed to R1 generation.
