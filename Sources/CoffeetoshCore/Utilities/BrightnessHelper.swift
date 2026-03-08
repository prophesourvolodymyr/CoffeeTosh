// BrightnessHelper.swift
// Coffeetosh / Coffeetosh Core Engine
// Controls built-in display brightness.
// Primary:  CoreDisplay private framework via dlopen (Apple Silicon + modern macOS).
// Fallback: IODisplayConnect (Intel / older macOS).

import Foundation
import CoreGraphics
import IOKit
import Darwin   // dlopen / dlsym / dlclose

// MARK: - BrightnessHelper

public enum BrightnessHelper {

    // ── Constants ───────────────────────────────────────────────
    /// One macOS brightness "notch" on a 16-step scale (F1/F2 keys).
    private static let oneNotch: Float = 1.0 / 16.0

    // ── State ───────────────────────────────────────────────────
    private static var savedBrightness: Float?
    private static var savedBrightnessBeforeMin: Float?

    // MARK: - Public API (Nudge — visual feedback)

    public static func nudgeUp() {
        guard let current = getBuiltInBrightness() else {
            print("[BrightnessHelper] ⚠️ Could not read display brightness")
            return
        }
        savedBrightness = current
        let target = min(current + oneNotch, 1.0)
        if setBuiltInBrightness(target) {
            print("[BrightnessHelper] 🔆 Brightness nudged: \(String(format: "%.1f%%", current * 100)) → \(String(format: "%.1f%%", target * 100))")
        }
    }

    public static func restoreOriginal() {
        guard let original = savedBrightness else { return }
        if setBuiltInBrightness(original) {
            print("[BrightnessHelper] 🔅 Brightness restored: \(String(format: "%.1f%%", original * 100))")
        }
        savedBrightness = nil
    }

    // MARK: - Public API (Minimum — headless power saving)

    /// Sets display brightness to zero (fully off — backlight killed).
    /// Saves current value; falls back to 0.5 if brightness can't be read
    /// (e.g. Apple Silicon during rapid state changes or display already off).
    public static func setMinimum() {
        savedBrightnessBeforeMin = getBuiltInBrightness() ?? 0.5
        if setBuiltInBrightness(0.0) {
            print("[BrightnessHelper] 🔅 Brightness set to 0% (screen off, system awake)")
        } else {
            print("[BrightnessHelper] ⚠️ Could not set brightness to 0 (display not responding)")
        }
    }

    public static func restoreFromMinimum() {
        guard let original = savedBrightnessBeforeMin else { return }
        if setBuiltInBrightness(original) {
            print("[BrightnessHelper] 🔆 Brightness restored from minimum: \(String(format: "%.1f%%", original * 100))")
        }
        savedBrightnessBeforeMin = nil
    }

    // MARK: - Public Access (cross-process restore)

    public static func getBuiltInBrightnessPublic() -> Float? { getBuiltInBrightness() }

    @discardableResult
    public static func setBuiltInBrightnessPublic(_ value: Float) -> Bool { setBuiltInBrightness(value) }

    // MARK: - Read / Write (CoreDisplay-first)

    private static func getBuiltInBrightness() -> Float? {
        if let v = coreDisplayGet() { return Float(v) }
        return ioDisplayGet()
    }

    @discardableResult
    private static func setBuiltInBrightness(_ value: Float) -> Bool {
        if coreDisplaySet(Double(value)) { return true }
        return ioDisplaySet(value)
    }

    // MARK: - CoreDisplay (Apple Silicon + macOS 12+) ────────────
    // Uses dlopen so we don't need to link against the private framework.

    private static func coreDisplayGet() -> Double? {
        guard let handle = dlopen(
            "/System/Library/Frameworks/CoreDisplay.framework/CoreDisplay",
            RTLD_LAZY
        ) else { return nil }
        defer { dlclose(handle) }
        guard let sym = dlsym(handle, "CoreDisplay_Display_GetUserBrightness") else { return nil }
        typealias Fn = @convention(c) (UInt32) -> Double
        let fn = unsafeBitCast(sym, to: Fn.self)
        let v = fn(UInt32(CGMainDisplayID()))
        return (v >= 0 && v <= 1) ? v : nil
    }

    @discardableResult
    private static func coreDisplaySet(_ value: Double) -> Bool {
        guard let handle = dlopen(
            "/System/Library/Frameworks/CoreDisplay.framework/CoreDisplay",
            RTLD_LAZY
        ) else { return false }
        defer { dlclose(handle) }
        guard let sym = dlsym(handle, "CoreDisplay_Display_SetUserBrightness") else { return false }
        typealias Fn = @convention(c) (UInt32, Double) -> Void
        let fn = unsafeBitCast(sym, to: Fn.self)
        fn(UInt32(CGMainDisplayID()), value)
        return true
    }

    // MARK: - IODisplayConnect (Intel / older macOS fallback) ─────

    private static func ioDisplayGet() -> Float? {
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        ) == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            var v: Float = 0
            if IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &v) == kIOReturnSuccess {
                IOObjectRelease(service)
                return v
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        return nil
    }

    @discardableResult
    private static func ioDisplaySet(_ value: Float) -> Bool {
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        ) == kIOReturnSuccess else { return false }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            if IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, value) == kIOReturnSuccess {
                IOObjectRelease(service)
                return true
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        return false
    }
}
