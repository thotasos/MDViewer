import Foundation
import AppKit
import Highlightr

struct Heading: Identifiable, Equatable {
    let id = UUID()
    let level: Int
    let text: String
    let anchor: String
}

class MarkdownService {
    static let shared = MarkdownService()

    private let highlightr: Highlightr?

    private init() {
        self.highlightr = Highlightr()
        highlightr?.setTheme(to: "atom-one-dark")
    }

    func extractHeadings(from markdown: String) -> [Heading] {
        var headings: [Heading] = []
        let lines = markdown.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("# ") {
                let text = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 1, text: cleanText, anchor: generateAnchor(from: cleanText)))
            } else if trimmed.hasPrefix("## ") {
                let text = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 2, text: cleanText, anchor: generateAnchor(from: cleanText)))
            } else if trimmed.hasPrefix("### ") {
                let text = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 3, text: cleanText, anchor: generateAnchor(from: cleanText)))
            } else if trimmed.hasPrefix("#### ") {
                let text = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 4, text: cleanText, anchor: generateAnchor(from: cleanText)))
            } else if trimmed.hasPrefix("##### ") {
                let text = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 5, text: cleanText, anchor: generateAnchor(from: cleanText)))
            } else if trimmed.hasPrefix("###### ") {
                let text = String(trimmed.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                let cleanText = removeInlineFormatting(text)
                headings.append(Heading(level: 6, text: cleanText, anchor: generateAnchor(from: cleanText)))
            }
        }

        return headings
    }

    private func removeInlineFormatting(_ text: String) -> String {
        var result = text

        // Remove bold: **text** or __text__
        result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__(.+?)__"#, with: "$1", options: .regularExpression)

        // Remove italic: *text* or _text_
        result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: #"_(.+?)_"#, with: "$1", options: .regularExpression)

        // Remove inline code: `code`
        result = result.replacingOccurrences(of: #"`(.+?)`"#, with: "$1", options: .regularExpression)

        // Remove links: [text](url)
        result = result.replacingOccurrences(of: #"\[(.+?)\]\(.+?\)"#, with: "$1", options: .regularExpression)

        // Remove images: ![alt](url)
        result = result.replacingOccurrences(of: #"!\[(.*?)\]\(.+?\)"#, with: "$1", options: .regularExpression)

        return result.trimmingCharacters(in: .whitespaces)
    }

    private func generateAnchor(from text: String) -> String {
        return text
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
    }

    func convertToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                :root {
                    color-scheme: light dark;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
                    font-size: 15px;
                    line-height: 1.6;
                    padding: 24px 40px;
                    max-width: 900px;
                    margin: 0 auto;
                    background-color: transparent;
                }
                @media (prefers-color-scheme: dark) {
                    body { color: #FFFFFF; }
                    a { color: #58A6FF; }
                    code { background-color: #2D2D2D; color: #E06C75; }
                    pre { background-color: #2D2D2D; }
                    blockquote { border-left-color: #444C56; color: #8B949E; }
                    hr { border-color: #444C56; }
                    table th { background-color: #2D2D2D; }
                    table td, table th { border-color: #444C56; }
                }
                @media (prefers-color-scheme: light) {
                    body { color: #000000; }
                    a { color: #0969DA; }
                    code { background-color: #F0F0F0; color: #CF222E; }
                    pre { background-color: #F0F0F0; }
                    blockquote { border-left-color: #D0D7DE; color: #656D76; }
                    hr { border-color: #D0D7DE; }
                    table th { background-color: #F0F0F0; }
                    table td, table th { border-color: #D0D7DE; }
                }
                h1, h2, h3, h4, h5, h6 {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                    line-height: 1.25;
                }
                h1 { font-size: 28px; border-bottom: 1px solid; padding-bottom: 8px; }
                h2 { font-size: 22px; border-bottom: 1px solid; padding-bottom: 6px; }
                h3 { font-size: 18px; }
                h4 { font-size: 16px; }
                p { margin: 0 0 16px 0; }
                a { text-decoration: none; }
                a:hover { text-decoration: underline; }
                code {
                    font-family: 'SF Mono', Menlo, Monaco, monospace;
                    font-size: 13px;
                    padding: 2px 6px;
                    border-radius: 4px;
                }
                pre {
                    padding: 16px;
                    border-radius: 8px;
                    overflow-x: auto;
                    margin: 16px 0;
                    position: relative;
                }
                pre code {
                    padding: 0;
                    background: none;
                    font-size: 13px;
                    line-height: 1.5;
                }
                ul, ol { margin: 0 0 16px 0; padding-left: 24px; }
                li { margin: 4px 0; }
                li > ul, li > ol { margin: 0; }
                blockquote {
                    margin: 16px 0;
                    padding: 0 16px;
                    border-left: 4px solid;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: 16px 0;
                }
                table th, table td {
                    padding: 8px 12px;
                    border: 1px solid;
                    text-align: left;
                }
                table th { font-weight: 600; }
                img {
                    max-width: 100%;
                    height: auto;
                    border-radius: 8px;
                }
                hr {
                    border: none;
                    border-top: 1px solid;
                    margin: 24px 0;
                }
                .task-list-item {
                    list-style-type: none;
                    margin-left: -20px;
                }
                .task-list-item input {
                    margin-right: 8px;
                }
                /* Search highlight */
                .search-highlight {
                    background-color: #FFEB3B;
                    color: #000000;
                    padding: 1px 2px;
                    border-radius: 2px;
                }
                .search-highlight.current {
                    background-color: #FF9800;
                    outline: 2px solid #E65100;
                }
                @media (prefers-color-scheme: dark) {
                    .search-highlight {
                        background-color: #FF8F00;
                        color: #FFFFFF;
                    }
                    .search-highlight.current {
                        background-color: #FF6F00;
                        outline: 2px solid #FFAB00;
                    }
                }
            </style>
            <script>
                function highlightSearch(term) {
                    clearHighlights();
                    if (!term || term.length === 0) return 0;

                    const regex = new RegExp('(' + escapeRegExp(term) + ')', 'gi');
                    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
                    const textNodes = [];
                    while(walker.nextNode()) textNodes.push(walker.currentNode);

                    let count = 0;
                    textNodes.forEach(node => {
                        if (node.parentNode.tagName === 'SCRIPT' || node.parentNode.tagName === 'STYLE') return;
                        const text = node.textContent;
                        if (regex.test(text)) {
                            const span = document.createElement('span');
                            span.innerHTML = text.replace(regex, '<mark class="search-highlight">$1</mark>');
                            node.parentNode.replaceChild(span, node);
                            count += (text.match(regex) || []).length;
                        }
                        regex.lastIndex = 0;
                    });
                    return count;
                }

                function clearHighlights() {
                    const marks = document.querySelectorAll('mark.search-highlight');
                    marks.forEach(mark => {
                        const parent = mark.parentNode;
                        parent.replaceChild(document.createTextNode(mark.textContent), mark);
                        parent.normalize();
                    });
                }

                function scrollToNextMatch() {
                    const marks = document.querySelectorAll('mark.search-highlight');
                    if (marks.length === 0) return false;

                    let current = document.querySelector('mark.search-highlight.current');
                    let index = current ? Array.from(marks).indexOf(current) : -1;

                    marks.forEach(m => m.classList.remove('current'));

                    let nextIndex = (index + 1) % marks.length;
                    marks[nextIndex].classList.add('current');
                    marks[nextIndex].scrollIntoView({behavior: 'smooth', block: 'center'});
                    return true;
                }

                function scrollToPreviousMatch() {
                    const marks = document.querySelectorAll('mark.search-highlight');
                    if (marks.length === 0) return false;

                    let current = document.querySelector('mark.search-highlight.current');
                    let index = current ? Array.from(marks).indexOf(current) : marks.length;

                    marks.forEach(m => m.classList.remove('current'));

                    let prevIndex = index - 1;
                    if (prevIndex < 0) prevIndex = marks.length - 1;
                    marks[prevIndex].classList.add('current');
                    marks[prevIndex].scrollIntoView({behavior: 'smooth', block: 'center'});
                    return true;
                }

                function escapeRegExp(string) {
                    return string.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');
                }

                function getMatchCount() {
                    return document.querySelectorAll('mark.search-highlight').length;
                }
            </script>
        </head>
        <body>

        """

        var inCodeBlock = false
        var codeBlockContent = ""
        var codeBlockLanguage = ""

        var inList = false
        var listType = ""

        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    // End code block
                    let highlightedCode = highlightCode(codeBlockContent, language: codeBlockLanguage)
                    html += "<pre><code class=\"language-\(codeBlockLanguage)\">\(highlightedCode)</code></pre>\n"
                    codeBlockContent = ""
                    codeBlockLanguage = ""
                    inCodeBlock = false
                } else {
                    // Start code block
                    inCodeBlock = true
                    codeBlockLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                }
                continue
            }

            if inCodeBlock {
                codeBlockContent += line + "\n"
                continue
            }

            // Headers
            if line.hasPrefix("# ") {
                let text = String(line.dropFirst(2))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h1 id=\"\(anchor)\">\(escapeHTML(text))</h1>\n"
            } else if line.hasPrefix("## ") {
                let text = String(line.dropFirst(3))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h2 id=\"\(anchor)\">\(escapeHTML(text))</h2>\n"
            } else if line.hasPrefix("### ") {
                let text = String(line.dropFirst(4))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h3 id=\"\(anchor)\">\(escapeHTML(text))</h3>\n"
            } else if line.hasPrefix("#### ") {
                let text = String(line.dropFirst(5))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h4 id=\"\(anchor)\">\(escapeHTML(text))</h4>\n"
            } else if line.hasPrefix("##### ") {
                let text = String(line.dropFirst(6))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h5 id=\"\(anchor)\">\(escapeHTML(text))</h5>\n"
            } else if line.hasPrefix("###### ") {
                let text = String(line.dropFirst(7))
                let anchor = generateAnchor(from: removeInlineFormatting(text))
                html += "<h6 id=\"\(anchor)\">\(escapeHTML(text))</h6>\n"
            }
            // Horizontal rule
            else if line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___") {
                html += "<hr>\n"
            }
            // Blockquote
            else if line.hasPrefix("> ") {
                html += "<blockquote>\(escapeHTML(String(line.dropFirst(2))))</blockquote>\n"
            }
            // Unordered list
            else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                let content = processInline(String(line.dropFirst(2)))
                if line.contains("[ ]") || line.contains("[x]") || line.contains("[X]") {
                    let checked = line.contains("[x]") || line.contains("[X]")
                    html += "<li class=\"task-list-item\"><input type=\"checkbox\" \(checked ? "checked" : "") disabled> \(content)</li>\n"
                } else {
                    html += "<li>\(content)</li>\n"
                }
            }
            // Ordered list
            else if line.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                var dropped = line.drop(while: { $0.isNumber || $0 == "." })
                while dropped.first == " " || dropped.first == "." {
                    dropped = dropped.dropFirst()
                }
                let content = processInline(String(dropped).trimmingCharacters(in: .whitespaces))
                html += "<li>\(content)</li>\n"
            }
            // Table
            else if line.hasPrefix("|") {
                html += processTableLine(line) + "\n"
            }
            // Empty line
            else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                html += "<br>\n"
            }
            // Regular paragraph
            else {
                let processed = processInline(line)
                html += "<p>\(processed)</p>\n"
            }
        }

        html += """
        </body>
        </html>
        """

        return html
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private func processInline(_ text: String) -> String {
        var result = escapeHTML(text)

        // Bold: **text** or __text__
        result = result.replacingOccurrences(
            of: #"\*\*(.+?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: #"__(.+?)__"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )

        // Italic: *text* or _text_
        result = result.replacingOccurrences(
            of: #"\*(.+?)\*"#,
            with: "<em>$1</em>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: #"_(.+?)_"#,
            with: "<em>$1</em>",
            options: .regularExpression
        )

        // Inline code: `code`
        result = result.replacingOccurrences(
            of: #"`(.+?)`"#,
            with: "<code>$1</code>",
            options: .regularExpression
        )

        // Links: [text](url)
        result = result.replacingOccurrences(
            of: #"\[(.+?)\]\((.+?)\)"#,
            with: "<a href=\"$2\">$1</a>",
            options: .regularExpression
        )

        // Images: ![alt](url)
        result = result.replacingOccurrences(
            of: #"!\[(.*?)\]\((.+?)\)"#,
            with: "<img src=\"$2\" alt=\"$1\">",
            options: .regularExpression
        )

        // Strikethrough: ~~text~~
        result = result.replacingOccurrences(
            of: #"~~(.+?)~~"#,
            with: "<del>$1</del>",
            options: .regularExpression
        )

        return result
    }

    private var isTableRow = false

    private func processTableLine(_ line: String) -> String {
        let cells = line
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "| ", with: "|")
            .replacingOccurrences(of: " |", with: "|")
            .trimmingCharacters(in: CharacterSet(charactersIn: "|"))
            .components(separatedBy: "|")

        // Check if it's a separator row
        if cells.allSatisfy({ $0.allSatisfy({ $0 == "-" || $0 == ":" }) }) {
            return ""
        }

        let tag = isTableRow ? "td" : "th"
        isTableRow = true

        let content = cells.map { "<$tag>\(escapeHTML($0.trimmingCharacters(in: .whitespaces)))</$tag>" }.joined()
        return "<tr>\(content)</tr>"
    }

    private func highlightCode(_ code: String, language: String) -> String {
        guard let highlightr = highlightr,
              !language.isEmpty,
              let highlighted = highlightr.highlight(code, as: language) else {
            return escapeHTML(code)
        }

        return highlighted.string
    }
}
