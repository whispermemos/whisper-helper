import Foundation

/*
 * Marks the helper's folders as trusted in Claude Code. A background session
 * (`claude --bg`) refuses to start in a folder whose "Do you trust this folder?"
 * prompt was never accepted, and the memo is lost. Adding a folder to the helper
 * already says Claude may work there, so FoldersStore trusts each folder when it is
 * added, and all of them at launch. This sets the same flag the prompt sets,
 * projects["<path>"].hasTrustDialogAccepted in ~/.claude.json, and leaves the rest of
 * that file alone. Claude Code writes the file too, so it is only written when a
 * folder is not trusted yet.
 */
enum ClaudeTrust {
    static let defaultConfigFile = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".claude.json")

    static func trust(_ folders: [URL], configFile: URL = defaultConfigFile) throws {
        // no file means Claude Code was never run here; it makes the file itself
        guard FileManager.default.fileExists(atPath: configFile.path) else {
            return
        }

        guard var config = try JSONSerialization.jsonObject(with: Data(contentsOf: configFile)) as? [String: Any] else {
            throw HelperError(message: "\(configFile.path) is not a JSON object")
        }

        var projects = config["projects"] as? [String: Any] ?? [:]
        let untrusted = folders.map(\.path).filter { path in
            (projects[path] as? [String: Any])?["hasTrustDialogAccepted"] as? Bool != true
        }
        guard !untrusted.isEmpty else {
            return
        }

        for path in untrusted {
            var project = projects[path] as? [String: Any] ?? [:]
            project["hasTrustDialogAccepted"] = true
            projects[path] = project
        }
        config["projects"] = projects

        let data = try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: configFile, options: .atomic)
    }
}
