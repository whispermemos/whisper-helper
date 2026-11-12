import Foundation

/*
 * Runs a command through the user's login shell and collects its output.
 * A Mac app started from Finder has a bare PATH, so `claude`, `git` and the tools
 * a session needs are only found when the command goes through the shell the user
 * set up (zsh or bash). Used by ClaudeLauncher.
 */
struct ShellResult {
    let exitCode: Int32
    let output: String
}

enum Shell {
    /// `command` sees `arguments` as "$1", "$2"... so no value is ever pasted into shell code.
    static func runInLoginShell(
        _ command: String,
        arguments: [String],
        directory: URL
    ) async throws -> ShellResult {
        let process = Process()
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        process.executableURL = URL(fileURLWithPath: shellPath)
        process.arguments = ["-lic", command, "whisper-memos-helper"] + arguments
        process.currentDirectoryURL = directory
        process.standardInput = FileHandle.nullDevice

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        // reading and waiting block, so keep them off the main thread
        return try await Task.detached {
            try process.run()
            let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
            process.waitUntilExit()
            return ShellResult(
                exitCode: process.terminationStatus,
                output: String(decoding: data, as: UTF8.self)
            )
        }.value
    }
}
