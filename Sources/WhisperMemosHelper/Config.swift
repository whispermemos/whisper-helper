import Foundation

/*
 * Addresses and timings for talking to the Claude Code worker.
 * Used by PairingSocket and MailboxConnection. Setting WHISPER_MEMOS_WORKER_URL
 * (e.g. http://localhost:8787) points the helper at a local `wrangler dev`.
 */
enum Config {
    static let workerUrl = URL(
        string: ProcessInfo.processInfo.environment["WHISPER_MEMOS_WORKER_URL"]
            ?? "https://claude-code-workers.whispermemos.com"
    )!

    // the page the QR code opens on the phone
    static let connectPageUrl = "https://app.whispermemos.com/claude-code/connect"

    static let pingInterval: Duration = .seconds(30)
    static let maxReconnectDelay = 60

    /// The name this Mac has in System Settings, e.g. "Anna's MacBook Pro".
    /// It is what the iPhone app shows for this Mac.
    static var macName: String {
        Host.current().localizedName ?? "Mac"
    }

    /// The worker's address for a WebSocket: https becomes wss, http becomes ws.
    static func socketUrl(path: String, query: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents(url: workerUrl, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "http" ? "ws" : "wss"
        components.path = path
        components.queryItems = query
        return components.url!
    }
}
