// LidStateMonitor.swift
// Coffeetosh / Coffeetosh Core Engine
// Monitors MacBook lid (clamshell) state via IOKit.

import Foundation
import IOKit

// MARK: - LidTransition

/// Represents a lid state change detected between two polling ticks.
public enum LidTransition {
    case closed   // Lid just closed
    case opened   // Lid just opened
    case unchanged
}

// MARK: - LidStateMonitor

/// Polls `AppleClamshellState` from IOKit's `IOPMrootDomain` to detect
/// lid open/close transitions. Called on the daemon's 5-second tick loop.
///
/// Usage:
/// ```swift
/// let lidMonitor = LidStateMonitor()
/// // On each tick:
/// switch lidMonitor.poll() {
/// case .closed: // handle lid close
/// case .opened: // handle lid open
/// case .unchanged: break
/// }
/// ```
public final class LidStateMonitor {

    // ── State ───────────────────────────────────────────────────
    /// Previous lid state (nil = first poll, no transition emitted).
    private var previousClosed: Bool?

    /// Whether the lid is currently closed (last known state).
    public var isLidClosed: Bool {
        return previousClosed ?? Self.readClamshellState()
    }

    // MARK: - Init

    public init() {
        // Seed initial state without emitting a transition
        self.previousClosed = Self.readClamshellState()
        let state = previousClosed == true ? "closed" : "open"
        print("[LidStateMonitor] 📖 Initial lid state: \(state)")
    }

    // MARK: - Poll

    /// Check current lid state and return a transition if it changed.
    /// Call this on every daemon tick (e.g., every 5 seconds).
    public func poll() -> LidTransition {
        let currentClosed = Self.readClamshellState()

        defer { previousClosed = currentClosed }

        guard let previous = previousClosed else {
            // First poll — seed state, no transition
            return .unchanged
        }

        if currentClosed && !previous {
            return .closed
        } else if !currentClosed && previous {
            return .opened
        }
        return .unchanged
    }

    // MARK: - IOKit Clamshell Read ───────────────────────────────

    /// Reads `AppleClamshellState` from `IOPMrootDomain`.
    /// Returns `true` if the lid is closed, `false` if open.
    /// Returns `false` on desktops or if the property can't be read.
    public static func readClamshellState() -> Bool {
        let rootDomain = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPMrootDomain")
        )
        guard rootDomain != 0 else { return false }
        defer { IOObjectRelease(rootDomain) }

        guard let property = IORegistryEntryCreateCFProperty(
            rootDomain,
            "AppleClamshellState" as CFString,
            kCFAllocatorDefault,
            0
        ) else {
            return false
        }

        return (property.takeRetainedValue() as? Bool) ?? false
    }
}
