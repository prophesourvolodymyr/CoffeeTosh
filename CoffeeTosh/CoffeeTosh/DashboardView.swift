import SwiftUI
import AppKit
import CoffeetoshCore

struct DashboardView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                ProMaxOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                MainDashboardView()
            }
        }
        .frame(width: 820, height: 540)   // fixed non-resizable window
        .background(popoverBase) // Espresso Dark
        .colorScheme(.dark)
        // Detect window open and set dock appearance inside the view lifecycle
        .onAppear {
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                // Force window to front
                if let window = NSApplication.shared.windows.first(where: { $0.title == "Dashboard" }) {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            if let window = notification.object as? NSWindow, window.title == "Dashboard" {
                // When Dashboard closes, go back to utility mode
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}

// Complete Analytics & Dashboard View
struct MainDashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var history: [SessionHistoryItem] = []
    @State private var stats: HistoryStats = HistoryStats(totalSessions: 0, totalHoursPrevented: 0, keepAwakePercent: 0, headlessPercent: 0)
    @State private var selectedTab = "Analytics"
    @State private var sidebarVisible = false

    // Active-session banner (Bug #13)
    @State private var showSessionBanner = false

    // Badge "seen" flags — show badge until user visits the tab once
    @AppStorage("seenPresetTab")   private var seenPresetTab   = false
    @AppStorage("seenSettingsTab") private var seenSettingsTab = false

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar Navigation — slides in first (Lego brick #1)
            VStack(alignment: .leading, spacing: 10) {
                Text("COFFEETOSH")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(warmAmber)
                    .padding(.bottom, 10)
                    .padding(.leading, 12)

                SidebarButton(title: "Analytics", icon: "chart.bar.fill", isSelected: selectedTab == "Analytics") {
                    selectedTab = "Analytics"
                }

                SidebarButton(title: "CLI Guide", icon: "terminal.fill", isSelected: selectedTab == "CLI") {
                    selectedTab = "CLI"
                }

                SidebarButton(title: "Preset", icon: "bolt.fill", isSelected: selectedTab == "Preset",
                              showBadge: !seenPresetTab) {
                    seenPresetTab = true
                    selectedTab = "Preset"
                }

                SidebarButton(title: "Settings", icon: "gearshape.fill", isSelected: selectedTab == "Settings",
                              showBadge: !seenSettingsTab) {
                    seenSettingsTab = true
                    selectedTab = "Settings"
                }

                SidebarButton(title: "About", icon: "info.circle.fill", isSelected: selectedTab == "About") {
                    selectedTab = "About"
                }

                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 10)
            .frame(width: 180)
            .background(Color.black.opacity(0.3))
            .offset(x: sidebarVisible ? 0 : -190)
            .opacity(sidebarVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.0), value: sidebarVisible)

            // Content Area
            if selectedTab == "Analytics" {
                AnalyticsView(history: history, stats: stats, onClear: loadData)
                    .onAppear(perform: loadData)
            } else if selectedTab == "CLI" {
                CLIGuideView()
            } else if selectedTab == "Preset" {
                DashboardPresetView()
            } else if selectedTab == "Settings" {
                DashboardSettingsView()
            } else {
                AboutView()
            }
        }
        .onReceive(appState.$status) { newStatus in
            // Reload history when a session ends, even if the Analytics tab is open
            // (onAppear won't fire again while the tab is already visible).
            // DELAY: the optimistic `appState.status = .inactive` in ContentView fires
            // this handler BEFORE SleepManager.restore() (background thread) finishes
            // writing history.json.  Without a delay, loadData() reads the old/empty
            // file and stats animate to 0.  500 ms is plenty for the background
            // thread's appendSession() + markInactive() pair to complete.
            if !newStatus.active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    loadData()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                sidebarVisible = true
            }
            // Bug #13: show banner if a session is already running when Dashboard opens
            if appState.status.active {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.3)) {
                    showSessionBanner = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    withAnimation { showSessionBanner = false }
                }
            }
        }
        .overlay(alignment: .top) {
            if showSessionBanner {
                SessionActiveBanner(
                    mode: appState.status.mode,
                    remaining: appState.status.remainingSeconds
                ) {
                    withAnimation { showSessionBanner = false }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 10)
                .padding(.horizontal, 16)
            }
        }
    }

    private func loadData() {
        self.history = HistoryManager.shared.getHistory()
        self.stats = HistoryManager.shared.getStats()
    }
}

