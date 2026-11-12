import AppKit

/*
 * The few app-level behaviours SwiftUI has no setting for. Used by HelperApp.
 * Keeps the helper running after its window is closed, so memos still arrive,
 * and hides the Dock icon at launch when the user asked for that in Settings.
 */
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        DockIcon.apply()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
