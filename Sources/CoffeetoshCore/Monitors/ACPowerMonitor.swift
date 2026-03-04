// ACPowerMonitor.swift
// Coffeetosh / Coffeetosh Core Engine
// Detects AC power connection/disconnection to auto-activate/deactivate Coffeetosh.

import Foundation
import IOKit.ps

// MARK: - ACPowerMonitor

/// Monitors AC power state changes via IOKit.
/// When enabled in Settings:
///   - AC connected → auto-start Coffeetosh with last-used duration/mode
///   - Battery only → auto-stop and restore sleep defaults
public final class ACPowerMonitor {

    // ── State ───────────────────────────────────────────────────
    public private(set) var isRunning: Bool = false
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.coffeetosh.coffeetosh.acmonitor", qos: .utility)
    private var lastKnownState: Bool? // true = AC, false = battery

    /// Polling interval in seconds (IOKit notifications are more elegant,
    /// but a 10s poll is reliable and avoids RunLoop complexity in CLI).
    public var pollInterval: TimeInterval = 10

    // ── Callbacks ───────────────────────────────────────────────
    /// Fires when AC power is connected.
    public var onACConnected: (() -> Void)?

    /// Fires when switching to battery power.
    public var onBatteryActive: (() -> Void)?

    public init() {}

    // MARK: - Start / Stop ───────────────────────────────────────

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        lastKnownState = isOnACPower()

        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + pollInterval, repeating: pollInterval)
        t.setEventHandler { [weak self] in
            self?.checkPowerState()
        }
        t.resume()
        timer = t

        let state = lastKnownState == true ? "AC" : "Battery"
        print("[ACPowerMonitor] ✅ Started — current: \(state), polling every \(Int(pollInterval))s")
    }

    public func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        lastKnownState = nil
        print("[ACPowerMonitor] 🛑 Stopped")
    }

    // MARK: - Poll ───────────────────────────────────────────────

    private func checkPowerState() {
        let currentlyOnAC = isOnACPower()

        guard currentlyOnAC != lastKnownState else { return } // No change
        lastKnownState = currentlyOnAC

        if currentlyOnAC {
            print("[ACPowerMonitor] ⚡ AC power connected")
            DispatchQueue.main.async { [weak self] in
                self?.onACConnected?()
            }
        } else {
            print("[ACPowerMonitor] 🔋 Switched to battery")
            DispatchQueue.main.async { [weak self] in
                self?.onBatteryActive?()
            }
        }
    }

    // MARK: - Power Source Detection ─────────────────────────────

    /// Returns `true` if the Mac is currently on AC power.
    public func isOnACPower() -> Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [Any],
              let firstSource = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, firstSource as CFTypeRef)?.takeUnretainedValue() as? [String: Any],
              let powerSource = description[kIOPSPowerSourceStateKey] as? String
        else {
            // If we can't determine, assume AC (safer — don't auto-stop)
            return true
        }
        return powerSource == kIOPSACPowerValue
    }
}
