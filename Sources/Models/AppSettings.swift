import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let lastFolderKey = "lastOpenedFolder"
    private let sidebarCollapsedKey = "sidebarCollapsed"
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

    @Published var zoomLevel: CGFloat {
        didSet {
            UserDefaults.standard.set(zoomLevel, forKey: zoomLevelKey)
        }
    }

    private init() {
        if let path = UserDefaults.standard.string(forKey: lastFolderKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                self.lastOpenedFolder = url
            }
        }

        self.sidebarCollapsed = UserDefaults.standard.bool(forKey: sidebarCollapsedKey)
        self.zoomLevel = CGFloat(UserDefaults.standard.double(forKey: zoomLevelKey))
        if self.zoomLevel == 0 {
            self.zoomLevel = 1.0
        }
    }
}
