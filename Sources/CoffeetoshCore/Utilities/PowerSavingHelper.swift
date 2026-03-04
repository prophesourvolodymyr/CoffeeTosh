// PowerSavingHelper.swift
// Coffeetosh / Coffeetosh Core Engine
// Low Power Mode and minimum brightness for headless sessions.

import Foundation

// MARK: - PowerSavingHelper

/// Manages power-saving optimizations during headless sessions:
/// - Enables macOS Low Power Mode (`pmset lowpowermode 1`)
/// - Sets display brightness to minimum (via BrightnessHelper)
///
/// Original brightness is persisted to `status.json` so ANY process
/// (daemon, stop CLI) can restore it — not just the process that set it.
public enum PowerSavingHelper {

    // ── State ───────────────────────────────────────────────────
    private static var wasLowPowerEnabled: Bool = false

    // MARK: - Enable Power Saving

    /// Activates power-saving measures for headless mode.
    /// - Parameter lowPower: Whether to enable macOS Low Power Mode (optional).
    /// Brightness is ALWAYS set to minimum for headless — this is not optional.
    public static func activate(lowPower: Bool = false) {
        // 1. Set brightness to minimum — save original to status.json
        setMinimumBrightness()

        // 2. Enable Low Power Mode if requested
        if lowPower {
            enableLowPowerMode()
        }

        print("[PowerSavingHelper] ✅ Power saving active (lowPower: \(lowPower))")
    }

    // MARK: - Restore

    /// Restores all power-saving changes. Reads original brightness from status.json.
    /// Safe to call from any process (daemon or CLI).
    public static func restore() {
        // 1. Restore brightness (reads originalBrightness from status.json)
        restoreBrightness()

        // 2. Disable Low Power Mode if we enabled it
        // Note: for the daemon expiry path, we read lowPowerEnabled from status.json
        if wasLowPowerEnabled {
            disableLowPowerMode()
        }

        print("[PowerSavingHelper] 🔅 Power saving restored")
    }

    /// Restores power saving using status.json data (for daemon/stop which run in a different process).
    /// Reads `originalBrightness` and `lowPowerEnabled` from the persisted status.
    public static func restoreFromStatus(_ status: CoffeetoshStatus) {
        // 1. Restore brightness from persisted value
        if let originalBrightness = status.originalBrightness {
            if BrightnessHelper.setBuiltInBrightnessPublic(originalBrightness) {
                print("[PowerSavingHelper] 🔆 Brightness restored to \(String(format: "%.1f%%", originalBrightness * 100))")
            }
        }

        // 2. Restore Low Power Mode if we enabled it
        if status.lowPowerEnabled == true {
            // Check if LPM is currently on before disabling
            let current = ShellHelper.run("pmset -g | grep lowpowermode")
            if current.contains("1") {
                _ = ShellHelper.runWithSudo("pmset -a lowpowermode 0")
                print("[PowerSavingHelper] ⚡ Low Power Mode disabled")
            }
        }

        print("[PowerSavingHelper] 🔅 Power saving restored (from status)")
    }

    // MARK: - Low Power Mode ─────────────────────────────────────

    private static func enableLowPowerMode() {
        // Check current state so we only restore if WE changed it
        let current = ShellHelper.run("pmset -g | grep lowpowermode")
        let alreadyOn = current.contains("1")

        if alreadyOn {
            wasLowPowerEnabled = false  // Don't disable on restore — user had it on
            print("[PowerSavingHelper] Low Power Mode already enabled by user")
        } else {
            let ok = ShellHelper.runWithSudo("pmset -a lowpowermode 1")
            wasLowPowerEnabled = ok
            if ok {
                print("[PowerSavingHelper] ⚡ Low Power Mode enabled")
            }
        }
    }

    private static func disableLowPowerMode() {
        _ = ShellHelper.runWithSudo("pmset -a lowpowermode 0")
        wasLowPowerEnabled = false
        print("[PowerSavingHelper] ⚡ Low Power Mode disabled")
    }

    // MARK: - Minimum Brightness ─────────────────────────────────

    private static func setMinimumBrightness() {
        // Save current brightness to status.json for cross-process restore
        if let current = BrightnessHelper.getBuiltInBrightnessPublic() {
            // Persist to status.json so daemon/stop CLI can restore
            if var status = try? StatusFileManager.read() {
                status.originalBrightness = current
                try? StatusFileManager.write(status)
            }
        }
        BrightnessHelper.setMinimum()
    }

    private static func restoreBrightness() {
        // Try reading persisted brightness from status.json
        if let status = try? StatusFileManager.read(),
           let originalBrightness = status.originalBrightness {
            _ = BrightnessHelper.setBuiltInBrightnessPublic(originalBrightness)
            print("[PowerSavingHelper] 🔆 Brightness restored to \(String(format: "%.1f%%", originalBrightness * 100))")
        } else {
            // Fallback to in-memory restore
            BrightnessHelper.restoreFromMinimum()
        }
    }
}
