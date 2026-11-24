import XCTest
@testable import WhisperMemosHelper

final class ClaudeTrustTests: XCTestCase {
    private var configFile: URL!

    override func setUpWithError() throws {
        configFile = FileManager.default.temporaryDirectory.appending(path: "claude-\(UUID().uuidString).json")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: configFile)
    }

    private func readConfig() throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: configFile)) as? [String: Any])
    }

    func testTrustsANewFolderAndKeepsTheRestOfTheFile() throws {
        try #"{"numStartups": 3, "projects": {"/code/app": {"allowedTools": ["Bash"]}}}"#.write(to: configFile, atomically: true, encoding: .utf8)

        try ClaudeTrust.trust([URL(fileURLWithPath: "/code/app"), URL(fileURLWithPath: "/code/ignite")], configFile: configFile)

        let config = try readConfig()
        let projects = try XCTUnwrap(config["projects"] as? [String: [String: Any]])
        XCTAssertEqual(config["numStartups"] as? Int, 3)
        XCTAssertEqual(projects["/code/app"]?["allowedTools"] as? [String], ["Bash"])
        XCTAssertEqual(projects["/code/app"]?["hasTrustDialogAccepted"] as? Bool, true)
        XCTAssertEqual(projects["/code/ignite"]?["hasTrustDialogAccepted"] as? Bool, true)
    }

    func testLeavesTheFileUntouchedWhenEveryFolderIsTrusted() throws {
        let original = #"{"projects":{"/code/app":{"hasTrustDialogAccepted":true}}}"#
        try original.write(to: configFile, atomically: true, encoding: .utf8)

        try ClaudeTrust.trust([URL(fileURLWithPath: "/code/app")], configFile: configFile)

        XCTAssertEqual(try String(contentsOf: configFile, encoding: .utf8), original)
    }

    func testDoesNotCreateTheFileWhenClaudeNeverRan() throws {
        try ClaudeTrust.trust([URL(fileURLWithPath: "/code/app")], configFile: configFile)

        XCTAssertFalse(FileManager.default.fileExists(atPath: configFile.path))
    }
}
