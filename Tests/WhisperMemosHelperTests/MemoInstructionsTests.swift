import XCTest
@testable import WhisperMemosHelper

final class MemoInstructionsTests: XCTestCase {
    func testInstructionsGoAfterTheMemo() {
        let prompt = MemoInstructions.prompt(memo: "Fix the login bug.", instructions: "Open a pull request.\n")
        XCTAssertEqual(prompt, "Fix the login bug.\n\nOpen a pull request.")
    }

    func testEmptyInstructionsLeaveTheMemoAlone() {
        XCTAssertEqual(MemoInstructions.prompt(memo: "Fix the login bug.", instructions: "  \n"), "Fix the login bug.")
    }

    func testDefaultAsksForAWorktreeAndAPullRequest() {
        XCTAssertTrue(MemoInstructions.defaultText.contains("new git worktree"))
        XCTAssertTrue(MemoInstructions.defaultText.contains("open a pull request"))
    }
}
