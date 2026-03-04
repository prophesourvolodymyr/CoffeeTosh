import Foundation

public struct SessionHistoryItem: Codable, Identifiable {
    public var id = UUID()
    public let startTime: Date
    public let durationSeconds: Int      // Planned duration (0 = indefinite)
    public let actualDurationSeconds: Int? // Real elapsed seconds — nil on old records
    public let mode: CoffeetoshMode
    public let endReason: String // "User Quit", "Expired", "System Sleep"
    
    public init(id: UUID = UUID(), startTime: Date, durationSeconds: Int, actualDurationSeconds: Int? = nil, mode: CoffeetoshMode, endReason: String) {
        self.id = id
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.mode = mode
        self.endReason = endReason
    }

    /// How long the session actually ran, or falls back to the planned value.
    public var effectiveDurationSeconds: Int {
        actualDurationSeconds ?? durationSeconds
    }
}

public class HistoryManager {
    public static let shared = HistoryManager()
    private let historyFileURL: URL
    
    private init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".coffeetosh")
        if !FileManager.default.fileExists(atPath: configDir.path) {
            try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        }
        historyFileURL = configDir.appendingPathComponent("history.json")
    }
    
    public func appendSession(_ item: SessionHistoryItem) {
        var logs = getHistory()
        logs.append(item)
        
        do {
            let data = try JSONEncoder().encode(logs)
            try data.write(to: historyFileURL)
        } catch {
            print("Failed to write history: \(error)")
        }
    }
    
    public func clearHistory() {
        try? FileManager.default.removeItem(at: historyFileURL)
    }

    public func getHistory() -> [SessionHistoryItem] {
        guard let data = try? Data(contentsOf: historyFileURL),
              let logs = try? JSONDecoder().decode([SessionHistoryItem].self, from: data) else {
            return []
        }
        return logs.sorted(by: { $0.startTime > $1.startTime })
    }
    
    public func getStats() -> HistoryStats {
        let logs = getHistory()
        let totalSessions = logs.count
        
        var totalSeconds = 0
        var keepAwakeCount = 0
        var headlessCount = 0
        
        for log in logs {
            // Always use actual elapsed time for stats — never the planned duration.
            // A session stopped after 5 min on a 1h preset should count as 5 min.
            totalSeconds += log.effectiveDurationSeconds
            if log.mode == .keepAwake { keepAwakeCount += 1 }
            else if log.mode == .headless { headlessCount += 1 }
        }
        
        let keepAwakePercent = totalSessions == 0 ? 0.0 : Double(keepAwakeCount) / Double(totalSessions) * 100.0
        let headlessPercent = totalSessions == 0 ? 0.0 : Double(headlessCount) / Double(totalSessions) * 100.0
        
        return HistoryStats(
            totalSessions: totalSessions,
            totalHoursPrevented: Double(totalSeconds) / 3600.0,
            keepAwakePercent: keepAwakePercent,
            headlessPercent: headlessPercent
        )
    }
}

public struct HistoryStats {
    public let totalSessions: Int
    public let totalHoursPrevented: Double
    public let keepAwakePercent: Double
    public let headlessPercent: Double
    
    public init(totalSessions: Int, totalHoursPrevented: Double, keepAwakePercent: Double, headlessPercent: Double) {
        self.totalSessions = totalSessions
        self.totalHoursPrevented = totalHoursPrevented
        self.keepAwakePercent = keepAwakePercent
        self.headlessPercent = headlessPercent
    }
}
