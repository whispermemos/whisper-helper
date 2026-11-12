import SwiftUI

/*
 * The main window: the folders this Mac offers to Whisper Memos. Shows nothing
 * until the Mac is paired, and puts the onboarding sheet on top of itself
 * whenever it is not. The connection status sits in a bar at the bottom.
 */
struct FolderListView: View {
    @EnvironmentObject private var pairing: PairingStore
    @EnvironmentObject private var folders: FoldersStore
    @State private var isOnboarding = false

    var body: some View {
        List(shownFolders, id: \.self) { folder in
            FolderRow(folder: folder) {
                folders.remove(folder)
            }
        }
        .overlay {
            emptyState
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ConnectionStatusBar()
        }
        .frame(minWidth: 340, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Folder", systemImage: "plus", action: addFolders)
                    .help("Add Folder")
                    .disabled(!pairing.isPaired)
            }
        }
        .sheet(isPresented: $isOnboarding) {
            OnboardingSheet()
        }
        .onChange(of: pairing.isPaired, initial: true) { _, isPaired in
            if !isPaired {
                isOnboarding = true
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if !pairing.isPaired {
            ContentUnavailableView(
                "Not Connected",
                systemImage: "macbook.and.iphone",
                description: Text("Connect this Mac to Whisper Memos to see your folders.")
            )
        } else if folders.folders.isEmpty {
            ContentUnavailableView {
                Label("No Folders", systemImage: "folder")
            } description: {
                Text("Add the folders Claude Code may work in. Only the folder names leave this Mac.")
            } actions: {
                Button("Add Folder…", action: addFolders)
            }
        }
    }

    // MARK: - Folders

    private var shownFolders: [URL] {
        pairing.isPaired ? folders.folders : []
    }

    private func addFolders() {
        FolderPanel.chooseFolders().forEach(folders.add)
    }
}
