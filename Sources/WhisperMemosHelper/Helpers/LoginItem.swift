import ServiceManagement

/*
 * Starts the helper when the user logs in to the Mac. Used by SettingsView.
 * Only works from the built .app; registering fails for a bare binary.
 */
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ isEnabled: Bool) {
        if isEnabled {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
    }
}
