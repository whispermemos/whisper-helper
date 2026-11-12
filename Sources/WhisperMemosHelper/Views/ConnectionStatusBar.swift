import SwiftUI

/*
 * The bar at the bottom of the main window. On the left a coloured dot with the
 * connected account's email (green means the line to Whisper Memos is open), and
 * under it what the helper last did, including the last error. On the right a
 * button that opens Settings.
 */
struct ConnectionStatusBar: View {
    @EnvironmentObject private var pairing: PairingStore
    @EnvironmentObject private var connection: MailboxConnection
    @EnvironmentObject private var jobs: JobRunner

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let lastEvent = jobs.lastEvent {
                    Text(lastEvent)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .help(lastEvent)
                }
            }

            Spacer()

            SettingsLink {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
            .settingsButtonStyle()
            .help("Settings")
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .padding(.vertical, 8)
        .barBackground()
    }

    private var status: ConnectionStatus {
        ConnectionStatus(pairing: pairing, connection: connection)
    }

    // the green dot already says "connected", so the email stands alone
    private var text: String {
        if case .connected(let email) = status {
            return email
        }
        return status.text
    }

    private var dotColor: Color {
        switch status {
        case .notConnected:
            .secondary
        case .connecting:
            .orange
        case .connected:
            .green
        }
    }
}

private extension View {
    /// A round glass button where the system has glass, like the "+" in the toolbar.
    @ViewBuilder
    func settingsButtonStyle() -> some View {
        if #available(macOS 26, *) {
            buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
        } else {
            buttonStyle(.borderless)
        }
    }

    /// Newer systems blur the list under the bar by themselves. Older ones need a real bar.
    @ViewBuilder
    func barBackground() -> some View {
        if #available(macOS 26, *) {
            self
        } else {
            background(.bar)
                .overlay(alignment: .top) {
                    Divider()
                }
        }
    }
}
