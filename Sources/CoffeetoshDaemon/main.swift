// main.swift
// coffeetosh-daemon — Background Daemon for Coffeetosh
// Detached process that owns the countdown, caffeinate, and pmset restore.
// Survives GUI quit and SSH disconnect.

import Foundation
import CoffeetoshCore

// MARK: - Signal Traps ──────────────────────────────────────────
// Layer 1 of crash recovery: unconditionally restore system defaults on death.

func installSignalTraps() {
    let handler: @convention(c) (Int32) -> Void = { sig in
        print("[coffeetosh-daemon] ⚡ Caught signal \(sig) — restoring system defaults…")
        SleepManager.shared.restore()
        // Restore brightness from persisted status if lid was closed
        if let status = try? StatusFileManager.read(),
           let originalBrightness = status.originalBrightness {
            _ = BrightnessHelper.setBuiltInBrightnessPublic(originalBrightness)
            print("[coffeetosh-daemon] 🔆 Brightness restored to \(String(format: "%.1f%%", originalBrightness * 100))")
        }
        exit(0)
    }
    signal(SIGINT, handler)
    signal(SIGTERM, handler)
    signal(SIGHUP, handler)
}

installSignalTraps()

// MARK: - Read Initial State ────────────────────────────────────

guard let status = try? StatusFileManager.read(), status.active else {
    print("[coffeetosh-daemon] ⚠️ No active session in status.json — exiting.")
    exit(1)
}

print("[coffeetosh-daemon] ✅ Started — mode: \(status.mode.rawValue), duration: \(status.durationSeconds == 0 ? "∞" : "\(status.durationSeconds)s")")

// MARK: - Activate Sleep Prevention ─────────────────────────────
// The DAEMON is the long-running process, so it must hold the IOPMAssertion
// and own the caffeinate subprocess. The CLI only writes status.json.
// For Mode B: the CLI already ran the admin pmset command (NSAppleScript needs
// a UI/terminal), so we pass skipAdmin: true to skip the admin prompt here.

let skipAdmin = status.mode == .headless  // CLI already set pmset for Mode B
let activated = SleepManager.shared.activate(mode: status.mode, durationSeconds: status.durationSeconds, skipAdmin: skipAdmin)
guard activated else {
    print("[coffeetosh-daemon] ❌ Failed to activate \(status.mode.rawValue) mode — exiting.")
    // Mark session as failed so CLI/GUI knows
    try? StatusFileManager.markInactive()
    exit(1)
}

// Write our PID + caffeinate PID into the status file
var updated = status
updated.daemonPid = Int(ProcessInfo.processInfo.processIdentifier)
// Re-read to get any fields SleepManager wrote (caffeinatePid, originalPmset)
if let fresh = try? StatusFileManager.read() {
    updated.caffeinatePid = fresh.caffeinatePid
    updated.originalPmset = fresh.originalPmset
}
updated.daemonPid = Int(ProcessInfo.processInfo.processIdentifier)
try? StatusFileManager.write(updated)

// MARK: - Lid State Monitor ─────────────────────────────────────
// Monitors the MacBook lid (clamshell) state via IOKit.
// On lid close → save brightness to status.json, set to minimum.
// On lid open  → restore brightness from status.json.

let lidMonitor = LidStateMonitor()

// If the lid is ALREADY closed at start (e.g., started via SSH), apply immediately
if lidMonitor.isLidClosed && status.mode == .headless {
    print("[coffeetosh-daemon] 🔒 Lid already closed — setting minimum brightness")
    let brightnessToSave = BrightnessHelper.getBuiltInBrightnessPublic() ?? 0.5
    var s = try! StatusFileManager.read()
    s.originalBrightness = brightnessToSave
    s.lidClosed = true
    try? StatusFileManager.write(s)
    BrightnessHelper.setMinimum()
} else {
    // Write initial lid state
    if var s = try? StatusFileManager.read() {
        s.lidClosed = lidMonitor.isLidClosed
        try? StatusFileManager.write(s)
    }
}

// MARK: - Countdown Loop ────────────────────────────────────────
// Runs on a 5-second tick. Checks:
//   1. Lid state transitions (brightness adjust)
//   2. Has the timer expired?
//   3. Has status.json been externally set to active=false (GUI/CLI stop)?
//   4. Has the status file been deleted?

let tickInterval: TimeInterval = 5

while true {
    Thread.sleep(forTimeInterval: tickInterval)

    // ── Read current state ──────────────────────────────────────
    guard let current = try? StatusFileManager.read() else {
        // File deleted or unreadable — treat as external stop
        print("[coffeetosh-daemon] 📁 status.json missing — restoring and exiting.")
        SleepManager.shared.restore()
        exit(0)
    }

    // ── External stop signal ────────────────────────────────────
    if !current.active {
        print("[coffeetosh-daemon] 🛑 External stop detected — restoring and exiting.")
        SleepManager.shared.restore()
        exit(0)
    }

    // ── Lid state monitoring (headless only) ────────────────────
    if current.mode == .headless {
        switch lidMonitor.poll() {
        case .closed:
            print("[coffeetosh-daemon] 🔒 Lid closed — saving brightness, setting minimum")
            // Save current brightness to status.json BEFORE setting minimum.
            // Fall back to 0.5 if read fails (Apple Silicon / display already off)
            // so restore always has a sensible value.
            let brightnessToSave = BrightnessHelper.getBuiltInBrightnessPublic() ?? 0.5
            var s = current
            s.originalBrightness = brightnessToSave
            s.lidClosed = true
            try? StatusFileManager.write(s)
            BrightnessHelper.setMinimum()

        case .opened:
            print("[coffeetosh-daemon] 🔓 Lid opened during Lid Closed session — locking screen")

            // Lock the Mac immediately via CGSession so no one can access the
            // desktop without the user's macOS password. This is real OS-level
            // security, not a custom overlay that can be bypassed by killing the app.
            _ = ShellHelper.run("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")

            // Restore brightness from what we saved on lid close
            if let original = current.originalBrightness {
                _ = BrightnessHelper.setBuiltInBrightnessPublic(original)
                print("[coffeetosh-daemon] 🔆 Brightness restored to \(String(format: "%.1f%%", original * 100))")
            }

            // Write lid state + one-shot flag so the GUI can show the overlay
            var s = current
            s.lidClosed = false
            s.originalBrightness = nil
            s.lidOpenedDuringSession = true   // GUI consumes this and clears it
            try? StatusFileManager.write(s)

        case .unchanged:
            break
        }
    }

    // ── Timer expiry check ──────────────────────────────────────
    if current.durationSeconds > 0, let start = current.startTime {
        let elapsed = Date().timeIntervalSince(start)
        if elapsed >= Double(current.durationSeconds) {
            print("[coffeetosh-daemon] ⏰ Timer expired after \(current.durationSeconds)s — restoring.")
            SleepManager.shared.restore()

            // Restore brightness if lid was closed (saved in status.json)
            if let originalBrightness = current.originalBrightness {
                _ = BrightnessHelper.setBuiltInBrightnessPublic(originalBrightness)
                print("[coffeetosh-daemon] 🔆 Brightness restored to \(String(format: "%.1f%%", originalBrightness * 100))")
            }

            // Write expiredAt so GUI can trigger the "Session ended" popover
            var expired = current
            expired.active = false
            expired.expiredAt = Date()
            expired.daemonPid = nil
            expired.caffeinatePid = nil
            try? StatusFileManager.write(expired)

            exit(0)
        }
    }

    // ── Still running — loop continues ──────────────────────────
}
