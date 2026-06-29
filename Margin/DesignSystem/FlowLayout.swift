import SwiftUI

/// A simple wrapping layout: items flow left-to-right and wrap to the next line.
/// Each row is anchored by `alignment` (centered by default). Used for the word
/// palette and body chips so the set reads as a flat, balanced field rather than
/// a ranked list (§6.3).
struct FlowLayout: Layout {
    var spacing: CGFloat = Theme.Spacing.xs
    /// How each row is anchored across the available width.
    var alignment: HorizontalAlignment = .center

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widestRow = max(widestRow, x - spacing)
        }

        let width = maxWidth == .infinity ? widestRow : maxWidth
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxWidth = bounds.width

        // Break into rows exactly as sizeThatFits does, then center each row.
        var rows: [[(index: Int, size: CGSize)]] = [[]]
        var x: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append((index, size))
            x += size.width + spacing
        }

        var y = bounds.minY
        for row in rows {
            let rowWidth = row.reduce(0) { $0 + $1.size.width }
                + spacing * CGFloat(max(0, row.count - 1))
            let rowHeight = row.map(\.size.height).max() ?? 0

            var cursorX: CGFloat
            if alignment == .leading {
                cursorX = bounds.minX
            } else if alignment == .trailing {
                cursorX = bounds.minX + (maxWidth - rowWidth)
            } else {
                cursorX = bounds.minX + (maxWidth - rowWidth) / 2
            }

            for item in row {
                subviews[item.index].place(
                    at: CGPoint(x: cursorX, y: y + (rowHeight - item.size.height) / 2),
                    proposal: ProposedViewSize(item.size)
                )
                cursorX += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
}
