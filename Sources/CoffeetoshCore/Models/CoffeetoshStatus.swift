// CoffeetoshStatus.swift
// Coffeetosh / Coffeetosh Core Engine
// Source of Truth: ~/.coffeetosh/status.json

import Foundation

// MARK: - Mode Enum

/// The two operating modes for Coffeetosh.
/// - `keepAwake`: Mode A — IOPMAssertion only, no admin required.
/// - `headless`: Mode B — pmset disablesleep + caffeinate, admin required.
public enum CoffeetoshMode: String, Codable {
    case keepAwake = "keep-awake"
    case headless    = "headless"
}

// MARK: - Status Model

/// Atomic state shared between GUI, Daemon, and CLI via `~/.coffeetosh/status.json`.
public struct CoffeetoshStatus: Codable {

    // ── Core State ──────────────────────────────────────────────
    /// Whether a sleep-prevention session is currently running.
    public var active: Bool

    /// The operating mode of the current (or last) session.
    public var mode: CoffeetoshMode

    // ── Timing ──────────────────────────────────────────────────
    /// ISO-8601 timestamp of when the session started.
    public var startTime: Date?

    /// Total requested duration in seconds. `0` means indefinite.
    public var durationSeconds: Int

    // ── Process Tracking ────────────────────────────────────────
    /// PID of the background `coffeetosh-daemon` process.
    public var daemonPid: Int?

    /// PID of the `caffeinate` subprocess (Mode B only).
    public var caffeinatePid: Int?

    // ── Restore Data ────────────────────────────────────────────
    /// Raw `pmset -g` output captured *before* activation so restore is exact.
    public var originalPmset: String?

    // ── SSH Monitor ─────────────────────────────────────────────
    /// Whether the SSH session monitor is active (Mode B only).
    public var sshMonitorEnabled: Bool?

    /// Consecutive polls with zero ESTABLISHED SSH connections.
    public var consecutiveZeroCount: Int?

    // ── Expiry ──────────────────────────────────────────────────
    /// Written by the daemon when the timer expires; GUI reads to trigger popover.
    public var expiredAt: Date?

    /// Timestamp of the last SSH monitor check.
    public var lastCheckTime: Date?

    // ── Power Saving (Headless) ─────────────────────────────────
    /// Whether Low Power Mode should be enabled during headless sessions.
    public var lowPowerEnabled: Bool?

    /// Original display brightness (0.0–1.0) before we set it to minimum.
    /// Persisted here so ANY process (daemon, stop CLI) can restore it.
    public var originalBrightness: Float?

    /// Current lid (clamshell) state — written by daemon on each tick.
    public var lidClosed: Bool?

    /// One-shot flag: set by daemon when the lid is opened during an active
    /// Lid Closed session. GUI reads it and shows a "Session still running" prompt.
    /// Cleared by the GUI after it consumes the flag.
    public var lidOpenedDuringSession: Bool?

    // ── Public Init ─────────────────────────────────────────────
    public init(
        active: Bool,
        mode: CoffeetoshMode,
        startTime: Date? = nil,
        durationSeconds: Int = 0,
        daemonPid: Int? = nil,
        caffeinatePid: Int? = nil,
        originalPmset: String? = nil,
        sshMonitorEnabled: Bool? = nil,
        consecutiveZeroCount: Int? = nil,
        expiredAt: Date? = nil,
        lastCheckTime: Date? = nil,
        lowPowerEnabled: Bool? = nil,
        originalBrightness: Float? = nil,
        lidClosed: Bool? = nil,
        lidOpenedDuringSession: Bool? = nil
    ) {
        self.active = active
        self.mode = mode
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.daemonPid = daemonPid
        self.caffeinatePid = caffeinatePid
        self.originalPmset = originalPmset
        self.sshMonitorEnabled = sshMonitorEnabled
        self.consecutiveZeroCount = consecutiveZeroCount
        self.expiredAt = expiredAt
        self.lastCheckTime = lastCheckTime
        self.lowPowerEnabled = lowPowerEnabled
        self.originalBrightness = originalBrightness
        self.lidClosed = lidClosed
        self.lidOpenedDuringSession = lidOpenedDuringSession
    }
}

// MARK: - Defaults

extension CoffeetoshStatus {
    /// An inactive, clean-slate status object.
    public static let inactive = CoffeetoshStatus(
        active: false,
        mode: .headless,
        startTime: nil,
        durationSeconds: 0,
        daemonPid: nil,
        caffeinatePid: nil,
        originalPmset: nil,
        sshMonitorEnabled: nil,
        consecutiveZeroCount: nil,
        expiredAt: nil,
        lastCheckTime: nil,
        lowPowerEnabled: nil,
        originalBrightness: nil,
        lidClosed: nil
    )
}

// MARK: - Convenience

extension CoffeetoshStatus {
    /// Remaining seconds based on `startTime` and `durationSeconds`.
    /// Returns `nil` for indefinite sessions (`durationSeconds == 0`).
    public var remainingSeconds: Int? {
        guard durationSeconds > 0, let start = startTime else { return nil }
        let elapsed = Int(Date().timeIntervalSince(start))
        return max(0, durationSeconds - elapsed)
    }

    /// Human-readable remaining time, e.g. "5h 42m".
    public var remainingFormatted: String {
        guard let remaining = remainingSeconds else { return "∞" }
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
