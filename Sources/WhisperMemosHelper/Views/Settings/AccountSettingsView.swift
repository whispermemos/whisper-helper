import SwiftUI

/*
 * The Account tab of Settings: the Whisper Memos account this Mac is connected
 * to, "Disconnect this Mac", and this Mac's name at the bottom.
 */
struct AccountSettingsView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var pairing: PairingStore
    @EnvironmentObject private var connection: MailboxConnection
    @State private var isConfirmingDisconnect = false

    var body: some View {
        Form {
            if let email = pairing.email, pairing.isPaired {
                LabeledContent {
                    Button("Disconnect this Mac…") {
                        isConfirmingDisconnect = true
                    }
                } label: {
                    Text(email)
                    Text("Whisper Memos account")
                }
            } else {
                Text("Not connected")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .safeAreaInset(edge: .bottom) {
            Text(Config.macName)
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .confirmationDialog("Disconnect this Mac?", isPresented: $isConfirmingDisconnect) {
            Button("Disconnect", role: .destructive, action: disconnect)
        } message: {
            Text("Memos will no longer start Claude Code sessions on this Mac. To connect again, scan a new code with your iPhone.")
        }
    }

    private func disconnect() {
        Task {
            await connection.disconnect()
            // the main window shows the QR code again
            openWindow(id: HelperApp.mainWindowId)
        }
    }
}