// MARK: - Session Active Banner

private struct SessionActiveBanner: View {
    let mode: CoffeetoshMode
    let remaining: Int?
    let onDismiss: () -> Void

    private var modeLabel: String {
        mode == .headless ? "Lid Closed" : "Keep Awake"
    }
    private var durationLabel: String {
        guard let secs = remaining, secs > 0 else { return "∞" }
        let h = secs / 3600; let m = (secs % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m left" }
        if h > 0 { return "\(h)h left" }
        return "\(m)m left"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Pulsing dot
            Circle()
                .fill(warmAmber)
                .frame(width: 8, height: 8)

            Image(systemName: mode == .headless ? "terminal.fill" : "cup.and.saucer.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(warmAmber)

            VStack(alignment: .leading, spacing: 1) {
                Text("Session Running — \(modeLabel)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(textPrimary)
                Text(durationLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(textSecondary)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(textSecondary)
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 42/255, green: 32/255, blue: 25/255))
                .shadow(color: .black.opacity(0.45), radius: 12, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(warmAmber.opacity(0.3), lineWidth: 1))
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var showBadge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                if showBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.red.opacity(0.6), radius: 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundColor(isSelected ? warmAmber : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? warmAmber.opacity(0.15) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showBadge)
    }
}

struct AnalyticsView: View {
    let history: [SessionHistoryItem]
    let stats: HistoryStats
    let onClear: (() -> Void)?  // called after history is wiped so parent reloads
    @State private var appeared = false

    init(history: [SessionHistoryItem], stats: HistoryStats, onClear: (() -> Void)? = nil) {
        self.history = history
        self.stats = stats
        self.onClear = onClear
    }

    // Cards metadata for indexed stagger
    private var statCards: [(title: String, value: Double, format: String)] {
        [
            ("Total Hours",    stats.totalHoursPrevented,         "%.1f"),
            ("Total Sessions", Double(stats.totalSessions),       "%.0f"),
            ("Keep Awake",     stats.keepAwakePercent,            "%.0f%%"),
            ("Lid Closed",     stats.headlessPercent,             "%.0f%%"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Analytics")
                    .font(.system(size: 28, weight: .bold))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.08), value: appeared)

                // Stat cards — Lego bricks #2-5, each drops in with stagger
                HStack(spacing: 20) {
                    ForEach(Array(statCards.enumerated()), id: \.offset) { idx, card in
                        StatCard(title: card.title, value: card.value, format: card.format)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 40)
                            .animation(
                                .spring(response: 0.48, dampingFraction: 0.62)
                                .delay(0.14 + Double(idx) * 0.08),
                                value: appeared
                            )
                    }
                }

                Text("Recent Sessions")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top, 10)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.44), value: appeared)

                // History rows — final Lego bricks, thwump thwump thwump
                if history.isEmpty {
                    Text("No sessions recorded yet.")
                        .foregroundColor(textSecondary)
                        .font(.system(size: 14))
                        .padding()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.5), value: appeared)
                } else {
                    VStack(spacing: 1) {
                        ForEach(Array(history.enumerated()), id: \.element.id) { idx, item in
                            HistoryRow(item: item)
                                .padding()
                                .background(Color.white.opacity(0.03))
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 28)
                                .animation(
                                    .spring(response: 0.42, dampingFraction: 0.65)
                                    .delay(0.48 + Double(idx) * 0.055),
                                    value: appeared
                                )
                        }
                    }
                    .cornerRadius(8)

                    // Clear History
                    Button(action: {
                        HistoryManager.shared.clearHistory()
                        onClear?()   // tell parent to reload its @State arrays
                        appeared = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            appeared = true
                        }
                    }) {
                        Label("Clear History", systemImage: "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textSecondary.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.6), value: appeared)
                }
            }
            .padding(30)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
        .onChange(of: appeared) { _ in
            // Reload history whenever the view re-animates (e.g. after clear)
            if appeared {
                // no-op here — parent DashboardView owns the data;
                // this is here as a hook if needed in future
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let format: String
    @State private var current: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textSecondary)
            AnimatedNumberText(number: current, format: format)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(warmAmber)
                .animation(nil, value: current == 0) // kill implicit parent animation on reset
        }
        .padding(16)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            // Snap to 0 without any animation (override parent implicit spring)
            var snap = Transaction()
            snap.animation = nil
            withTransaction(snap) { current = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeOut(duration: 1.1)) {
                    current = value
                }
            }
        }
        // Re-animate when stats reload after a session ends.
        .onChange(of: value) { newVal in
            var snap = Transaction()
            snap.animation = nil
            withTransaction(snap) { current = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.9)) {
                    current = newVal
                }
            }
        }
    }
}

