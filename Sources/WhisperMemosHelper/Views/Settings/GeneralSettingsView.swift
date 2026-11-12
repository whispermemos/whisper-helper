import SwiftUI

/*
 * The General tab of Settings: start at login and hide the Dock icon.
 */
struct GeneralSettingsView: View {
    @AppStorage(DefaultsKey.isDockIconHidden) private var isDockIconHidden = false
    @State private var isStartingAtLogin = LoginItem.isEnabled

    var body: some View {
        Form {
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
        .formStyle(.grouped)
    }
}
