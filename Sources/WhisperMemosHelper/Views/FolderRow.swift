import SwiftUI

/*
 * One folder in the main window's list: the name that is sent to Whisper Memos,
 * with its path underneath. Right-click to show it in Finder or remove it.
 */
struct FolderRow: View {
    let folder: URL
    let onRemove: () -> Void

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.lastPathComponent)
                    .fontWeight(.medium)

                Text((folder.deletingLastPathComponent().path as NSString).abbreviatingWithTildeInPath)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        } icon: {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Show in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([folder])
            }
            Divider()
            Button("Remove", role: .destructive, action: onRemove)
        }
    }
}

#Preview {
    List {
        FolderRow(folder: URL(fileURLWithPath: "/Users/me/Code/whisper-memos")) {}
        FolderRow(folder: URL(fileURLWithPath: "/Users/me/Code/growbase")) {}
    }
    .frame(width: 340)
}
