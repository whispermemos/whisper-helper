import AppKit

/*
 * Starts a Claude Code session for a memo and opens it in the Claude desktop app.
 * `claude --desktop` cannot take a prompt, so there are two ways, picked in Settings
 * (see LaunchMode). After the first turn: run the first turn with no window, then hand
 * that session to the desktop app. Remote Control: start the session in the background
 * with Remote Control on, read its claude.ai link from its screen, and open that link
 * in the desktop app. Either way the session starts in the folder itself with
 * permissions bypassed. Used by JobRunner. What we learned about the `claude` command
 * is in the README.
 */
enum ClaudeLauncher {
    // the Remote Control link shows up a few seconds after the session starts
    private static let linkAttempts = 20

    static func launch(prompt: String, title: String?, in folder: URL, mode: LaunchMode) async throws {
        // --name is what the desktop app shows for the session
        let name = title ?? "Memo"
        switch mode {
        case .afterFirstTurn:
            try await launchAfterFirstTurn(prompt: prompt, name: name, in: folder)
        case .remoteControl:
            try await launchWithRemoteControl(prompt: prompt, name: name, in: folder)
        }
    }

    // MARK: - After the first turn

    private static func launchAfterFirstTurn(prompt: String, name: String, in folder: URL) async throws {
        // claude only takes lowercase session ids
        let sessionId = UUID().uuidString.lowercased()

        try await run(
            "exec claude -p \"$1\" --session-id \"$2\" --permission-mode bypassPermissions --name \"$3\"",
            arguments: [prompt, sessionId, name],
            in: folder
        )

        // --desktop refuses to run without a terminal, so `script` fakes one
        try await run(
            "exec script -q /dev/null claude --desktop --resume \"$1\"",
            arguments: [sessionId],
            in: folder
        )
    }

    // MARK: - Remote Control

    private static func launchWithRemoteControl(prompt: String, name: String, in folder: URL) async throws {
        // --bg returns at once; --bg ignores --session-id, so the id comes from what it prints
        let started = try await run(
            "exec claude --bg --remote-control \"$2\" --name \"$2\" --permission-mode bypassPermissions \"$1\"",
            arguments: [prompt, name],
            in: folder
        )
        guard let backgroundId = backgroundId(in: started) else {
            throw HelperError(message: "Claude did not say which background session it started")
        }

        for _ in 0..<linkAttempts {
            let screen = try await run("exec claude logs \"$1\"", arguments: [backgroundId], in: folder)
            if let link = remoteControlLink(in: screen), let url = URL(string: "claude://\(link)") {
                NSWorkspace.shared.open(url)
                return
            }
            try await Task.sleep(for: .seconds(1))
        }
        throw HelperError(message: "Started in the background, but Remote Control gave no link. Open it with claude attach \(backgroundId)")
    }

    /// The short id in "backgrounded · 90709edd · Memo".
    static func backgroundId(in output: String) -> String? {
        let pattern = try! Regex(#"backgrounded\W+([0-9a-f]+)"#)
        return output.firstMatch(of: pattern)?[1].substring.map(String.init)
    }

    /// The "claude.ai/code/session_…" link a Remote Control session shows on its screen.
    static func remoteControlLink(in screen: String) -> String? {
        let pattern = try! Regex(#"claude\.ai/code/session_[A-Za-z0-9]+"#)
        return screen.firstMatch(of: pattern).map { String(screen[$0.range]) }
    }

    // MARK: - Shell

    @discardableResult
    private static func run(_ command: String, arguments: [String], in directory: URL) async throws -> String {
        let result = try await Shell.runInLoginShell(command, arguments: arguments, directory: directory)
        if result.exitCode != 0 {
            // the last line is where claude says what went wrong
            let lastLine = result.output
                .split(separator: "\n")
                .last
                .map(String.init) ?? "exit code \(result.exitCode)"
            throw HelperError(message: lastLine)
        }
        return result.output
    }
}
