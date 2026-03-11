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

                    // Search toggle button
                    Button(action: {
                        previewViewModel.toggleSearch()
                    }) {
                        Image(systemName: previewViewModel.searchVisible ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    }
                    .buttonStyle(.borderless)
                    .help("Search (Cmd+F)")
                    .keyboardShortcut("f", modifiers: .command)

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

                // Search bar
                if previewViewModel.searchVisible {
                    SearchBarView(
                        searchText: $previewViewModel.searchText,
                        matchCount: previewViewModel.matchCount,
                        currentMatchIndex: previewViewModel.currentMatchIndex,
                        onSearch: { term in
                            webViewCoordinator?.search(term: term) { count in
                                previewViewModel.matchCount = count
                                previewViewModel.currentMatchIndex = count > 0 ? 1 : 0
                            }
                        },
                        onNext: {
                            webViewCoordinator?.searchNext { found in
                                if found {
                                    previewViewModel.currentMatchIndex = min(previewViewModel.currentMatchIndex + 1, previewViewModel.matchCount)
                                }
                            }
                        },
                        onPrevious: {
                            webViewCoordinator?.searchPrevious { found in
                                if found {
                                    previewViewModel.currentMatchIndex = max(previewViewModel.currentMatchIndex - 1, 1)
                                }
                            }
                        },
                        onClear: {
                            webViewCoordinator?.clearSearch()
                            previewViewModel.clearSearch()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))

                    Divider()
                }

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
                    coordinator: $webViewCoordinator,
                    searchText: previewViewModel.searchText,
                    baseURL: file.url.deletingLastPathComponent()
                )
                .onAppear {
                    previewViewModel.loadMarkdown(from: file.url)
                }
                .onChange(of: viewModel.selectedFile?.id) { _ in
                    if let file = viewModel.selectedFile {
                        previewViewModel.loadMarkdown(from: file.url)
                    }
                }
                .onChange(of: previewViewModel.searchText) { newValue in
                    if newValue.isEmpty {
                        webViewCoordinator?.clearSearch()
                        previewViewModel.matchCount = 0
                        previewViewModel.currentMatchIndex = 0
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

struct SearchBarView: View {
    @Binding var searchText: String
    let matchCount: Int
    let currentMatchIndex: Int
    let onSearch: (String) -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search in document...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.callout)
                    .onSubmit {
                        if !searchText.isEmpty {
                            onSearch(searchText)
                        }
                    }
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty {
                            onSearch(newValue)
                        } else {
                            onClear()
                        }
                    }

                if !searchText.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            if matchCount > 0 {
                Text("\(currentMatchIndex) of \(matchCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: onPrevious) {
                    Image(systemName: "chevron.up")
                }
                .buttonStyle(.borderless)
                .disabled(matchCount <= 1)

                Button(action: onNext) {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)
                .disabled(matchCount <= 1)
            } else if !searchText.isEmpty {
                Text("No results")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

class WebViewCoordinator: NSObject {
    weak var webView: WKWebView?

    func scrollToHeading(_ anchor: String) {
        let js = "document.getElementById('\(anchor)').scrollIntoView({behavior: 'smooth', block: 'start'});"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    func search(term: String, completion: @escaping (Int) -> Void) {
        let escapedTerm = term.replacingOccurrences(of: "'", with: "\\'")
        let js = "highlightSearch('\(escapedTerm)')"
        webView?.evaluateJavaScript(js) { result, _ in
            let count = (result as? Int) ?? 0
            completion(count)
        }
    }

    func searchNext(completion: @escaping (Bool) -> Void) {
        webView?.evaluateJavaScript("scrollToNextMatch()") { result, _ in
            let found = (result as? Bool) ?? false
            completion(found)
        }
    }

    func searchPrevious(completion: @escaping (Bool) -> Void) {
        webView?.evaluateJavaScript("scrollToPreviousMatch()") { result, _ in
            let found = (result as? Bool) ?? false
            completion(found)
        }
    }

    func clearSearch() {
        webView?.evaluateJavaScript("clearHighlights()", completionHandler: nil)
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    let zoomLevel: CGFloat
    @Binding var coordinator: WebViewCoordinator?
    var searchText: String = ""
    var baseURL: URL? = nil

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
            webView.loadHTMLString(html, baseURL: baseURL)
        }

        webView.pageZoom = zoomLevel
    }
}
