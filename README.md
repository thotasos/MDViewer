# MDViewer

A beautiful native macOS application for viewing Markdown files, designed to work like the macOS Preview app for PDFs.

## Features

- **Native macOS App** - Built with SwiftUI for a seamless macOS experience
- **Three-Column Layout** - Browse folders, select files, and preview with ease
- **Beautiful Rendering** - Elegant typography using SF Pro fonts
- **Syntax Highlighting** - Code blocks are beautifully highlighted
- **Dark Mode Support** - Automatic light and dark theme support
- **Zoom Controls** - Zoom in/out with keyboard shortcuts (Cmd+/Cmd-)
- **Persistent Settings** - Remembers last opened folder and preferences

## Screenshots

The app features a clean three-panel design:
- **Left**: Folder browser with collapsible sidebar
- **Center**: File list showing all .md files in the selected folder
- **Right**: Beautifully rendered markdown preview

## Usage

1. Launch MDViewer
2. Click "Open Folder" or press ⌘O to select a folder containing markdown files
3. Browse markdown files in the center panel
4. Click any file to preview it in the right panel

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘O | Open Folder |
| ⌘+ | Zoom In |
| ⌘- | Zoom Out |
| ⌘0 | Reset Zoom |
| ⌘W | Close Window |
| ⌘Q | Quit |

## Requirements

- macOS 13.0 (Ventura) or later

## Installation

Simply double-click the MDViewer.app bundle to launch the app.

## Tech Stack

- **SwiftUI** - Native macOS UI framework
- **AppKit** - For NSOpenPanel and window management
- **Highlightr** - Syntax highlighting for code blocks
- **WKWebView** - For rendering markdown as HTML

## Architecture

MDViewer follows the MVVM (Model-View-ViewModel) architecture:

```
MDViewer/
├── Sources/
│   ├── App/           # App entry point and delegate
│   ├── Models/        # Data models (MarkdownFile, AppSettings)
│   ├── ViewModels/   # Business logic (FileBrowser, MarkdownPreview)
│   ├── Views/        # SwiftUI views
│   ├── Services/     # File and Markdown services
│   └── Utilities/    # Extensions and helpers
└── Resources/        # Assets
```

## License

MIT License - Feel free to use and modify as needed.
