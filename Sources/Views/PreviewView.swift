import SwiftUI
import WebKit

struct PreviewView: View {
    @EnvironmentObject var viewModel: FileBrowserViewModel
    @StateObject private var previewViewModel = MarkdownPreviewViewModel()
    @State private var webViewCoordinator: WebViewCoordinator?

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

                    // Outline toggle button
                    if !previewViewModel.headings.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.outlineCollapsed.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.outlineCollapsed ? "list.bullet" : "list.bullet.rectangle")
                        }
                        .buttonStyle(.borderless)
                        .help("Toggle Document Outline")
                    }

                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()

                // Document Outline
                if !previewViewModel.headings.isEmpty && !viewModel.outlineCollapsed {
                    DocumentOutlineView(
                        headings: previewViewModel.headings,
                        onSelectHeading: { heading in
                            webViewCoordinator?.scrollToHeading(heading.anchor)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    Divider()
                }
            }

            // Content
            if let file = viewModel.selectedFile {
                MarkdownWebView(
                    html: previewViewModel.htmlContent,
                    zoomLevel: viewModel.zoomLevel,
                    coordinator: $webViewCoordinator
                )
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

class WebViewCoordinator: NSObject {
    weak var webView: WKWebView?

    func scrollToHeading(_ anchor: String) {
        let js = "document.getElementById('\(anchor)').scrollIntoView({behavior: 'smooth', block: 'start'});"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    let zoomLevel: CGFloat
    @Binding var coordinator: WebViewCoordinator?

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")

        let newCoordinator = WebViewCoordinator()
        newCoordinator.webView = webView
        DispatchQueue.main.async {
            self.coordinator = newCoordinator
        }

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if !html.isEmpty {
            webView.loadHTMLString(html, baseURL: nil)
        }

        webView.pageZoom = zoomLevel
    }
}
