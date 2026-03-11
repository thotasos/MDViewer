import Foundation
import SwiftUI
import Combine

class FileBrowserViewModel: ObservableObject {
    @Published var rootFolder: URL?
    @Published var fileSystemRoot: FileSystemItem?
    @Published var markdownFiles: [MarkdownFile] = []
    @Published var selectedFile: MarkdownFile?
    @Published var selectedFolder: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showWelcome = true

    @Published var zoomLevel: CGFloat = 1.0 {
        didSet {
            AppSettings.shared.zoomLevel = zoomLevel
        }
    }

    @Published var sidebarCollapsed: Bool = false {
        didSet {
            AppSettings.shared.sidebarCollapsed = sidebarCollapsed
        }
    }

    @Published var fileListCollapsed: Bool = false {
        didSet {
            AppSettings.shared.fileListCollapsed = fileListCollapsed
        }
    }

    @Published var outlineCollapsed: Bool = false {
        didSet {
            AppSettings.shared.outlineCollapsed = outlineCollapsed
        }
    }

    private let settings = AppSettings.shared

    init() {
        self.zoomLevel = settings.zoomLevel
        self.sidebarCollapsed = settings.sidebarCollapsed
        self.fileListCollapsed = settings.fileListCollapsed
        self.outlineCollapsed = settings.outlineCollapsed

        if let lastFolder = settings.lastOpenedFolder {
            openFolder(lastFolder)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenFolder(_:)),
            name: .openFolder,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenFile(_:)),
            name: .openFile,
            object: nil
        )
    }

    @objc private func handleOpenFolder(_ notification: Notification) {
        if let url = notification.object as? URL {
            openFolder(url)
        }
    }

    @objc private func handleOpenFile(_ notification: Notification) {
        if let url = notification.object as? URL {
            let folder = url.deletingLastPathComponent()
            openFolder(folder)
            selectFile(at: url)
        }
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.init(filenameExtension: "md")!]
        panel.message = "Select a markdown file to open"
        panel.prompt = "Open"

        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.openSingleFile(url)
            }
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder containing markdown files"
        panel.prompt = "Open"

        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.openFolder(url)
            }
        }
    }

    private func openSingleFile(_ url: URL) {
        let folder = url.deletingLastPathComponent()
        openFolder(folder)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.selectFile(at: url)
        }
    }

    func openFolder(_ url: URL) {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fileSystemItem = FileSystemItem(url: url)
            let files = self?.scanForMarkdownFiles(in: url) ?? []

            DispatchQueue.main.async {
                self?.rootFolder = url
                self?.fileSystemRoot = fileSystemItem
                self?.selectedFolder = url
                self?.markdownFiles = files
                self?.settings.lastOpenedFolder = url
                self?.showWelcome = false
                self?.isLoading = false

                if let firstFile = files.first {
                    self?.selectedFile = firstFile
                }
            }
        }
    }

    private func scanForMarkdownFiles(in folder: URL) -> [MarkdownFile] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return contents
            .filter { $0.pathExtension.lowercased() == "md" }
            .map { MarkdownFile(url: $0) }
            .sorted { ($0.modificationDate ?? .distantPast) > ($1.modificationDate ?? .distantPast) }
    }

    func selectFile(_ file: MarkdownFile) {
        selectedFile = file
    }

    func selectFile(at url: URL) {
        if let file = markdownFiles.first(where: { $0.url == url }) {
            selectedFile = file
        }
    }

    func zoomIn() {
        zoomLevel = min(zoomLevel + 0.1, 3.0)
    }

    func zoomOut() {
        zoomLevel = max(zoomLevel - 0.1, 0.5)
    }

    func resetZoom() {
        zoomLevel = 1.0
    }

    func navigateToFolder(_ url: URL) {
        openFolder(url)
    }
}
