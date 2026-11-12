import AppKit

/*
 * The standard open panel for picking the folders Claude Code may work in.
 * Used by the "+" button and empty state in FolderListView, and by
 * File > Add Folder in HelperApp.
 */
enum FolderPanel {
    /// Returns the picked folders, or nothing when the user cancelled.
    @MainActor
    static func chooseFolders() -> [URL] {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = true
        panel.prompt = "Add"
        panel.message = "Pick the folders Claude Code may work in."
        return panel.runModal() == .OK ? panel.urls : []
    }
}
