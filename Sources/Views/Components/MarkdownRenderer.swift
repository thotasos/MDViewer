import SwiftUI
import WebKit

struct MarkdownRenderer: View {
    let html: String
    let zoomLevel: CGFloat
    @Binding var coordinator: WebViewCoordinator?

    var body: some View {
        MarkdownWebView(html: html, zoomLevel: zoomLevel, coordinator: $coordinator)
    }
}
