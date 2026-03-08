import Foundation

struct MarkdownFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let modificationDate: Date?
    let fileSize: Int64

    var formattedDate: String {
        guard let date = modificationDate else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    init(url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent

        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        self.modificationDate = attributes?[.modificationDate] as? Date
        self.fileSize = attributes?[.size] as? Int64 ?? 0
    }
}

struct FileSystemItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    var children: [FileSystemItem]?

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.isDirectory = url.hasDirectoryPath

        if isDirectory {
            var items: [FileSystemItem] = []
            if let contents = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                items = contents
                    .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
                    .map { FileSystemItem(url: $0) }
                    .filter { $0.isDirectory || $0.url.pathExtension.lowercased() == "md" }
            }
            self.children = items.isEmpty ? nil : items
        }
    }
}
