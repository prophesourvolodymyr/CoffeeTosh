// SSHMonitor.swift
// Coffeetosh / Coffeetosh Core Engine
// Polls for active SSH connections; auto-restores sleep when sessions end.

import Foundation

// MARK: - SSHMonitor

/// Monitors active SSH connections on port 22 using `netstat`.
/// When enabled, replaces the timer — Coffeetosh stays awake as long as
/// at least one SSH session is ESTABLISHED. After 2 consecutive
/// zero-connection checks (60s grace), triggers deactivation.
public final class SSHMonitor {

    // ── Configuration ───────────────────────────────────────────
    /// Polling interval in seconds (default: 30s per R1 spec).
    public var pollInterval: TimeInterval = 30

    /// Consecutive zero-hit checks before triggering stop (default: 2 = 60s grace).
    public var graceMisses: Int = 2

    // ── State ───────────────────────────────────────────────────
    public private(set) var isRunning: Bool = false
    private var consecutiveZeroCount: Int = 0
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.coffeetosh.coffeetosh.sshmonitor", qos: .utility)

    // ── Callback ────────────────────────────────────────────────
    /// Fires when the grace period expires with zero SSH connections.
    public var onAllSessionsEnded: (() -> Void)?

    public init() {}

    // MARK: - Start / Stop ───────────────────────────────────────

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        consecutiveZeroCount = 0

        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + pollInterval, repeating: pollInterval)
        t.setEventHandler { [weak self] in
            self?.poll()
        }
        t.resume()
        timer = t

        print("[SSHMonitor] ✅ Started — polling every \(Int(pollInterval))s, grace: \(graceMisses) misses")
    }

    public func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        consecutiveZeroCount = 0
        print("[SSHMonitor] 🛑 Stopped")
    }

    // MARK: - Poll ───────────────────────────────────────────────

    private func poll() {
        let count = activeSSHConnectionCount()
        let now = Date()

        // Update status.json with monitor state
        if var status = try? StatusFileManager.read() {
            status.consecutiveZeroCount = count == 0 ? consecutiveZeroCount + 1 : 0
            status.lastCheckTime = now
            try? StatusFileManager.write(status)
        }

        if count > 0 {
            // Active sessions — reset counter
            if consecutiveZeroCount > 0 {
                print("[SSHMonitor] ↩️ SSH session detected (\(count) active) — resetting grace counter")
            }
            consecutiveZeroCount = 0
        } else {
            consecutiveZeroCount += 1
            print("[SSHMonitor] 🔍 No SSH sessions (\(consecutiveZeroCount)/\(graceMisses))")

            if consecutiveZeroCount >= graceMisses {
                print("[SSHMonitor] ⏰ Grace period expired — all SSH sessions ended")
                stop()
                DispatchQueue.main.async { [weak self] in
                    self?.onAllSessionsEnded?()
                }
            }
        }
    }

    // MARK: - Detection ──────────────────────────────────────────

    /// Returns the number of ESTABLISHED TCP connections on port 22.
    private func activeSSHConnectionCount() -> Int {
        let output = ShellHelper.run("netstat -an | grep '\\.22 ' | grep -c ESTABLISHED")
        return Int(output) ?? 0
    }
}
