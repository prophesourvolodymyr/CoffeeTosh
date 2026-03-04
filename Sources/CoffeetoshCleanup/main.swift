// main.swift
// coffeetosh-cleanup — Boot-time crash recovery for Coffeetosh
// Installed as a LaunchAgent, runs at login to catch stuck pmset states.

import Foundation
import CoffeetoshCore

// MARK: - Boot-Time Cleanup ──────────────────────────────────────
// Layer 3 of crash recovery:
// If the system crashed or the daemon was killed without cleanup,
// this script detects ghosted state and restores pmset defaults.

print("[coffeetosh-cleanup] 🔍 Checking for stuck Coffeetosh state…")

// 1. Read status.json
guard let status = try? StatusFileManager.read(), status.active else {
    print("[coffeetosh-cleanup] ✅ No active session — nothing to clean up.")
    exit(0)
}

// 2. Check if the daemon PID is still alive
if let pid = status.daemonPid {
    let alive = kill(Int32(pid), 0) == 0
    if alive {
        print("[coffeetosh-cleanup] ℹ️ Daemon PID \(pid) is still alive — no cleanup needed.")
        exit(0)
    }
    print("[coffeetosh-cleanup] ⚠️ Daemon PID \(pid) is DEAD but status.json says active — ghost detected!")
}

// 3. Kill orphan caffeinate process if it exists
if let cafPid = status.caffeinatePid {
    let cafAlive = kill(Int32(cafPid), 0) == 0
    if cafAlive {
        print("[coffeetosh-cleanup] 🛑 Killing orphan caffeinate PID \(cafPid)")
        CaffeinateProcess.kill(pid: Int32(cafPid))
    }
}

// 4. Restore pmset defaults
if status.mode == .headless {
    print("[coffeetosh-cleanup] 🔧 Restoring pmset -a disablesleep 0…")
    let result = ShellHelper.runWithAdmin("pmset -a disablesleep 0")
    if result {
        print("[coffeetosh-cleanup] ✅ pmset restored successfully.")
    } else {
        // Fallback: try without admin (may work if SIP allows)
        ShellHelper.run("pmset -a disablesleep 0")
        print("[coffeetosh-cleanup] ⚠️ Admin restore failed — attempted non-admin fallback.")
    }
}

// 5. Update status.json to inactive
try? StatusFileManager.markInactive()

print("[coffeetosh-cleanup] ✅ Cleanup complete — system sleep defaults restored.")
exit(0)
