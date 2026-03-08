import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Folders")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: viewModel.openFolder) {
                    Image(systemName: "folder.badge.plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Open Folder")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Current folder path
            if let root = viewModel.rootFolder {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                        Text(root.lastPathComponent)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    if let parent = root.deletingLastPathComponent() as URL?,
                       parent.path != "/" {
                        Button(action: {
                            viewModel.navigateToFolder(parent)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.caption2)
                                Text("Parent Folder")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.secondaryBackground.opacity(0.5))
            }

            Divider()

            // File tree
            if let root = viewModel.fileSystemRoot {
                FileTreeView(item: root)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No folder open")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct FileTreeView: View {
    let item: FileSystemItem
    @EnvironmentObject var viewModel: FileBrowserViewModel
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.isDirectory {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 12)

                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)

                        Text(item.name)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .padding(.leading, 4)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                if isExpanded, let children = item.children {
                    ForEach(children) { child in
                        FileTreeView(item: child)
                            .padding(.leading, 16)
                    }
                }
            } else {
                Button(action: {
                    viewModel.selectFile(at: item.url)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)

                        Text(item.name)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .padding(.leading, 22)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 2)
            }
        }
    }
}
