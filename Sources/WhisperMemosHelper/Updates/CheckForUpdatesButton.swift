import SwiftUI

/*
 * The "Check for Updates…" action, shared by the app menu, the menu bar menu and
 * Settings. Says "Update Available…" once Sparkle has found one.
 */
struct CheckForUpdatesButton: View {
    @ObservedObject var updates: UpdateManager

    var body: some View {
        Button(updates.hasUpdateAvailable ? "Update Available…" : "Check for Updates…") {
            updates.checkForUpdates()
            // with the Dock icon hidden the app is never frontmost, so bring it forward by hand
            NSApp.activate()
        }
        .disabled(!updates.canCheckForUpdates)
    }
}
