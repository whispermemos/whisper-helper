import Foundation

/*
 * The JSON messages the helper and the worker send each other over WebSockets.
 * The shapes are the contract in docs/protocol.md; change both together.
 * Every message has a "type". Used by PairingSocket and MailboxConnection.
 */

// MARK: - Mac to worker

/// The names of the folders this Mac can start a session in. Names only, never paths.
struct FoldersMessage: Encodable {
    let type = "folders"
    let folders: [String]
}

/// Tells the worker a job arrived, so it is never sent again.
struct AckMessage: Encodable {
    let type = "ack"
    let jobId: String
}

/// Disconnects this Mac for good.
struct RemoveMessage: Encodable {
    let type = "remove"
}

// MARK: - Worker to Mac

/// A memo to start a Claude Code session for. `folder` is one of the names this Mac sent.
struct Job: Decodable, Equatable {
    let id: String
    let prompt: String
    let folder: String
    /// The memo's title, for naming the session. Nil when the memo has none.
    let title: String?
}

/// What the worker sends on the working socket.
enum MailboxMessage: Decodable, Equatable {
    case job(Job)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeKey.self)
        switch try container.decode(String.self, forKey: .type) {
        case "job":
            self = .job(try Job(from: decoder))
        default:
            throw unknownType(in: container)
        }
    }
}

/// The one message the pairing socket gets, after the user taps Allow or Deny on the phone.
enum PairingAnswer: Decodable, Equatable {
    case approved(key: String, email: String)
    case denied

    private enum CodingKeys: String, CodingKey {
        case key, email
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeKey.self)
        switch try container.decode(String.self, forKey: .type) {
        case "approved":
            let fields = try decoder.container(keyedBy: CodingKeys.self)
            self = .approved(
                key: try fields.decode(String.self, forKey: .key),
                email: try fields.decode(String.self, forKey: .email)
            )
        case "denied":
            self = .denied
        default:
            throw unknownType(in: container)
        }
    }
}

private enum TypeKey: String, CodingKey {
    case type
}

private func unknownType(in container: KeyedDecodingContainer<TypeKey>) -> DecodingError {
    DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown message type")
}
