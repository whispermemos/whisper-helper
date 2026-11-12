import Foundation

/*
 * Every UserDefaults key the helper uses, so no file reaches for a raw string.
 */
enum DefaultsKey {
    static let email = "email"
    static let folders = "folders"
    static let isDockIconHidden = "isDockIconHidden"
    static let launchMode = "launchMode"
    static let memoInstructions = "memoInstructions"
}
