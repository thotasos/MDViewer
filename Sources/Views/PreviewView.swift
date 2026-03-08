import SwiftUI
import WebKit

struct PreviewView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel
    @StateObject private var previewViewModel = MarkdownPreviewViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            if let file = viewModel.selectedFile {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.blue)

                    Text(file.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()
            }

            // Content
            if let file = viewModel.selectedFile {
                MarkdownWebView(html: previewViewModel.htmlContent, zoomLevel: viewModel.zoomLevel)
                    .onAppear {
                        previewViewModel.loadMarkdown(from: file.url)
                    }
                    .onChange(of: viewModel.selectedFile?.id) { _ in
                        if let file = viewModel.selectedFile {
                            previewViewModel.loadMarkdown(from: file.url)
                        }
                    }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundStyle(.tertiary)

                    Text("Select a file to preview")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Choose a markdown file from the list")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor))
            }
        }
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    let zoomLevel: CGFloat

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if !html.isEmpty {
            webView.loadHTMLString(html, baseURL: nil)
        }

        webView.pageZoom = zoomLevel
    }
}
