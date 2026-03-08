import SwiftUI

@main
struct MDViewerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var fileBrowserViewModel = FileBrowserViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fileBrowserViewModel)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open File...") {
                    fileBrowserViewModel.openFile()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])

                Button("Open Folder...") {
                    fileBrowserViewModel.openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button("Zoom In") {
                    fileBrowserViewModel.zoomIn()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    fileBrowserViewModel.zoomOut()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Actual Size") {
                    fileBrowserViewModel.resetZoom()
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}
