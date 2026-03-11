import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let lastFolderKey = "lastOpenedFolder"
    private let recentFoldersKey = "recentFolders"
    private let sidebarCollapsedKey = "sidebarCollapsed"
    private let fileListCollapsedKey = "fileListCollapsed"
    private let outlineCollapsedKey = "outlineCollapsed"
    private let zoomLevelKey = "zoomLevel"

    private let maxRecentFolders = 10

    @Published var lastOpenedFolder: URL? {
        didSet {
            if let url = lastOpenedFolder {
                UserDefaults.standard.set(url.path, forKey: lastFolderKey)
            }
        }
    }

    @Published var recentFolders: [URL] = [] {
        didSet {
            let paths = recentFolders.map { $0.path }
            UserDefaults.standard.set(paths, forKey: recentFoldersKey)
        }
    }

    @Published var sidebarCollapsed: Bool {
        didSet {
            UserDefaults.standard.set(sidebarCollapsed, forKey: sidebarCollapsedKey)
        }
    }

    @Published var fileListCollapsed: Bool {
        didSet {
            UserDefaults.standard.set(fileListCollapsed, forKey: fileListCollapsedKey)
        }
    }

    @Published var outlineCollapsed: Bool {
        didSet {
            UserDefaults.standard.set(outlineCollapsed, forKey: outlineCollapsedKey)
        }
    }

    @Published var zoomLevel: CGFloat {
        didSet {
            UserDefaults.standard.set(zoomLevel, forKey: zoomLevelKey)
        }
    }

    private init() {
        let loadedZoom = CGFloat(UserDefaults.standard.double(forKey: zoomLevelKey))
        self.zoomLevel = loadedZoom == 0 ? 1.0 : loadedZoom

        self.sidebarCollapsed = UserDefaults.standard.bool(forKey: sidebarCollapsedKey)
        self.fileListCollapsed = UserDefaults.standard.bool(forKey: fileListCollapsedKey)
        self.outlineCollapsed = UserDefaults.standard.bool(forKey: outlineCollapsedKey)

        if let path = UserDefaults.standard.string(forKey: lastFolderKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                self.lastOpenedFolder = url
            }
        }

        if let paths = UserDefaults.standard.stringArray(forKey: recentFoldersKey) {
            self.recentFolders = paths
                .map { URL(fileURLWithPath: $0) }
                .filter { FileManager.default.fileExists(atPath: $0.path) }
        }
    }

    func addToRecentFolders(_ url: URL) {
        var updated = recentFolders.filter { $0 != url }
        updated.insert(url, at: 0)
        if updated.count > maxRecentFolders {
            updated = Array(updated.prefix(maxRecentFolders))
        }
        recentFolders = updated
    }

    func removeFromRecentFolders(_ url: URL) {
        recentFolders = recentFolders.filter { $0 != url }
    }

    func clearRecentFolders() {
        recentFolders = []
    }
}
