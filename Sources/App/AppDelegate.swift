import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app behavior
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // Handle files opened via Finder or drag & drop
        guard let url = urls.first else { return }

        if url.hasDirectoryPath {
            NotificationCenter.default.post(name: .openFolder, object: url)
        } else if url.pathExtension.lowercased() == "md" {
            NotificationCenter.default.post(name: .openFile, object: url)
        }
    }
}

extension Notification.Name {
    static let openFolder = Notification.Name("openFolder")
    static let openFile = Notification.Name("openFile")
}