// Counts up from 0 → target using SwiftUI's Animatable protocol.
// SwiftUI interpolates `animatableData` on every frame — no Timers needed.
private struct AnimatedNumberText: View, Animatable {
    var number: Double  // must be `var` — SwiftUI writes to animatableData each frame
    let format: String

    var animatableData: Double {
        get { number }
        set { number = newValue }
    }

    var body: some View {
        Text(String(format: format, number))
    }
}

struct HistoryRow: View {
    let item: SessionHistoryItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.startTime, style: .date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
                Text(item.startTime, style: .time)
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
            }
            .frame(width: 100, alignment: .leading)

            Text(item.mode == .keepAwake ? "Keep Awake" : "Lid Closed")
                .font(.system(size: 14))
                .foregroundColor(textPrimary)
                .frame(width: 120, alignment: .leading)

            // Actual duration — what really ran, not what was planned
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedActual)
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
                if item.actualDurationSeconds != nil && item.durationSeconds > 0 {
                    Text("of \(item.durationSeconds / 60)m planned")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary.opacity(0.55))
                }
            }
            .frame(width: 100, alignment: .leading)

            Spacer()

            Text(item.endReason)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .cornerRadius(4)
        }
    }

    private var formattedActual: String {
        let secs = item.effectiveDurationSeconds
        if secs == 0 { return "Indefinite" }
        let h = secs / 3600
        let m = (secs % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}

// MARK: - CLI Guide Tab

private struct CLISection: Identifiable {
    let id = UUID()
    let title: String
    let icon:  String
    let items: [CLIItem]
}
private struct CLIItem: Identifiable {
    let id = UUID()
    let cmd:  String
    let desc: String
}

private func buildCLISections() -> [CLISection] {
    [
        CLISection(title: "Setup", icon: "wrench.and.screwdriver.fill", items: [
            CLIItem(cmd: "coffeetosh install-cli",
                    desc: "Symlink the binary to /usr/local/bin so you can call it from any terminal."),
        ]),
        CLISection(title: "Start a Session", icon: "play.fill", items: [
            CLIItem(cmd: "coffeetosh start",
                    desc: "Use your saved Quick Preset. Prompts to set one if none is configured."),
            CLIItem(cmd: "coffeetosh start 2",
                    desc: "Lid Closed mode for exactly 2 hours."),
            CLIItem(cmd: "coffeetosh start --minutes 45",
                    desc: "Lid Closed mode for 45 minutes. Use --minutes (or -m) for sub-hour durations."),
            CLIItem(cmd: "coffeetosh start -m 90",
                    desc: "Shorthand for --minutes. Starts a 90-minute session."),
            CLIItem(cmd: "coffeetosh start 0",
                    desc: "Run indefinitely until you manually stop it."),
            CLIItem(cmd: "coffeetosh start 4 --mode keep-awake",
                    desc: "Keep Awake — prevents idle sleep only. No admin password needed."),
            CLIItem(cmd: "coffeetosh start 4 --low-power",
                    desc: "Lid Closed + macOS Low Power Mode enabled for the session duration."),
        ]),
        CLISection(title: "Quick Preset", icon: "bolt.fill", items: [
            CLIItem(cmd: "coffeetosh preset",
                    desc: "Show the currently saved Quick Preset."),
            CLIItem(cmd: "coffeetosh preset set keep-awake 2h",
                    desc: "Save a Keep Awake preset for 2 hours. One click in the menu bar activates it."),
            CLIItem(cmd: "coffeetosh preset set lid-closed 8h",
                    desc: "Save a Lid Closed preset for 8 hours."),
            CLIItem(cmd: "coffeetosh preset set lid-closed 0",
                    desc: "Save an indefinite Lid Closed preset (runs until you stop it)."),
            CLIItem(cmd: "coffeetosh preset clear",
                    desc: "Remove the saved preset."),
        ]),
        CLISection(title: "Control", icon: "stop.fill", items: [
            CLIItem(cmd: "coffeetosh stop",
                    desc: "Stop the active session and restore all system sleep settings."),
            CLIItem(cmd: "coffeetosh add",
                    desc: "Add 30 minutes to the running session (default increment)."),
            CLIItem(cmd: "coffeetosh add 60",
                    desc: "Add a custom number of minutes to the running session."),
        ]),
        CLISection(title: "Status & Help", icon: "info.circle.fill", items: [
            CLIItem(cmd: "coffeetosh status",
                    desc: "Print current session state, mode, remaining time, and daemon PID."),
            CLIItem(cmd: "coffeetosh help",
                    desc: "Show the full usage reference in your terminal."),
        ]),
        CLISection(title: "System Info", icon: "chart.bar.fill", items: [
            CLIItem(cmd: "coffeetosh battery",
                    desc: "Show battery percentage, charging source, and estimated time remaining."),
            CLIItem(cmd: "coffeetosh mac-temp",
                    desc: "Show Mac CPU and GPU die temperature via powermetrics. Prompts for admin password if not recently authenticated."),
        ]),
        CLISection(title: "Remote via SSH", icon: "network", items: [
            CLIItem(cmd: "ssh user@macbook.local \"coffeetosh start 12\"",
                    desc: "Start a 12-hour Lid Closed session on a remote Mac over SSH."),
            CLIItem(cmd: "ssh user@macbook.local \"coffeetosh status\"",
                    desc: "Check the session state on a remote Mac."),
            CLIItem(cmd: "ssh user@macbook.local \"coffeetosh stop\"",
                    desc: "Stop the session on a remote Mac."),
        ]),
    ]
}

struct CLIGuideView: View {
    @State private var appeared = false
    @State private var copiedCommand: String? = nil

    private let sections = buildCLISections()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                cliHeader
                cliBanner
                cliKeyFacts
                ForEach(Array(sections.enumerated()), id: \.element.id) { si, section in
                    cliSection(section, index: si)
                }
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }

    // MARK: sub-views (broken out so the type-checker handles each independently)

    @ViewBuilder private var cliHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(warmAmber)
                Text("CLI Guide")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textPrimary)
            }
            Text("Every command the coffeetosh binary supports — click any row to copy.")
                .font(.system(size: 14))
                .foregroundColor(textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.06), value: appeared)
    }

    @ViewBuilder private var cliBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(warmAmber)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text("First-time setup")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(textPrimary)
                Text("Run coffeetosh install-cli once to add the binary to your PATH (/usr/local/bin).")
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(warmAmber.opacity(0.07))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(warmAmber.opacity(0.18), lineWidth: 1))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.12), value: appeared)
    }

    private let keyFacts: [(icon: String, title: String, desc: String)] = [
        ("display",             "Screen turns off, system stays on",
         "In Lid Closed mode the display shuts off when you close the MacBook lid — saving energy while the CPU stays fully awake."),
        ("lock.fill",           "Admin password required for Lid Closed",
         "Lid Closed uses pmset to override system sleep. macOS will prompt for your admin password once when starting."),
        ("lock.shield.fill",    "Auto-locks if someone opens the lid",
         "If the lid is opened during a session, Coffeetosh instantly locks your Mac with the macOS lock screen. A password is required to get back in."),
        ("network",             "SSH access works while closed",
         "The machine stays networked. You can SSH in, run scripts, or manage it remotely the entire session."),
        ("arrow.down.app.fill", "Session runs in the background",
         "Closing the Coffeetosh window or quitting the app does not stop the session. Use coffeetosh stop or the Stop button."),
        ("infinity",            "Timer is optional",
         "Omit a duration (or pass 0) to run indefinitely. The session won't stop until you explicitly stop it."),
    ]

    @ViewBuilder private var cliKeyFacts: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(warmAmber)
                Text("WHAT YOU SHOULD KNOW")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(textSecondary)
            }
            .padding(.leading, 4)

            VStack(spacing: 6) {
                ForEach(Array(keyFacts.enumerated()), id: \.offset) { idx, fact in
                    HStack(alignment: .center, spacing: 14) {
                        Image(systemName: fact.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(warmAmber)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(fact.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(textPrimary)
                            Text(fact.desc)
                                .font(.system(size: 12))
                                .foregroundColor(textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.42, dampingFraction: 0.7).delay(0.16 + Double(idx) * 0.04), value: appeared)
                }
            }
        }
    }

    @ViewBuilder private func cliSection(_ section: CLISection, index si: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: section.icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(warmAmber)
                Text(section.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(textSecondary)
            }
            .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { ci, item in
                    CLICommandRow(
                        command: item.cmd,
                        description: item.desc,
                        isCopied: copiedCommand == item.cmd
                    ) {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.cmd, forType: .string)
                        copiedCommand = item.cmd
                        let snap = item.cmd
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if copiedCommand == snap { copiedCommand = nil }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 18)
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.68)
                        .delay(0.18 + Double(si) * 0.05 + Double(ci) * 0.035),
                        value: appeared
                    )
                }
            }
        }
    }
}

