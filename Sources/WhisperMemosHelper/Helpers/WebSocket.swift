import Foundation

/*
 * Two shortcuts for the worker's WebSockets, where every message is text.
 * Used by PairingSocket and MailboxConnection.
 */
extension URLSessionWebSocketTask {
    func receiveText() async throws -> String {
        switch try await receive() {
        case .string(let text):
            return text
        case .data(let data):
            return String(decoding: data, as: UTF8.self)
        @unknown default:
            return ""
        }
    }

    func send(json message: some Encodable) async throws {
        let data = try JSONEncoder().encode(message)
        try await send(.string(String(decoding: data, as: UTF8.self)))
    }
}
