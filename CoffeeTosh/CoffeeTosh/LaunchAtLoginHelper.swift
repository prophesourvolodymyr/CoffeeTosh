import ServiceManagement

/// Thin wrapper around SMAppService so both SettingsView and DashboardSettingsView
/// can toggle Launch at Login with a single call.
enum LaunchAtLoginHelper {

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[LaunchAtLogin] \(enabled ? "register" : "unregister") failed: \(error)")
        }
    }
}