private struct CLICommandRow: View {
    let command:     String
    let description: String
    let isCopied:    Bool
    let onCopy:      () -> Void

    @State private var hovering = false

    // Split `coffeetosh` prefix from the rest so we can colour them differently
    private var cmdParts: (base: String, rest: String) {
        let parts = command.split(separator: " ", maxSplits: 1)
        if parts.count == 2 {
            return (String(parts[0]), " " + String(parts[1]))
        }
        return (command, "")
    }

    var body: some View {
        Button(action: onCopy) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Terminal chrome ──────────────────────────────────────────
                HStack(spacing: 5) {
                    Circle().fill(Color(red: 1,    green: 0.37, blue: 0.34)).frame(width: 7, height: 7)
                    Circle().fill(Color(red: 1,    green: 0.73, blue: 0.16)).frame(width: 7, height: 7)
                    Circle().fill(Color(red: 0.18, green: 0.78, blue: 0.35)).frame(width: 7, height: 7)
                    Spacer()
                    // Copy indicator sits in the title bar
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isCopied ? "Copied!" : "Copy")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(isCopied ? Color.green : textSecondary.opacity(hovering ? 0.8 : 0.35))
                    .animation(.spring(response: 0.2), value: isCopied)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.35))

                Divider().background(Color.white.opacity(0.06))

                // ── Prompt + command ─────────────────────────────────────────
                HStack(alignment: .top, spacing: 0) {
                    Text("❯ ")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(warmAmber)
                    Text(cmdParts.base)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(isCopied ? Color.green : textPrimary)
                    Text(cmdParts.rest)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(isCopied ? Color.green.opacity(0.8) : warmAmber.opacity(0.85))
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, description.isEmpty ? 10 : 4)

                // ── Description line ─────────────────────────────────────────
                if !description.isEmpty {
                    Text("# " + description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(textSecondary.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(hovering ? 0.70 : 0.55))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isCopied ? Color.green.opacity(0.5) : Color.white.opacity(hovering ? 0.12 : 0.06),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeInOut(duration: 0.12), value: hovering)
    }
}

