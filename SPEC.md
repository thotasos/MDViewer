# MDViewer - macOS Markdown Preview App

## 1. Project Overview

- **Project Name:** MDViewer
- **Bundle Identifier:** com.mdviewer.app
- **Core Functionality:** A native macOS application for viewing markdown files with beautiful rendering, similar to how Preview.app displays PDFs. No editing - viewing only.
- **Target Users:** Developers, writers, and anyone who works with markdown files
- **macOS Version Support:** macOS 13.0 (Ventura) and later

## 2. UI/UX Specification

### Window Structure

- **Main Window:** Single window application with NSSplitViewController-style layout
- **Navigation:** Three-column layout
  - Left: Sidebar with file browser (collapsible)
  - Center: File list/thumbnails
  - Right: Markdown rendered preview
- **Window Size:** Default 1200x800, minimum 800x600
- **Window Chrome:** Native macOS window with title bar

### Visual Design

#### Color Palette
- **Primary Background (Dark):** #1E1E1E (system background)
- **Primary Background (Light):** #FFFFFF
- **Secondary Background (Dark):** #252526
- **Secondary Background (Light):** #F5F5F5
- **Accent Color:** #007AFF (system blue)
- **Text Primary (Dark):** #FFFFFF
- **Text Primary (Light):** #000000
- **Text Secondary:** #8E8E93 (system gray)
- **Code Block Background (Dark):** #2D2D2D
- **Code Block Background (Light):** #F0F0F0
- **Border Color (Dark):** #3D3D3D
- **Border Color (Light):** #E0E0E0

#### Typography
- **App Font:** System font (SF Pro) - native macOS font
- **Document Title:** SF Pro Display, 24pt, Semibold
- **Heading 1:** SF Pro Display, 28pt, Bold
- **Heading 2:** SF Pro Display, 22pt, Semibold
- **Heading 3:** SF Pro Display, 18pt, Medium
- **Body Text:** SF Pro Text, 15pt, Regular
- **Code:** SF Mono, 13pt, Regular
- **Caption/Metadata:** SF Pro Text, 12pt, Regular
- **Line Height:** 1.6 for body text

#### Spacing System (8pt grid)
- **Window Padding:** 16pt
- **Section Spacing:** 24pt
- **Element Spacing:** 8pt
- **List Item Padding:** 12pt vertical, 16pt horizontal
- **Card Padding:** 16pt

### Views & Components

#### Sidebar (File Browser)
- Native NSOutlineView-style file tree
- Shows folders and .md files
- Collapsible with toggle button
- Current folder path shown at top
- "Open Folder" button

#### File List (Center Panel)
- List view showing all .md files in selected folder
- Each item shows:
  - File icon (document icon)
  - File name (bold)
  - Last modified date (secondary text)
  - File size (secondary text)
- Selection highlight with accent color
- Sort by: Date Modified (default), Name, Size

#### Preview Panel (Right)
- Rendered markdown with beautiful typography
- Support for:
  - All standard markdown (headers, lists, code blocks, links, images, tables, blockquotes, horizontal rules)
  - Syntax highlighting for code blocks
  - Image display (local and remote)
  - Checkbox/todo lists
  - Task lists
- Smooth scrolling
- Zoom support (Cmd+/Cmd-)
- Copy code button on code blocks

#### Toolbar
- Open Folder button
- Zoom controls (-, +, fit)
- View mode toggle (single page, continuous)
- Search in document

#### Empty States
- Welcome screen with "Open Folder" prominent button
- Instructions for usage
- Recent folders (if any)

#### States
- **Loading:** Native progress indicator
- **Empty Folder:** "No markdown files found" message
- **Error:** Alert for invalid files
- **File Not Found:** Graceful error message

### Interactions & Animations
- Smooth sidebar collapse/expand (250ms ease-in-out)
- File selection with subtle highlight transition
- Hover states on all interactive elements
- Double-click file to open
- Drag & drop folder onto app to open
- Keyboard navigation (arrow keys, Enter to open)
- Cmd+O to open folder
- Cmd+W to close window
- Cmd+Q to quit

## 3. Functionality Specification

### Core Features (Priority Order)

1. **P0 - Must Have:**
   - Open folder and browse markdown files
   - Render standard markdown to HTML
   - Display code blocks with syntax highlighting
   - Support dark/light mode
   - Remember last opened folder
   - Smooth scrolling

2. **P1 - Should Have:**
   - Zoom in/out
   - Search within document
   - Copy code blocks
   - Image support
   - Table rendering

3. **P2 - Nice to Have:**
   - Recent folders
   - Print support
   - Share menu

### User Flows

#### Opening a Folder
1. User clicks "Open Folder" or uses Cmd+O
2. NSOpenPanel appears (directory selection mode)
3. User selects folder
4. App scans for .md files
5. File list populates
6. First file auto-selected and displayed

#### Viewing a File
1. User clicks file in list
2. Preview panel loads and renders markdown
3. Smooth scroll to top (optional)
4. User can scroll through rendered content

### Data Handling
- **No persistence required** for document content
- **UserDefaults** for:
  - Last opened folder path
  - Window position/size
  - Sidebar collapsed state
  - Zoom level preference

### Architecture Pattern
- **MVVM (Model-View-ViewModel)**
- SwiftUI for all views
- Combine for reactive data flow

### Edge Cases & Error Handling
- Invalid markdown: Show as plain text
- Missing images: Show placeholder
- Very large files: Lazy rendering
- Permission denied: Show error alert
- Empty folder: Show empty state

## 4. Technical Specification

### Dependencies (Swift Package Manager)

| Package | Version | Purpose |
|---------|---------|---------|
| swift-markdown | 0.4.0 | Apple's official markdown parsing |
| Highlightr | 2.2.1 | Syntax highlighting for code blocks |

### UI Framework
- **SwiftUI** (primary)
- **AppKit integration** where needed (NSOpenPanel, window management)

### Asset Requirements
- App Icon: Document with "MD" text (will use SF Symbols)
- Document Icon: Custom .md file icon
- All icons from SF Symbols

### File Structure
```
MDViewer/
├── Sources/
│   ├── App/
│   │   ├── MDViewerApp.swift
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── MarkdownFile.swift
│   │   └── AppSettings.swift
│   ├── ViewModels/
│   │   ├── FileBrowserViewModel.swift
│   │   └── MarkdownPreviewViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SidebarView.swift
│   │   ├── FileListView.swift
│   │   ├── PreviewView.swift
│   │   ├── WelcomeView.swift
│   │   └── Components/
│   │       ├── MarkdownRenderer.swift
│   │       └── CodeBlockView.swift
│   ├── Services/
│   │   ├── FileService.swift
│   │   └── MarkdownService.swift
│   └── Utilities/
│       └── Extensions.swift
├── Resources/
│   └── Assets.xcassets/
├── project.yml
└── Package.swift (for SPM dependencies)
```

### Build Configuration
- Deployment Target: macOS 13.0
- Swift Version: 5.9
- Code Signing: Sign to Run Locally
- Hardened Runtime: Enabled
- App Sandbox: Disabled (for file system access)
