import SwiftUI

/*
 * Entry point of the Whisper Memos Helper. It creates the long-lived
 * objects (pairing, folders, job runner, worker connection, updates) and shows three
 * things: the main window with the list of folders, the Settings window,
 * and a menu bar item. The app keeps running when the window is closed.
 */
@main
struct HelperApp: App {
    static let mainWindowId = "main"

    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var pairing: PairingStore
    @StateObject private var folders: FoldersStore
    @StateObject private var jobs: JobRunner
    @StateObject private var connection: MailboxConnection
    @StateObject private var updates: UpdateManager
    @AppStorage(DefaultsKey.isDockIconHidden) private var isDockIconHidden = false

    init() {
        let pairing = PairingStore()
        let folders = FoldersStore()
        let jobs = JobRunner(folders: folders)
        let connection = MailboxConnection(pairing: pairing, folders: folders, jobs: jobs)

        _pairing = StateObject(wrappedValue: pairing)
        _folders = StateObject(wrappedValue: folders)
        _jobs = StateObject(wrappedValue: jobs)
        _connection = StateObject(wrappedValue: connection)

        let updates = UpdateManager()
        updates.start()
        _updates = StateObject(wrappedValue: updates)
    }

    var body: some Scene {
        Window("Whisper Memos Helper", id: Self.mainWindowId) {
            FolderListView()
                .environmentObject(pairing)
                .environmentObject(folders)
                .environmentObject(connection)
                .environmentObject(jobs)
        }
        .defaultSize(width: 500, height: 560)
        .windowResizability(.contentMinSize)
        .keyboardShortcut("0")
        // with the Dock icon hidden the helper starts quietly, like a menu bar app
        .defaultLaunchBehavior(isDockIconHidden && pairing.isPaired ? .suppressed : .presented)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesButton(updates: updates)
            }
            CommandGroup(replacing: .newItem) {
                Button("Add Folder…") {
                    FolderPanel.chooseFolders().forEach(folders.add)
                }
                .keyboardShortcut("n")
                .disabled(!pairing.isPaired)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(pairing)
                .environmentObject(connection)
                .environmentObject(updates)
        }

        MenuBarExtra("Whisper Memos Helper", systemImage: "waveform") {
            MenuView()
                .environmentObject(pairing)
                .environmentObject(connection)
                .environmentObject(jobs)
                .environmentObject(updates)
        }
    }
}