struct AboutView: View {
    @State private var appeared = false

    private var logoImage: Image {
        if NSImage(named: "logo-filled") != nil { return Image("logo-filled") }
        return Image(nsImage: NSApp.applicationIconImage)
    }
    private var isNamedAsset: Bool { NSImage(named: "logo-filled") != nil }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // ── Logo ─────────────────────────────────────────────────────────
            logoImage
                .renderingMode(isNamedAsset ? .template : .original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isNamedAsset ? warmAmber : .white)
                .frame(width: 96, height: 96)
                .padding(.bottom, 22)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.82)
                .animation(.spring(response: 0.52, dampingFraction: 0.65).delay(0.06), value: appeared)

            // ── Name ─────────────────────────────────────────────────────────
            Text("CoffeeTosh")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(textPrimary)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.14), value: appeared)

            // ── Version pill ─────────────────────────────────────────────────
            Text("Version 1.2.0")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(warmAmber)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(warmAmber.opacity(0.12))
                .cornerRadius(20)
                .padding(.top, 8)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.20), value: appeared)

            // ── Tagline ──────────────────────────────────────────────────────
            Text("Keeps your Mac awake without the bloat.\nBuilt with Swift, by one developer who cared.")
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundColor(textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 48)
                .padding(.top, 18)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.26), value: appeared)

            // ── Divider ──────────────────────────────────────────────────────
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 60)
                .padding(.vertical, 28)
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.35).delay(0.32), value: appeared)

            // ── Buttons ──────────────────────────────────────────────────────
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    // GitHub
                    Link(destination: URL(string: "https://github.com/prophesourvolodymyr/Coffeetosh")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                            Text("GitHub")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(warmAmber)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(warmAmber.opacity(0.10))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(warmAmber.opacity(0.2), lineWidth: 1))
                    }

                    // Report a Bug
                    Link(destination: URL(string: "https://github.com/prophesourvolodymyr/Coffeetosh/issues/new")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "ladybug.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Report a Bug")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.09), lineWidth: 1))
                    }
                }

                // ── Donate ───────────────────────────────────────────────────
                Link(destination: URL(string: "https://buymeacoffee.com/professorvolodymyr")!) {
                    HStack(spacing: 8) {
                        // Buy Me a Coffee logo tile
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(red: 1.0, green: 0.82, blue: 0.18))
                                .frame(width: 22, height: 22)
                            Text("☕")
                                .font(.system(size: 12))
                        }
                        Text("Buy Me a Coffee")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.18))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Color(red: 1.0, green: 0.82, blue: 0.18).opacity(0.10))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 1.0, green: 0.82, blue: 0.18).opacity(0.28), lineWidth: 1)
                    )
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.36), value: appeared)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }
}

