import SwiftUI

/*
 * The General tab of Settings: start at login, hide the Dock icon, and updates
 * (the current version, automatic checks and installs, and a manual check).
 */
struct GeneralSettingsView: View {
    @EnvironmentObject private var updates: UpdateManager
    @AppStorage(DefaultsKey.isDockIconHidden) private var isDockIconHidden = false
    @State private var isStartingAtLogin = LoginItem.isEnabled

    var body: some View {
        Form {
            Section {
                Toggle("Start at login", isOn: $isStartingAtLogin)
                    .onChange(of: isStartingAtLogin) { _, wantsStartAtLogin in
                        LoginItem.setEnabled(wantsStartAtLogin)
                        // registering fails for a bare binary; show the real state
                        isStartingAtLogin = LoginItem.isEnabled
                    }

                Toggle(isOn: $isDockIconHidden) {
                    Text("Hide Dock icon")
                    Text("Open the window from the Whisper Memos icon in the menu bar.")
                }
                .onChange(of: isDockIconHidden) {
                    DockIcon.apply()
                    // changing the Dock icon sends the app to the back; stay in front
                    NSApp.activate()
                }
            }

            Section {
                Toggle("Automatically check for updates", isOn: Binding(
                    get: { updates.wantsAutomaticChecks }, set: { updates.setAutomaticChecks($0) }
                ))

                Toggle("Automatically download and install updates", isOn: Binding(
                    get: { updates.wantsAutomaticUpdates }, set: { updates.setAutomaticUpdates($0) }
                ))
                .disabled(!updates.wantsAutomaticChecks)

                LabeledContent {
                    CheckForUpdatesButton(updates: updates)
                } label: {
                    Text("Version \(UpdateManager.version)")
                    if !updates.isEnabled {
                        Text("Updates are off in development builds.")
                    }
                }
            }
            .disabled(!updates.isEnabled)
        }
        .formStyle(.grouped)
    }
}
