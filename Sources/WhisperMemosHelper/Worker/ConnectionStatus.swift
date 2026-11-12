import Foundation

/*
 * Whether this Mac is paired and whether its line to the worker is open, as one
 * value with a plain sentence. Shown by ConnectionStatusBar and MenuView.
 */
enum ConnectionStatus {
    case notConnected
    case connecting
    case connected(email: String)

    @MainActor
    init(pairing: PairingStore, connection: MailboxConnection) {
        if let email = pairing.email, pairing.isPaired {
            self = connection.isOnline ? .connected(email: email) : .connecting
        } else {
            self = .notConnected
        }
    }

    var text: String {
        switch self {
        case .notConnected:
            "Not connected"
        case .connecting:
            "Connecting to Whisper Memos…"
        case .connected(let email):
            "Connected to \(email)"
        }
    }
}