// MARK: - Preset Tab

struct DashboardPresetView: View {
    @AppStorage("presetMode")            private var presetMode: String = ""
    @AppStorage("presetDurationSeconds") private var presetDurationSeconds: Int = 0

    @State private var draftMode: String = ""
    @State private var draftDuration: Int = 0
    @State private var saved = false
    @State private var appeared = false

    private let durations: [(String, Int)] = [
        ("30m", 30*60), ("1h", 3600), ("2h", 7200), ("3h", 10800),
        ("4h", 14400), ("6h", 21600), ("8h", 28800), ("12h", 43200), ("24h", 86400), ("∞", 0)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // ── Header ──────────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(warmAmber)
                        Text("Quick Preset")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(textPrimary)
                    }
                    Text("One click on the menu bar icon activates this preset instantly.")
                        .font(.system(size: 14))
                        .foregroundColor(textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.08), value: appeared)

                // ── Active preset status pill ────────────────────────────────
                Group {
                    if presetMode.isEmpty {
                        // Subtle notification row — unobtrusive hint
                        HStack(spacing: 7) {
                            Image(systemName: "bolt.slash")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(textSecondary.opacity(0.5))
                            Text("No preset configured — pick a mode and duration below")
                                .font(.system(size: 12))
                                .foregroundColor(textSecondary.opacity(0.5))
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.025))
                        .cornerRadius(8)
                    } else {
                    HStack(spacing: 14) {
                        Image(systemName: presetMode == "headless" ? "terminal.fill" : "cup.and.saucer.fill")
                            .font(.system(size: 20))
                            .foregroundColor(warmAmber)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Active Preset")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(textSecondary)
                            Text(activePresetLabel)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(textPrimary)
                        }
                        Spacer()
                        Button("Clear") {
                            presetMode = ""
                            draftMode  = ""
                            AppPrefsWriter.clearPreset()
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(warmAmber.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(warmAmber.opacity(0.22), lineWidth: 1))
                }
                } // end Group
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.14), value: appeared)

                // ── Mode picker ──────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("MODE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(textSecondary)

                    HStack(spacing: 12) {
                        DashboardModeCard(
                            title: "Keep Awake",
                            desc: "Prevents sleep. Display stays on.",
                            icon: "cup.and.saucer.fill",
                            selected: draftMode == "keepAwake"
                        ) { draftMode = "keepAwake" }

                        DashboardModeCard(
                            title: "Lid Closed",
                            desc: "Blocks sleep assertions. Screen can turn off.",
                            icon: "terminal.fill",
                            selected: draftMode == "headless"
                        ) { draftMode = "headless" }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)
                .animation(.spring(response: 0.45, dampingFraction: 0.68).delay(0.22), value: appeared)

                // ── Duration picker ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("DURATION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(textSecondary)

                    let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(durations, id: \.1) { label, secs in
                            Button(action: { draftDuration = secs }) {
                                Text(label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(draftDuration == secs ? popoverBase : textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(draftDuration == secs ? warmAmber : Color.white.opacity(0.06))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)
                .animation(.spring(response: 0.45, dampingFraction: 0.68).delay(0.32), value: appeared)

                // ── Save CTA ─────────────────────────────────────────────────
                Button(action: savePreset) {
                    HStack(spacing: 8) {
                        Image(systemName: saved ? "checkmark" : "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(saved ? "Preset Saved!" : "Set as Preset")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(draftMode.isEmpty ? textSecondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(draftMode.isEmpty ? Color.white.opacity(0.06)
                                  : saved ? Color.green.opacity(0.75) : warmAmber)
                    )
                }
                .buttonStyle(.plain)
                .disabled(draftMode.isEmpty)
                .animation(.spring(response: 0.35), value: saved)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.40), value: appeared)
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            draftMode     = presetMode
            draftDuration = presetDurationSeconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }

    private var activePresetLabel: String {
        let modeStr = presetMode == "headless" ? "Lid Closed" : "Keep Awake"
        let durStr  = durations.first { $0.1 == presetDurationSeconds }?.0 ?? "∞"
        return "\(modeStr)  ·  \(durStr)"
    }

    private func savePreset() {
        presetMode            = draftMode
        presetDurationSeconds = draftDuration
        AppPrefsWriter.savePreset(mode: draftMode, durationSeconds: draftDuration)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { saved = false }
    }
}

