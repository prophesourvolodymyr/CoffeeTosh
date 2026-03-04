// SleepManager.swift
// Coffeetosh / Coffeetosh Core Engine
// Dual-Mode sleep prevention engine.

import Foundation
import IOKit
import IOKit.pwr_mgt

// MARK: - SleepManager

/// The core dual-mode engine for preventing macOS sleep.
///
/// - **Mode A (Keep Awake):** `IOPMAssertionCreateWithName` — prevents idle-sleep.
///   No admin required. Standard `kIOPMAssertionTypePreventUserIdleSystemSleep`.
///
/// - **Mode B (Coffeetosh / Headless):** `pmset -a disablesleep 1` via admin AppleScript +
///   `caffeinate -dis` subprocess. Prevents lid-close sleep for SSH.
public final class SleepManager {

    // ── Singleton ───────────────────────────────────────────────
    public static let shared = SleepManager()
    private init() {}

    // ── State ───────────────────────────────────────────────────
    public private(set) var isActive: Bool = false
    public private(set) var currentMode: CoffeetoshMode = .headless

    // ── Mode A handles ──────────────────────────────────────────
    /// IOKit assertion ID for Mode A — prevents system idle sleep.
    /// Display is intentionally allowed to sleep normally.
    private var systemAssertionID: IOPMAssertionID = IOPMAssertionID(0)

    // ── Mode B handles ──────────────────────────────────────────
    /// The caffeinate subprocess wrapper.
    private let caffeinate = CaffeinateProcess()

    /// Raw `pmset -g` snapshot taken before activation — used for exact restore.
    private var originalPmsetSnapshot: String?

    // MARK: - Activate ───────────────────────────────────────────

    /// Activates sleep prevention in the requested mode.
    ///
    /// - Parameters:
    ///   - mode: `.keepAwake` (Mode A) or `.headless` (Mode B).
    ///   - durationSeconds: Total duration. `0` = indefinite.
    ///   - skipAdmin: If `true`, skip the admin pmset command (used by daemon when CLI already ran it).
    /// - Returns: `true` if activation succeeded.
    @discardableResult
    public func activate(mode: CoffeetoshMode, durationSeconds: Int = 0, skipAdmin: Bool = false) -> Bool {
        // Safety: deactivate anything running first
        if isActive { restore() }

        currentMode = mode

        switch mode {
        case .keepAwake:
            guard activateModeA() else { return false }
        case .headless:
            if skipAdmin {
                // Daemon path: pmset already set by CLI, just start caffeinate
                guard activateModeBDaemonOnly() else { return false }
            } else {
                // Interactive path (CLI foreground / GUI): full admin + caffeinate
                guard activateModeB() else { return false }
            }
        }

        isActive = true

        // Visual feedback: bump brightness 1 notch so the user sees it activated
        BrightnessHelper.nudgeUp()

        // Persist to status.json
        var status = CoffeetoshStatus(
            active: true,
            mode: mode,
            startTime: Date(),
            durationSeconds: durationSeconds,
            daemonPid: Int(ProcessInfo.processInfo.processIdentifier),
            caffeinatePid: caffeinate.pid.map { Int($0) },
            originalPmset: originalPmsetSnapshot,
            sshMonitorEnabled: nil,
            consecutiveZeroCount: nil,
            expiredAt: nil,
            lastCheckTime: nil
        )
        // Preserve SSH monitor prefs from existing file
        if let existing = try? StatusFileManager.read() {
            status.sshMonitorEnabled = existing.sshMonitorEnabled
        }
        try? StatusFileManager.write(status)

        print("[SleepManager] ✅ Activated — mode: \(mode.rawValue), duration: \(durationSeconds == 0 ? "∞" : "\(durationSeconds)s")")
        return true
    }

    // MARK: - Pre-Activate Admin (CLI-side) ──────────────────────

    /// Runs the admin-escalated `pmset -a disablesleep 1` from the CLI process
    /// (which has terminal/UI access for the password prompt).
    /// Call this BEFORE launching the daemon for Mode B.
    ///
    /// - Parameter useSudo: If `true`, uses interactive `sudo` (for CLI). If `false`, uses NSAppleScript (for GUI).
    /// - Returns: `true` if pmset was successfully set.
    @discardableResult
    public func preActivateModeBAdmin(useSudo: Bool = true) -> Bool {
        // Capture original pmset settings
        originalPmsetSnapshot = ShellHelper.run("pmset -g")
        print("[SleepManager] Mode B Pre-Activate: Captured pmset snapshot")

        // Run admin-escalated pmset
        let ok: Bool
        if useSudo {
            ok = ShellHelper.runWithSudo("pmset -a disablesleep 1")
        } else {
            ok = ShellHelper.runWithAdmin("pmset -a disablesleep 1")
        }
        guard ok else {
            print("[SleepManager] ⚠️ Mode B Pre-Activate: Admin escalation denied/failed.")
            originalPmsetSnapshot = nil
            return false
        }
        print("[SleepManager] Mode B Pre-Activate: pmset disablesleep 1 — SET")
        return true
    }

    // MARK: - Restore (Deactivate) ───────────────────────────────

