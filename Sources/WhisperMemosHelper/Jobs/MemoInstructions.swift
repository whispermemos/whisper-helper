import Foundation

/*
 * The instructions the helper adds after every memo before handing it to Claude Code.
 * By default they ask for a worktree and a pull request when the folder is a git
 * repository, and for direct changes when it is not, unless the memo says otherwise.
 * The user can rewrite them in
 * Settings. Used by JobRunner and InstructionsSettingsView.
 */
enum MemoInstructions {
    static let defaultText = """
        If this folder is a git repository, work in a new git worktree on its own branch. \
        When the change is done, commit it, push the branch and open a pull request.

        If it is not a git repository, make the changes directly in the folder.

        The memo above always comes first. If it asks for something else, for example \
        no pull request, do what the memo says.
        """

    /// What the user saved in Settings, or the default when they never changed it.
    static var current: String {
        UserDefaults.standard.string(forKey: DefaultsKey.memoInstructions) ?? defaultText
    }

    /// The memo with the instructions after it. Empty instructions leave the memo as it is.
    static func prompt(memo: String, instructions: String) -> String {
        let trimmed = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return memo
        }
        return "\(memo)\n\n\(trimmed)"
    }
}