private struct DashboardModeCard: View {
    let title: String
    let desc:  String
    let icon:  String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(selected ? warmAmber : textSecondary)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(selected ? textPrimary : textSecondary)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? warmAmber.opacity(0.10) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? warmAmber.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct DashboardSettingsView: View {
    @AppStorage("autoActivateOnACPower") private var autoActivateOnACPower = false
    @AppStorage("sshSessionMonitor")     private var sshSessionMonitor = false
    @AppStorage("launchAtLogin")         private var launchAtLogin = false
    @AppStorage("showInlineTimer")       private var showInlineTimer = true
    @AppStorage("lowPowerMode")          private var lowPowerMode = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))

                VStack(alignment: .leading, spacing: 10) {
                    Text("General")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .padding(.leading, 4)

                    VStack(spacing: 0) {
                        DashboardToggleRow(
                            title: "Launch at Login",
                            desc: "Start Coffeetosh automatically when you log in.",
                            isOn: Binding(
                                get: { launchAtLogin },
                                set: { newVal in
                                    launchAtLogin = newVal
                                    LaunchAtLoginHelper.set(newVal)
                                }
                            )
                        )
                        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
                        DashboardToggleRow(
                            title: "Show Timer in Menu Bar",
                            desc: "Show a live countdown next to the menu bar icon during a session.",
                            isOn: $showInlineTimer
                        )
                        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
                        DashboardToggleRow(
                            title: "Auto-activate on AC Power",
                            desc: "Automatically turn on Keep Awake when plugged in.",
                            isOn: $autoActivateOnACPower
                        )
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)

                    Text("Advanced")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .padding(.top, 20)
                        .padding(.leading, 4)

                    VStack(spacing: 0) {
                        DashboardToggleRow(
                            title: "SSH Session Monitor",
                            desc: "Automatically start Headless mode when an SSH connection is active.",
                            isOn: $sshSessionMonitor
                        )
                        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
                        DashboardToggleRow(
                            title: "Low Power Mode (Headless)",
                            desc: "Enable macOS Low Power Mode during a Headless session. Requires admin.",
                            isOn: $lowPowerMode
                        )
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Sync toggle to reflect the true SMAppService registration state
            launchAtLogin = LaunchAtLoginHelper.isEnabled
        }
    }
}

struct DashboardToggleRow: View {
    let title: String
    let desc: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: warmAmber))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

#Preview("Dashboard Main") {
    MainDashboardView()
        .environmentObject(AppState())
}

#Preview("Onboarding") {
    ProMaxOnboardingView(hasCompletedOnboarding: .constant(false))
}