    /// Restores original macOS sleep settings and tears down all overrides.
    /// Safe to call multiple times — idempotent.
    public func restore(reason: String = "User Stopped") {
        // Do NOT guard on the in-memory isActive — it is stale after a process
        // restart. Always check the status file as source of truth.
        let fileActive = (try? StatusFileManager.read())?.active ?? false
        guard isActive || fileActive else { return }

        // Record history before clearing state
        if let status = try? StatusFileManager.read(), status.active {
            // Compute actual elapsed seconds — not the preset duration.
            let actualSecs = Int(Date().timeIntervalSince(status.startTime ?? Date()))
            let item = SessionHistoryItem(
                startTime: status.startTime ?? Date(),
                durationSeconds: status.durationSeconds,
                actualDurationSeconds: max(1, actualSecs),
                mode: status.mode,
                endReason: reason
            )
            HistoryManager.shared.appendSession(item)
        }

        switch currentMode {
        case .keepAwake:
            deactivateModeA()
        case .headless:
            deactivateModeB()
        }

        isActive = false
        originalPmsetSnapshot = nil

        // Restore brightness to pre-activation level
        BrightnessHelper.restoreOriginal()

        // Update status file
        try? StatusFileManager.markInactive()

        print("[SleepManager] 🛑 Restored — system sleep defaults active.")
    }

    // MARK: - Mode A  ────────────────────────────────────────────

    /// Creates an IOKit assertion to prevent system idle sleep only.
    /// Display is allowed to sleep normally — no point forcing it on.
    private func activateModeA() -> Bool {
        let reason = "Coffeetosh Keep Awake — preventing idle sleep" as CFString

        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &systemAssertionID
        )
        guard result == kIOReturnSuccess else {
            print("[SleepManager] ⚠️ Mode A: System assertion failed (\(result))")
            return false
        }

        print("[SleepManager] Mode A: System assertion created (\(systemAssertionID))")
        return true
    }

    /// Releases the system sleep assertion.
    private func deactivateModeA() {
        let result = IOPMAssertionRelease(systemAssertionID)
        if result == kIOReturnSuccess {
            print("[SleepManager] Mode A: System assertion released")
        }
        systemAssertionID = IOPMAssertionID(0)
    }

    // MARK: - Mode B (Full — Interactive) ─────────────────────────

    /// Full Mode B activation: admin pmset + caffeinate.
    /// Used for CLI foreground mode or future GUI.
    private func activateModeB() -> Bool {
        // 1. Capture original pmset settings
        originalPmsetSnapshot = ShellHelper.run("pmset -g")
        print("[SleepManager] Mode B: Captured original pmset snapshot (\(originalPmsetSnapshot?.count ?? 0) chars)")

        // 2. Disable system sleep via admin-escalated pmset
        let pmsetOk = ShellHelper.runWithAdmin("pmset -a disablesleep 1")
        guard pmsetOk else {
            print("[SleepManager] ⚠️ Mode B: pmset admin escalation failed — aborting.")
            originalPmsetSnapshot = nil
            return false
        }
        print("[SleepManager] Mode B: pmset disablesleep 1 — SET")

        // 3. Fork caffeinate subprocess
        let cafPid = caffeinate.start()
        if cafPid == nil {
            print("[SleepManager] ⚠️ Mode B: caffeinate failed to start (pmset still active, continuing)")
        }

        return true
    }

    // MARK: - Mode B (Daemon-Only — No Admin) ────────────────────

    /// Daemon-only Mode B activation: starts caffeinate only.
    /// Assumes CLI already ran `preActivateModeBAdmin()` to set pmset.
    private func activateModeBDaemonOnly() -> Bool {
        // Capture current pmset for reference (no admin needed for read)
        originalPmsetSnapshot = ShellHelper.run("pmset -g")
        print("[SleepManager] Mode B (Daemon): pmset already set by CLI, starting caffeinate only")

        // Fork caffeinate subprocess
        let cafPid = caffeinate.start()
        if cafPid == nil {
            print("[SleepManager] ⚠️ Mode B (Daemon): caffeinate failed to start")
            // Not fatal — pmset disablesleep is already active
        }

        return true
    }

    /// Kills caffeinate subprocess and restores pmset to defaults.
    /// Tries sudo first (works if cached), then NSAppleScript, then warns user.
    private func deactivateModeB() {
        // 1. Kill caffeinate
        caffeinate.stop()

        // 2. Restore pmset — try sudo (timestamp may be cached from pre-activate)
        let sudoOk = ShellHelper.runWithSudo("pmset -a disablesleep 0")
        if sudoOk {
            print("[SleepManager] Mode B: pmset disablesleep 0 — RESTORED (sudo)")
            return
        }

        // 3. Fallback: NSAppleScript (works in GUI)
        let adminOk = ShellHelper.runWithAdmin("pmset -a disablesleep 0")
        if adminOk {
            print("[SleepManager] Mode B: pmset disablesleep 0 — RESTORED (admin)")
            return
        }

        print("[SleepManager] ⚠️ Mode B: Could not restore pmset. Run manually: sudo pmset -a disablesleep 0")
    }
}
