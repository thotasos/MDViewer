import SwiftUI

struct FileListView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Documents")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(viewModel.markdownFiles.count) files")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // File list
            if viewModel.markdownFiles.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)

                    Text("No markdown files found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Open Another Folder") {
                        viewModel.openFolder()
                    }
                    .buttonStyle(.link)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(viewModel.markdownFiles) { file in
                            FileRowView(
                                file: file,
                                isSelected: viewModel.selectedFile?.id == file.id
                            )
                            .onTapGesture {
                                viewModel.selectFile(file)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct FileRowView: View {
    let file: MarkdownFile
    let isSelected: Bool
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            // File icon
            Image(systemName: "doc.richtext")
                .font(.title3)
                .foregroundStyle(isSelected ? .white : .blue)
                .frame(width: 24)

            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .white : .primary)

                HStack(spacing: 8) {
                    if let date = file.modificationDate {
                        Text(date.relativeString)
                            .font(.caption)
                            .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    }

                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
        .padding(.horizontal, 8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor
        } else if isHovering {
            return Color.secondary.opacity(0.1)
        }
        return .clear
    }
}
