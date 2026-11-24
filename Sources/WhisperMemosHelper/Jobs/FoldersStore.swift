import Foundation
import os

/*
 * The folders Claude Code may work in, saved in UserDefaults. FolderListView edits the
 * list. MailboxConnection sends the folder names to the worker, which picks one per
 * memo, and JobRunner finds the folder by that name. A folder is used as it is:
 * nothing looks inside it. Each folder is marked trusted in Claude Code (ClaudeTrust),
 * since a background session won't start in an untrusted one.
 */
@MainActor
final class FoldersStore: ObservableObject {
    @Published private(set) var folders: [URL]

    private let logger = Logger(subsystem: "tech.median.Whisper.Helper", category: "folders")

    // MARK: - Lifecycle

    init() {
        let paths = UserDefaults.standard.stringArray(forKey: DefaultsKey.folders) ?? []
        folders = paths.map { URL(fileURLWithPath: $0) }
        // folders added before the helper trusted them
        trust(folders)
    }

    // MARK: - Reading

    /// The worker knows a folder only by its name, e.g. "whisper-memos".
    var names: [String] {
        folders.map(\.lastPathComponent)
    }

    func folder(named name: String) -> URL? {
        folders.first { $0.lastPathComponent == name }
    }

    // MARK: - Editing

    /// A folder whose name is already in the list is skipped, since names must be unique.
    func add(_ folder: URL) {
        if self.folder(named: folder.lastPathComponent) != nil {
            return
        }
        folders.append(folder)
        save()
        trust([folder])
    }

    func remove(_ folder: URL) {
        folders.removeAll { $0 == folder }
        save()
    }

    // A failure only means the first memo there may fail to start, so it is logged, not shown.
    private func trust(_ folders: [URL]) {
        do {
            try ClaudeTrust.trust(folders)
        } catch {
            logger.error("Could not trust folders: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func save() {
        UserDefaults.standard.set(folders.map(\.path), forKey: DefaultsKey.folders)
    }
}
