import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Icon
            Image(systemName: "doc.richtext")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            // Title
            VStack(spacing: 8) {
                Text("MDViewer")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Text("A beautiful way to view Markdown files")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Open Folder Button
            Button(action: viewModel.openFolder) {
                HStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.title3)
                    Text("Open Folder")
                        .font(.headline)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(isHovering ? Color.accentColor.opacity(0.9) : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovering = hovering
                }
            }

            // Keyboard shortcut hint
            Text("or press ⌘O")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "eye", title: "Beautiful Rendering", description: "View markdown with elegant typography")
                FeatureRow(icon: "doc.text", title: "Syntax Highlighting", description: "Code blocks are beautifully highlighted")
                FeatureRow(icon: "moon.fill", title: "Dark Mode", description: "Automatic support for light and dark themes")
            }
            .padding(24)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .frame(maxWidth: 400)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
