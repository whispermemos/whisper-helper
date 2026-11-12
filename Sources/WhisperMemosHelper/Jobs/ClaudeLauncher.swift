import Foundation

/*
 * Starts a Claude Code session for a memo and opens it in the Claude desktop app.
 * `claude --desktop` cannot take a prompt, so this takes two steps: run the first
 * turn with no window, then hand that session to the desktop app. The session starts
 * in the folder itself with permissions bypassed. Whether it then moves to a git
 * worktree is up to the instructions added to the memo (see MemoInstructions).
 * Used by JobRunner. What we learned about the `claude` command is in the README.
 */
enum ClaudeLauncher {
    static func launch(prompt: String, title: String?, in folder: URL) async throws {
        // claude only takes lowercase session ids
        let sessionId = UUID().uuidString.lowercased()

        // --name is what the desktop app shows for the session
        try await run(
            "exec claude -p \"$1\" --session-id \"$2\" --permission-mode bypassPermissions --name \"$3\"",
            arguments: [prompt, sessionId, title ?? "Memo"],
            in: folder
        )

        // --desktop refuses to run without a terminal, so `script` fakes one
        try await run(
            "exec script -q /dev/null claude --desktop --resume \"$1\"",
            arguments: [sessionId],
            in: folder
        )
    }

    private static func run(_ command: String, arguments: [String], in directory: URL) async throws {
        let result = try await Shell.runInLoginShell(command, arguments: arguments, directory: directory)
        if result.exitCode != 0 {
            // the last line is where claude says what went wrong
            let lastLine = result.output
                .split(separator: "\n")
                .last
                .map(String.init) ?? "exit code \(result.exitCode)"
            throw HelperError(message: lastLine)
        }
    }
}
