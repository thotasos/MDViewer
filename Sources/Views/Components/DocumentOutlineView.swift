import SwiftUI

struct DocumentOutlineView: View {
    let headings: [Heading]
    let onSelectHeading: (Heading) -> Void

    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Contents")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(headings.count)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(headings) { heading in
                            OutlineItemView(
                                heading: heading,
                                onSelect: { onSelectHeading(heading) }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .frame(maxHeight: 200)
            }
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct OutlineItemView: View {
    let heading: Heading
    let onSelect: () -> Void

    @State private var isHovered = false

    private var indentation: CGFloat {
        CGFloat((heading.level - 1) * 12)
    }

    private var fontSize: Font {
        switch heading.level {
        case 1: return .caption
        case 2: return .caption
        case 3: return .caption2
        default: return .caption2
        }
    }

    private var fontWeight: Font.Weight {
        heading.level == 1 ? .semibold : .regular
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                // Level indicator
                Circle()
                    .fill(headingLevelColor)
                    .frame(width: 4, height: 4)

                Text(heading.text)
                    .font(fontSize)
                    .fontWeight(fontWeight)
                    .lineLimit(1)
                    .foregroundStyle(heading.level == 1 ? .primary : .secondary)

                Spacer()
            }
            .padding(.leading, indentation + 4)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(isHovered ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.3) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var headingLevelColor: Color {
        switch heading.level {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        case 4: return .purple
        default: return .gray
        }
    }
}
