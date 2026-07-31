// SudoersInstaller.swift
// Coffeetosh Core Engine
// Installs a sudoers rule so the daemon can run pmset without a password.

import Foundation

// MARK: - SudoersInstaller

/// Manages `/etc/sudoers.d/coffeetosh` — a sudoers rule that allows admin
/// users to run `pmset` without a password prompt.
///
/// **Why this exists:**
/// Mode B (Lid Closed) uses `pmset -a disablesleep 1` (requires admin).
/// When the daemon's timer expires, it must run `pmset -a disablesleep 0`
/// to restore sleep. But:
/// - The `sudo` token expires after ~5 minutes.
/// - The `osascript` admin dialog can't be shown with the lid closed.
///
/// This sudoers rule makes `sudo -n pmset ...` succeed permanently,
/// so the daemon can always restore system defaults — even at 3 AM
/// with the lid closed.
///
/// Installed once during the first Mode B activation using the same
/// admin authorization the user already provides.
public enum SudoersInstaller {

    private static let rulePath = "/etc/sudoers.d/coffeetosh"

    private static let ruleContent = """
    # Coffeetosh — passwordless pmset for daemon auto-restore.
    # Safe to remove: sudo rm /etc/sudoers.d/coffeetosh
    %admin ALL=(root) NOPASSWD: /usr/bin/pmset
    """

    /// Whether the sudoers rule is already installed.
    public static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: rulePath)
    }

    // MARK: - Install

    /// Installs the sudoers rule with admin privileges (may show dialog).
    @discardableResult
    public static func install() -> Bool {
        guard !isInstalled else {
            print("[SudoersInstaller] ℹ️ Rule already installed.")
            return true
        }
        return writeRule(admin: ShellHelper.runWithAdmin)
    }

    /// Installs the sudoers rule using a cached sudo token (no dialog).
    /// Call immediately after an interactive sudo command while the token is fresh.
    @discardableResult
    public static func installSilent() -> Bool {
        guard !isInstalled else { return true }
        return writeRule(admin: ShellHelper.runWithAdminNoPrompt)
    }

    /// Removes the sudoers rule.
    public static func uninstall() {
        guard isInstalled else { return }
        _ = ShellHelper.runWithAdmin("rm -f \(rulePath)")
        print("[SudoersInstaller] 🛑 Rule removed.")
    }

    // MARK: - Private

    private static func writeRule(admin: @escaping (String) -> Bool) -> Bool {
        let tmpPath = "/tmp/coffeetosh-sudoers-\(ProcessInfo.processInfo.processIdentifier)"

        // 1. Write rule to temp file (no shell quoting issues)
        do {
            try ruleContent.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        } catch {
            print("[SudoersInstaller] ⚠️ Failed to write temp file: \(error)")
            return false
        }

        // 2. Validate syntax with visudo (prevents bricking sudo)
        let check = ShellHelper.run("/usr/sbin/visudo -c -f \(tmpPath) 2>&1")
        guard check.contains("parsed OK") else {
            print("[SudoersInstaller] ⚠️ visudo validation failed: \(check)")
            try? FileManager.default.removeItem(atPath: tmpPath)
            return false
        }

        // 3. Copy to /etc/sudoers.d/ with correct ownership (requires root).
        //    Wrapped in sh -c so the entire command runs under one sudo invocation.
        let cmd = "sh -c 'cp \(tmpPath) \(rulePath) && chmod 0440 \(rulePath) && chown root:wheel \(rulePath) && rm -f \(tmpPath)'"
        let ok = admin(cmd)

        // 4. Cleanup temp file if admin failed
        try? FileManager.default.removeItem(atPath: tmpPath)

        if ok {
            print("[SudoersInstaller] ✅ Sudoers rule installed — daemon can now auto-restore pmset.")
        } else {
            print("[SudoersInstaller] ⚠️ Failed to install sudoers rule (pmset restore will require password).")
        }
        return ok
    }
}
