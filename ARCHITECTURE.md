# Architecture Overview

## System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        MDViewer                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐    │
│  │   Sidebar   │  │  File List  │ │     Preview     │    │
│  │   (Swift)   │  │  (SwiftUI)  │ │   (WKWebView)   │    │
│  └──────┬──────┘  └──────┬──────┘ └────────┬────────┘    │
│         │                │                  │              │
│         └────────────────┼──────────────────┘              │
│                          ▼                                  │
│              ┌───────────────────────┐                      │
│              │  FileBrowserViewModel  │                      │
│              │    (ObservableObject)  │                      │
│              └───────────┬────────────┘                      │
│                          │                                   │
│         ┌────────────────┼────────────────┐                 │
│         ▼                ▼                ▼                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ FileService │  │   Markdown  │  │  AppSettings│        │
│  │             │  │   Service   │  │ (UserDefaults│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### App Layer
- **MDViewerApp.swift** - Main app entry point, defines WindowGroup
- **AppDelegate.swift** - Handles app lifecycle, file open events

### Models
- **MarkdownFile** - Represents a markdown file with metadata
- **FileSystemItem** - Represents a file/folder in the tree
- **AppSettings** - Singleton for persisting user preferences

### ViewModels
- **FileBrowserViewModel** - Manages folder browsing, file selection, zoom
- **MarkdownPreviewViewModel** - Handles markdown-to-HTML conversion

### Views
- **ContentView** - Main split view container
- **SidebarView** - Folder tree browser
- **FileListView** - List of markdown files in selected folder
- **PreviewView** - Markdown preview using WKWebView
- **WelcomeView** - Initial welcome screen

### Services
- **FileService** - File system operations (scan folders, read files)
- **MarkdownService** - Custom markdown to HTML converter with syntax highlighting

## Data Flow

1. **Opening a Folder:**
   - User clicks "Open Folder" → NSOpenPanel appears
   - FileBrowserViewModel.openFolder() → scans directory
   - FileSystemItem tree built → markdownFiles array populated
   - First file auto-selected → shown in preview

2. **Selecting a File:**
   - User clicks file in FileListView
   - FileBrowserViewModel.selectedFile updated
   - PreviewView detects change → MarkdownPreviewViewModel loads file
   - MarkdownService converts markdown to HTML
   - WKWebView renders HTML

3. **Settings Persistence:**
   - User changes zoom level → saved to AppSettings → UserDefaults
   - App launches → AppSettings loads from UserDefaults

## State Management

- **@StateObject** - Used for view-local state (MarkdownPreviewViewModel)
- **@EnvironmentObject** - Used for app-wide state (FileBrowserViewModel)
- **@Published** - Triggers UI updates when properties change

## Error Handling

- File read errors: Show error message in preview
- Invalid markdown: Render as plain text
- Missing folders: Show empty state with "Open Folder" prompt

## Extension Points

Future enhancements could include:
- Search within document (add search bar to preview)
- Print support (use WKWebView printing)
- Recent folders menu (store in UserDefaults)
- File watching for live updates (use DispatchSource)
