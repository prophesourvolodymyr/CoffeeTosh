// BrightnessHelper.swift
// Coffeetosh / Coffeetosh Core Engine
// Nudges display brightness up by 1 notch as a visual "active" indicator.

import Foundation
import CoreGraphics

// MARK: - BrightnessHelper

/// Manages a ±1 notch brightness nudge as visual feedback that Coffeetosh is active.
///
/// - On activate: saves current brightness, bumps +1 notch (~6.25% of 16-step macOS scale).
/// - On restore:  returns brightness to the saved original value.
///
/// Uses CoreGraphics `CGDisplayIOServicePort` → IOKit `IODisplaySetFloatParameter`.
/// Works on built-in MacBook displays. External monitors may not respond.
public enum BrightnessHelper {

    // ── Constants ───────────────────────────────────────────────
    /// One macOS brightness "notch" on a 16-step scale (F1/F2 keys).
    private static let oneNotch: Float = 1.0 / 16.0  // ~0.0625

    // ── State ───────────────────────────────────────────────────
    /// Saved brightness before the nudge, so we can restore exactly.
    private static var savedBrightness: Float?
    /// Saved brightness before setting to minimum (headless power saving).
    private static var savedBrightnessBeforeMin: Float?

    // MARK: - Public API (Nudge — visual feedback)

    /// Bumps brightness up by 1 notch (clamped to 1.0).
    /// Saves the original value for later restore.
    public static func nudgeUp() {
        guard let current = getBuiltInBrightness() else {
            print("[BrightnessHelper] ⚠️ Could not read display brightness (external monitor?)")
            return
        }

        savedBrightness = current
        let target = min(current + oneNotch, 1.0)

        if setBuiltInBrightness(target) {
            print("[BrightnessHelper] 🔆 Brightness nudged: \(String(format: "%.1f%%", current * 100)) → \(String(format: "%.1f%%", target * 100))")
        }
    }

    /// Restores brightness to the value saved before `nudgeUp()`.
    /// Idempotent — safe to call if nudge never happened.
    public static func restoreOriginal() {
        guard let original = savedBrightness else { return }

        if setBuiltInBrightness(original) {
            print("[BrightnessHelper] 🔅 Brightness restored: \(String(format: "%.1f%%", original * 100))")
        }
        savedBrightness = nil
    }

    // MARK: - Public API (Minimum — headless power saving)

    /// Sets display to minimum brightness (1 notch above off).
    /// Saves the current value for later restore via `restoreFromMinimum()`.
    public static func setMinimum() {
        guard let current = getBuiltInBrightness() else {
            print("[BrightnessHelper] ⚠️ Could not read display brightness")
            return
        }

        savedBrightnessBeforeMin = current
        let minimum: Float = oneNotch  // ~6.25% — lowest visible

        if setBuiltInBrightness(minimum) {
            print("[BrightnessHelper] 🔅 Brightness set to minimum: \(String(format: "%.1f%%", minimum * 100))")
        }
    }

    /// Restores brightness from minimum to its pre-minimum value.
    public static func restoreFromMinimum() {
        guard let original = savedBrightnessBeforeMin else { return }

        if setBuiltInBrightness(original) {
            print("[BrightnessHelper] 🔆 Brightness restored from minimum: \(String(format: "%.1f%%", original * 100))")
        }
        savedBrightnessBeforeMin = nil
    }

    // MARK: - Public Access (for PowerSavingHelper cross-process restore)

    /// Public wrapper to read current built-in display brightness.
    public static func getBuiltInBrightnessPublic() -> Float? {
        return getBuiltInBrightness()
    }

    /// Public wrapper to set built-in display brightness.
    @discardableResult
    public static func setBuiltInBrightnessPublic(_ value: Float) -> Bool {
        return setBuiltInBrightness(value)
    }

    // MARK: - IOKit Display Brightness ──────────────────────────

    /// Reads the current brightness of the built-in display (0.0 – 1.0).
    private static func getBuiltInBrightness() -> Float? {
        var brightness: Float = 0
        var iterator: io_iterator_t = 0

        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard result == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            var brightnessValue: Float = 0
            let getResult = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightnessValue)
            if getResult == kIOReturnSuccess {
                brightness = brightnessValue
                IOObjectRelease(service)
                return brightness
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        return nil
    }

    /// Sets the brightness of the built-in display (0.0 – 1.0).
    @discardableResult
    private static func setBuiltInBrightness(_ value: Float) -> Bool {
        var iterator: io_iterator_t = 0

        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard result == kIOReturnSuccess else { return false }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            let setResult = IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, value)
            if setResult == kIOReturnSuccess {
                IOObjectRelease(service)
                return true
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        return false
    }
}
