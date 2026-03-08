import SwiftUI
import ServiceManagement
import CoffeetoshCore

struct SettingsView: View {
    /// Provided when shown as an overlay inside ContentView (dismiss env doesn't reach overlays).
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss

    // Preset
    @AppStorage("presetMode")            private var presetMode: String = ""
    @AppStorage("presetDurationSeconds") private var presetDurationSeconds: Int = 0

    // General prefs
    @AppStorage("autoActivateOnACPower") private var autoActivateOnACPower = false
    @AppStorage("sshSessionMonitor")     private var sshSessionMonitor = false
    @AppStorage("lowPowerMode")          private var lowPowerMode = false
    @AppStorage("launchAtLogin")         private var launchAtLogin = false
    @AppStorage("showInlineTimer")       private var showInlineTimer = true

    // Temporary selection state for the preset picker (mirrors stored values)
    @State private var draftMode: String = ""
    @State private var draftDuration: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    if let onBack { onBack() } else { dismiss() }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(textSecondary)
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44) // Generous touch target
                
                Spacer()
                
                Text("Settings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textPrimary)
                
                Spacer()
                
                // Empty view to balance the header layout
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(popoverBase)
            
            Divider()
                .background(textSecondary.opacity(0.3))
            
            // Settings List
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Group 1: General
                    VStack(alignment: .leading, spacing: 1) {
                        Text("GENERAL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(textSecondary)
                            .padding(.leading, 12)
                            .padding(.bottom, 6)
                        
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                title: "Launch at Login",
                                isOn: Binding(
                                    get: { launchAtLogin },
                                    set: { newVal in
                                        launchAtLogin = newVal
                                        LaunchAtLoginHelper.set(newVal)
                                    }
                                )
                            )
                            Divider().background(textSecondary.opacity(0.15)).padding(.leading, 16)
                            SettingsToggleRow(
                                title: "Show Timer in Menu Bar",
                                isOn: $showInlineTimer
                            )
                            Divider().background(textSecondary.opacity(0.15)).padding(.leading, 16)
                            SettingsToggleRow(
                                title: "Auto-activate on AC Power",
                                isOn: $autoActivateOnACPower
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(cardSection)
                        )
                    }
                    
                    // Group 2: Advanced
                    VStack(alignment: .leading, spacing: 1) {
                        Text("ADVANCED")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(textSecondary)
                            .padding(.leading, 12)
                            .padding(.bottom, 6)
                        
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                title: "SSH Session Monitor",
                                isOn: $sshSessionMonitor
                            )
                            Divider().background(textSecondary.opacity(0.15)).padding(.leading, 16)
                            SettingsToggleRow(
                                title: "Low Power Mode (Lid Closed)",
                                isOn: $lowPowerMode
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(cardSection)
                        )
                    }
                    
                    // Group 3: App
                    VStack(alignment: .leading, spacing: 1) {
                        Text("APP")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(textSecondary)
                            .padding(.leading, 12)
                            .padding(.bottom, 6)

                        VStack(spacing: 0) {
                            Button(action: {
                                // Open Dashboard via AppKit — openWindow env not available in NSPopover context
                                NSApp.setActivationPolicy(.regular)
                                NSApp.activate(ignoringOtherApps: true)
                                NSApp.windows.first { $0.canBecomeKey }?.makeKeyAndOrderFront(nil)
                            }) {
                                HStack {
                                    Text("Open Dashboard")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundStyle(textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
                    }

                    // Group 4: Quick Preset
                    PresetPickerSection(presetMode: $presetMode,
                                        presetDurationSeconds: $presetDurationSeconds)
                }
                .padding(20)
            }
        }
        .frame(width: 280, height: 400)
        .background(popoverBase)
        .colorScheme(.dark)
        .onAppear {
            // Sync Launch at Login toggle to reflect actual SMAppService registration state
            launchAtLogin = LaunchAtLoginHelper.isEnabled
        }
    }
}

// MARK: - Preset Picker Section

private struct PresetPickerSection: View {
    @Binding var presetMode: String
    @Binding var presetDurationSeconds: Int

    @State private var draftMode: String = ""
    @State private var draftDuration: Int = 0

    private let durations: [(String, Int)] = [
        ("30m", 30*60), ("1h", 3600), ("2h", 7200), ("3h", 10800),
        ("4h", 14400), ("6h", 21600), ("8h", 28800), ("∞", 0)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("QUICK PRESET")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(textSecondary)

                Spacer()

                if !presetMode.isEmpty {
                    // Active preset badge
                    Text(presetLabel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(warmAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(warmAmber.opacity(0.12))
                        .cornerRadius(5)
                }
            }
            .padding(.leading, 12)

            VStack(spacing: 12) {
                // Mode picker
                HStack(spacing: 0) {
                    PresetModeTab(label: "Keep Awake", selected: draftMode == "keepAwake") {
                        draftMode = "keepAwake"
                    }
                    PresetModeTab(label: "Lid Closed", selected: draftMode == "headless") {
                        draftMode = "headless"
                    }
                }
                .background(cardSection)
                .cornerRadius(8)

                // Duration grid
                let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(durations, id: \.1) { label, secs in
                        Button(action: { draftDuration = secs }) {
                            Text(label)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(draftDuration == secs ? popoverBase : textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(draftDuration == secs ? warmAmber : Color.white.opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Action row
                HStack(spacing: 8) {
                    Button(action: clearPreset) {
                        Text("Clear")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .opacity(presetMode.isEmpty ? 0.35 : 1)

                    Button(action: savePreset) {
                        Label("Set Preset", systemImage: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(draftMode.isEmpty ? textSecondary : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(draftMode.isEmpty ? Color.white.opacity(0.06) : warmAmber)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(draftMode.isEmpty)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(cardSection))
        }
        .onAppear {
            draftMode     = presetMode
            draftDuration = presetDurationSeconds
        }
    }

    private var presetLabel: String {
        let modeStr = presetMode == "headless" ? "Lid Closed" : "Keep Awake"
        let durStr  = durations.first { $0.1 == presetDurationSeconds }?.0 ?? "∞"
        return "\(modeStr) · \(durStr)"
    }

    private func savePreset() {
        presetMode            = draftMode
        presetDurationSeconds = draftDuration
        AppPrefsWriter.savePreset(mode: draftMode, durationSeconds: draftDuration)
    }

    private func clearPreset() {
        presetMode = ""
        draftMode  = ""
        AppPrefsWriter.clearPreset()
    }
}

private struct PresetModeTab: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selected ? .white : textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(selected ? warmAmber : Color.clear)
                .cornerRadius(7)
        }
        .buttonStyle(.plain)
    }
}

// Custom iOS 16 styled toggle row
struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: warmAmber))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
}

