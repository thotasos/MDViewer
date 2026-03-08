import SwiftUI
import WebKit

struct MarkdownRenderer: View {
    let html: String
    let zoomLevel: CGFloat

    var body: some View {
        MarkdownWebView(html: html, zoomLevel: zoomLevel)
    }
}
