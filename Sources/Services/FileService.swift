import Foundation

class FileService {
    static let shared = FileService()

    private init() {}

    func scanMarkdownFiles(in folder: URL) -> [MarkdownFile] {
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

    func getSubdirectories(in folder: URL) -> [URL] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return contents
            .filter { $0.hasDirectoryPath }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }

    func readFile(at url: URL) -> String? {
        try? String(contentsOf: url, encoding: .utf8)
    }

    func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    func parentDirectory(of url: URL) -> URL? {
        url.deletingLastPathComponent()
    }
}
