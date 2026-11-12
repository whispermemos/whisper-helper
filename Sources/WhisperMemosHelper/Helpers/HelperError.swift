import Foundation

/*
 * An error that carries one plain sentence, shown in the menu as is.
 * Used by ClaudeLauncher to pass on what `claude` said went wrong.
 */
struct HelperError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
