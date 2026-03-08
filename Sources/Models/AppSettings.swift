import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let lastFolderKey = "lastOpenedFolder"
    private let sidebarCollapsedKey = "sidebarCollapsed"
    private let fileListCollapsedKey = "fileListCollapsed"
    private let zoomLevelKey = "zoomLevel"

    @Published var lastOpenedFolder: URL? {
        didSet {
            if let url = lastOpenedFolder {
                UserDefaults.standard.set(url.path, forKey: lastFolderKey)
            }
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

        if let path = UserDefaults.standard.string(forKey: lastFolderKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                self.lastOpenedFolder = url
            }
        }
    }
}
