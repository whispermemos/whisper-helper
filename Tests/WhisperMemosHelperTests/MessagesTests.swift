import XCTest
@testable import WhisperMemosHelper

/*
 * Checks that the WebSocket messages match the JSON written down in
 * docs/protocol.md, in both directions.
 */
final class MessagesTests: XCTestCase {
    func testMacMessagesEncode() throws {
        XCTAssertEqual(
            try json(FoldersMessage(folders: ["whisper-memos", "growbase"])),
            ["type": "folders", "folders": ["whisper-memos", "growbase"]]
        )
        XCTAssertEqual(try json(AckMessage(jobId: "memo1")), ["type": "ack", "jobId": "memo1"])
        XCTAssertEqual(try json(RemoveMessage()), ["type": "remove"])
    }

    func testJobDecodes() throws {
        let message: MailboxMessage = try decode(
            #"{"type":"job","id":"memo1","prompt":"Fix the login bug","folder":"whisper-memos"}"#
        )
        XCTAssertEqual(message, .job(Job(id: "memo1", prompt: "Fix the login bug", folder: "whisper-memos", title: nil)))
    }

    func testPairingAnswersDecode() throws {
        XCTAssertEqual(
            try decode(#"{"type":"approved","key":"user.mac.secret","email":"me@example.com"}"#),
            PairingAnswer.approved(key: "user.mac.secret", email: "me@example.com")
        )
        XCTAssertEqual(try decode(#"{"type":"denied"}"#), PairingAnswer.denied)
    }

    func testUnknownTypeIsRejected() {
        XCTAssertThrowsError(try decode(#"{"type":"hello"}"#) as MailboxMessage)
        XCTAssertThrowsError(try decode(#"{"type":"hello"}"#) as PairingAnswer)
    }

    func testPairingCodeIsBase64UrlOf32Bytes() {
        let code = PairingSocket.makeCode()

        // 32 bytes are 43 base64 characters once the padding is gone
        XCTAssertEqual(code.count, 43)
        XCTAssertNil(code.rangeOfCharacter(from: CharacterSet(charactersIn: "+/=")))
        XCTAssertNotEqual(code, PairingSocket.makeCode())
    }

    private func json(_ message: some Encodable) throws -> NSDictionary {
        let data = try JSONEncoder().encode(message)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? NSDictionary)
    }

    private func decode<Message: Decodable>(_ text: String) throws -> Message {
        try JSONDecoder().decode(Message.self, from: Data(text.utf8))
    }
}
