import AppKit

/*
 * Shows or hides the helper's Dock icon, following the "Hide Dock icon" setting.
 * Used by AppDelegate at launch and by SettingsView when the toggle changes.
 * With the icon hidden the app has no menu bar of its own either; the waveform
 * icon in the menu bar is the way back to the window.
 */
enum DockIcon {
    @MainActor
    static func apply() {
        let isHidden = UserDefaults.standard.bool(forKey: DefaultsKey.isDockIconHidden)
        NSApp.setActivationPolicy(isHidden ? .accessory : .regular)
    }
}
