import SwiftUI

/*
 * The menu under the menu bar icon. Shows which account is connected and what
 * the helper last did (including the last error), and opens the main window and
 * Settings. It is the only way in when the Dock icon is hidden.
 */
struct MenuView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @EnvironmentObject private var pairing: PairingStore
    @EnvironmentObject private var connection: MailboxConnection
    @EnvironmentObject private var jobs: JobRunner

    var body: some View {
        Text(ConnectionStatus(pairing: pairing, connection: connection).text)

        if let lastEvent = jobs.lastEvent {
            Text(lastEvent)
        }

        Divider()

        Button("Open Whisper Memos Helper") {
            openWindow(id: HelperApp.mainWindowId)
            // with the Dock icon hidden the app is never frontmost, so bring it forward by hand
            NSApp.activate()
        }

        Button("Settings…") {
            openSettings()
            NSApp.activate()
        }
        .keyboardShortcut(",")

        Divider()

        Button("Quit Whisper Memos Helper") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
