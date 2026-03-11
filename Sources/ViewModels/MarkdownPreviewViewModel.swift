import Foundation
import SwiftUI
import WebKit

class MarkdownPreviewViewModel: ObservableObject {
    @Published var htmlContent: String = ""
    @Published var headings: [Heading] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentFileURL: URL?

    func loadMarkdown(from url: URL) {
        guard url != currentFileURL else { return }

        currentFileURL = url
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let markdown = try String(contentsOf: url, encoding: .utf8)
                let html = MarkdownService.shared.convertToHTML(markdown)
                let extractedHeadings = MarkdownService.shared.extractHeadings(from: markdown)

                DispatchQueue.main.async {
                    self?.htmlContent = html
                    self?.headings = extractedHeadings
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to load file: \(error.localizedDescription)"
                    self?.htmlContent = "<pre>\(error.localizedDescription)</pre>"
                    self?.headings = []
                    self?.isLoading = false
                }
            }
        }
    }

    func clear() {
        currentFileURL = nil
        htmlContent = ""
        headings = []
        errorMessage = nil
    }
}
