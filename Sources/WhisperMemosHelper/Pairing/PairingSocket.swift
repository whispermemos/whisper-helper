import Foundation

/*
 * The Mac's side of pairing by QR code. Used by OnboardingPairingStep.
 * The helper makes up a secret code, shows it as a QR link, and holds a WebSocket
 * open on that code. When the user taps Allow in the iOS app, the worker sends
 * the key for this Mac down the socket. A code lives for five minutes.
 */
enum PairingSocket {
    private static let expiredCloseCode = 4000

    /// 32 random bytes as base64url with no padding.
    static func makeCode() -> String {
        let bytes = (0..<32).map { _ in UInt8.random(in: .min ... .max) }
        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// The link inside the QR code. The iPhone camera opens it in Whisper Memos.
    static func connectUrl(code: String) -> String {
        "\(Config.connectPageUrl)?code=\(code)"
    }

    /// Waits for the phone's decision. Returns nil when the five minutes ran out.
    /// Throws when the worker cannot be reached.
    static func waitForAnswer(code: String) async throws -> PairingAnswer? {
        let socket = URLSession.shared.webSocketTask(with: Config.socketUrl(
            path: "/api/pairings/\(code)/socket",
            query: [URLQueryItem(name: "name", value: Config.macName)]
        ))
        socket.resume()
        defer { socket.cancel() }

        do {
            // closing the socket is what stops the wait when the QR code leaves the screen
            let text = try await withTaskCancellationHandler {
                try await socket.receiveText()
            } onCancel: {
                socket.cancel()
            }
            return try JSONDecoder().decode(PairingAnswer.self, from: Data(text.utf8))
        } catch {
            if socket.closeCode.rawValue == expiredCloseCode {
                return nil
            }
            throw error
        }
    }
}
