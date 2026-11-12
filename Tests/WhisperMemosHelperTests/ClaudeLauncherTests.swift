import XCTest
@testable import WhisperMemosHelper

final class ClaudeLauncherTests: XCTestCase {
    func testReadsTheBackgroundIdFromWhatClaudePrints() {
        let output = "Starting background service…\nbackgrounded · 90709edd · RC live test\n  claude agents  list sessions\n"
        XCTAssertEqual(ClaudeLauncher.backgroundId(in: output), "90709edd")
    }

    func testFindsTheRemoteControlLinkOnTheScreen() {
        let screen = "\u{1B}[38;2;153;153;153mclaude.ai/code/session_017GjiKhuaJ8j3wmhJvHYAA9\u{1B}[39m✽ Thinking…"
        XCTAssertEqual(ClaudeLauncher.remoteControlLink(in: screen), "claude.ai/code/session_017GjiKhuaJ8j3wmhJvHYAA9")
    }

    func testNoLinkBeforeRemoteControlConnects() {
        XCTAssertNil(ClaudeLauncher.remoteControlLink(in: "Claude Code v2.1.322\n❯ Fix the login bug."))
    }
}
