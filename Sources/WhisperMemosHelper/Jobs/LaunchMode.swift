import Foundation

/*
 * How a memo's session gets into the Claude desktop app, picked in Settings > Sessions.
 * Either the app opens it once Claude's first turn is done, or it opens right away as a
 * Remote Control session you can watch live. Used by JobRunner, ClaudeLauncher and
 * SessionsSettingsView.
 */
enum LaunchMode: String, CaseIterable, Identifiable {
    case afterFirstTurn
    case remoteControl

    var id: String { rawValue }

    /// What the user picked in Settings, or opening after the first turn when they never picked.
    static var current: LaunchMode {
        UserDefaults.standard.string(forKey: DefaultsKey.launchMode).flatMap(LaunchMode.init) ?? .afterFirstTurn
    }

    var title: String {
        switch self {
        case .afterFirstTurn: "Open when the first answer is ready"
        case .remoteControl: "Open right away with Remote Control"
        }
    }

    var explanation: String {
        switch self {
        case .afterFirstTurn:
            "Claude works on the memo out of sight. When its first turn is done, the session opens in the Claude app with the result, next to your other sessions. This can take a few minutes."
        case .remoteControl:
            "Claude works on the memo in the background. The session opens in the Claude app within seconds, and you watch Claude work live. It shows under Remote Control at the bottom of the sidebar. Needs Remote Control to be available on your Claude account."
        }
    }
}
