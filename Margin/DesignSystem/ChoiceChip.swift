import SwiftUI

/// A soft, equal-weight chip for a single choice.
///
/// Every chip looks the same regardless of what it holds — no valence color, no
/// emoji, no hierarchy. Selection is shown only with a quiet ink wash and a
/// firmer stone border. This is what keeps the word palette non-judgmental
/// (CLAUDE.md §1, §6.3).
struct ChoiceChip: View {
    let label: String
    var isSelected: Bool = false
    var font: Font = Theme.Font.serif(18, relativeTo: .body)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(font)
                .foregroundStyle(Theme.Color.ink.opacity(isSelected ? 1 : 0.78))
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Capsule().fill(isSelected ? Theme.Color.ink.opacity(0.06) : Color.clear)
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Theme.Color.stoneFirm : Theme.Color.stone,
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
