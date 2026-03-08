# Design Decisions

## Tech Stack

### SwiftUI over AppKit
- **Chosen:** SwiftUI for all UI components
- **Alternatives considered:** AppKit, Hybrid SwiftUI/AppKit
- **Rationale:** SwiftUI is Apple's modern UI framework, provides better state management with @Published properties, and offers native macOS controls with minimal effort. It also automatically supports Dark Mode.
- **Tradeoffs:** Less fine-grained control over window chrome compared to pure AppKit

### WKWebView for Markdown Rendering
- **Chosen:** WKWebView to render HTML-generated markdown
- **Alternatives considered:** SwiftUI Text with AttributedString, NSTextView
- **Rationale:** WKWebView provides the most flexible and beautiful rendering of HTML/CSS, supports syntax highlighting via Highlightr, and automatically handles scrolling, selection, and zooming.
- **Tradeoffs:** Slightly more memory overhead than pure text rendering

### Highlightr for Syntax Highlighting
- **Chosen:** Highlightr library for code block highlighting
- **Alternatives considered:** Custom highlighting, swift-markdown library
- **Rationale:** Highlightr supports 190+ languages and 90+ themes, integrates well with WKWebView, and provides consistent results.
- **Tradeoffs:** External dependency, adds to bundle size

## Architecture

### MVVM Pattern
- **Chosen:** Model-View-ViewModel architecture
- **Alternatives considered:** MVC, Clean Architecture
- **Rationale:** MVVM works naturally with SwiftUI's @StateObject and @EnvironmentObject property wrappers, keeping business logic separate from views while enabling reactive UI updates.
- **Tradeoffs:** May require more boilerplate for complex state management

### UserDefaults for Persistence
- **Chosen:** UserDefaults for all app settings
- **Alternatives considered:** Core Data, SQLite, File-based storage
- **Rationale:** UserDefaults is perfect for small amounts of data like preferences, last folder path, and zoom level. No additional setup required.
- **Tradeoffs:** Not suitable for large data sets

## UI/UX

### Three-Column Split View
- **Chosen:** HSplitView with three columns (Sidebar, File List, Preview)
- **Alternatives considered:** Two-panel, Tab-based navigation
- **Rationale:** Mirrors Finder and Preview.app patterns that macOS users are familiar with. Provides quick navigation without excessive clicking.
- **Tradeoffs:** Takes more screen space on smaller displays

### Dark Mode First
- **Chosen:** Dark mode as default consideration with light mode support
- **Rationale:** Developers and technical users often prefer dark mode. Using system colors ensures proper theme switching.
- **Tradeoffs:** Some custom styling requires extra consideration for both modes

### SF Pro Fonts
- **Chosen:** System fonts (SF Pro, SF Mono for code)
- **Alternatives considered:** Custom web fonts
- **Rationale:** SF Pro is optimized for screen readability on Apple devices, loads instantly, and provides native feel.
- **Tradeoffs:** Limited font variety on non-Apple devices
