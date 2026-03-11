import XCTest
@testable import MDViewer

final class MarkdownServiceTests: XCTestCase {

    var markdownService: MarkdownService!

    override func setUp() {
        super.setUp()
        markdownService = MarkdownService.shared
    }

    override func tearDown() {
        markdownService = nil
        super.tearDown()
    }

    // MARK: - Heading Extraction Tests

    func testExtractHeadings_SimpleHeadings() {
        let markdown = """
        # Heading 1

        ## Heading 2

        ### Heading 3

        #### Heading 4

        ##### Heading 5

        ###### Heading 6

        Some content here
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertEqual(headings.count, 6)
        XCTAssertEqual(headings[0].level, 1)
        XCTAssertEqual(headings[0].text, "Heading 1")
        XCTAssertEqual(headings[1].level, 2)
        XCTAssertEqual(headings[1].text, "Heading 2")
        XCTAssertEqual(headings[2].level, 3)
        XCTAssertEqual(headings[2].text, "Heading 3")
        XCTAssertEqual(headings[3].level, 4)
        XCTAssertEqual(headings[3].text, "Heading 4")
        XCTAssertEqual(headings[4].level, 5)
        XCTAssertEqual(headings[4].text, "Heading 5")
        XCTAssertEqual(headings[5].level, 6)
        XCTAssertEqual(headings[5].text, "Heading 6")
    }

    func testExtractHeadings_WithInlineFormatting() {
        let markdown = """
        # **Bold Heading**

        ## *Italic Heading*

        ## [Link Heading](url)
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertEqual(headings.count, 3)
        XCTAssertEqual(headings[0].text, "Bold Heading")
        XCTAssertEqual(headings[1].text, "Italic Heading")
        XCTAssertEqual(headings[2].text, "Link Heading")
    }

    func testExtractHeadings_NoHeadings() {
        let markdown = """
        This is just a paragraph.

        - List item 1
        - List item 2

        ```swift
        let x = 1
        ```
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertTrue(headings.isEmpty)
    }

    func testExtractHeadings_EmptyString() {
        let markdown = ""

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertTrue(headings.isEmpty)
    }

    func testExtractHeadings_MultipleH1() {
        let markdown = """
        # First H1

        Some content

        # Second H1

        More content
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertEqual(headings.count, 2)
        XCTAssertEqual(headings[0].level, 1)
        XCTAssertEqual(headings[0].text, "First H1")
        XCTAssertEqual(headings[1].level, 1)
        XCTAssertEqual(headings[1].text, "Second H1")
    }

    func testExtractHeadings_NestedStructure() {
        let markdown = """
        # Main Title

        ## Section 1

        ### Subsection 1.1

        ### Subsection 1.2

        ## Section 2

        ### Subsection 2.1

        #### Deep Nested
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertEqual(headings.count, 7)
        XCTAssertEqual(headings[0].text, "Main Title")
        XCTAssertEqual(headings[1].text, "Section 1")
        XCTAssertEqual(headings[2].text, "Subsection 1.1")
        XCTAssertEqual(headings[3].text, "Subsection 1.2")
        XCTAssertEqual(headings[4].text, "Section 2")
        XCTAssertEqual(headings[5].text, "Subsection 2.1")
        XCTAssertEqual(headings[6].text, "Deep Nested")
    }

    func testExtractHeadings_HeadingWithEmoji() {
        let markdown = """
        # 🚀 Getting Started

        ## 🛠 Installation
        """

        let headings = markdownService.extractHeadings(from: markdown)

        XCTAssertEqual(headings.count, 2)
        XCTAssertEqual(headings[0].text, "🚀 Getting Started")
        XCTAssertEqual(headings[1].text, "🛠 Installation")
    }

    // MARK: - HTML Generation Tests

    func testConvertToHTML_BasicMarkdown() {
        let markdown = "# Hello World\n\nThis is a paragraph."

        let html = markdownService.convertToHTML(markdown)

        XCTAssertTrue(html.contains("<h1>Hello World</h1>"))
        XCTAssertTrue(html.contains("<p>This is a paragraph.</p>"))
    }

    func testConvertToHTML_CodeBlock() {
        let markdown = "```swift\nlet x = 1\n```"

        let html = markdownService.convertToHTML(markdown)

        XCTAssertTrue(html.contains("language-swift"))
    }
}
