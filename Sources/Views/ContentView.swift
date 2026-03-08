import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel

    var body: some View {
        Group {
            if viewModel.showWelcome {
                WelcomeView()
            } else {
                HSplitView {
                    // Sidebar
                    if !viewModel.sidebarCollapsed {
                        SidebarView()
                            .frame(minWidth: 180, idealWidth: 220, maxWidth: 300)
                    }

                    // File List
                    FileListView()
                        .frame(minWidth: 200, idealWidth: 280, maxWidth: 400)

                    // Preview
                    PreviewView()
                        .frame(minWidth: 400)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.sidebarCollapsed.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
            }

            ToolbarItemGroup(placement: .principal) {
                if let folder = viewModel.rootFolder {
                    Text(folder.lastPathComponent)
                        .font(.headline)
                        .lineLimit(1)
                }
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: viewModel.openFolder) {
                    Image(systemName: "folder")
                }
                .help("Open Folder")

                Divider()

                Button(action: viewModel.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .help("Zoom Out")

                Text("\(Int(viewModel.zoomLevel * 100))%")
                    .font(.caption)
                    .frame(width: 45)

                Button(action: viewModel.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .help("Zoom In")

                Button(action: viewModel.resetZoom) {
                    Image(systemName: "1.magnifyingglass")
                }
                .help("Actual Size")
            }
        }
    }
}
