import SwiftUI

/// **Name** — the second stage of a Moment (CLAUDE.md §6.3).
///
/// Word-first: the curated palette is the first thing met. A quiet question sits
/// above it. Picking one word is enough to complete the stage (the minimum
/// Moment). A shame-free "can't name it" path opens a free-text field — writing
/// your own is equal to picking, not a fallback. Once a word is chosen, an
/// *optional* body step softly reveals beneath; it's clearly skippable.
///
/// Nothing here judges: every word and every body location gets identical
/// treatment, drawn only from Theme tokens — no valence color, no emoji, no
/// ranking. The app mirrors; it never evaluates.
struct NameView: View {

    /// Called when the person has named what's here and continues.
    var onComplete: (MomentDraft) -> Void = { _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Word
    @State private var chosenWord: String?
    @State private var chosenBand: Band?
    @State private var writingOwn = false
    @State private var typedWord = ""
    @FocusState private var typing: Bool

    // Body (optional, second)
    @State private var chosenBody: String?

    private var hasWord: Bool { !(chosenWord ?? "").trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            PaperBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    prompt
                    palette
                    nameYourOwn

                    if hasWord {
                        bodySection
                            .transition(.opacity)
                        continueAffordance
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.xxl)
                .padding(.bottom, Theme.Spacing.xxl)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Prompt

    /// One calm question. Never clinical, never a test.
    private var prompt: some View {
        Text("What's here right now?")
            .font(Theme.Font.serif(27, relativeTo: .title))
            .foregroundStyle(Theme.Color.ink.opacity(0.85))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, Theme.Spacing.xs)
    }

    // MARK: - Word palette

    /// The flat, non-hierarchical set of words. Order is interleaved by config
    /// so no good→bad gradient is implied; all chips are visually equal.
    private var palette: some View {
        FlowLayout(spacing: Theme.Spacing.sm, alignment: .leading) {
            ForEach(MomentConfig.words) { choice in
                ChoiceChip(
                    label: choice.word,
                    isSelected: !writingOwn && chosenWord == choice.word
                ) {
                    pick(choice)
                }
            }
        }
    }

    // MARK: - Write your own ("can't name it")

    @ViewBuilder private var nameYourOwn: some View {
        if writingOwn {
            VStack(spacing: Theme.Spacing.xs) {
                TextField("it feels like…", text: $typedWord)
                    .font(Theme.Font.serif(20, relativeTo: .title3))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.Color.ink)
                    .focused($typing)
                    .submitLabel(.done)
                    .onChange(of: typedWord) { _, newValue in
                        // Writing your own is its own word — band is nil (§3).
                        withAnimation(.easeInOut(duration: 0.25)) {
                            chosenWord = newValue
                            chosenBand = nil
                        }
                    }
                    .padding(.bottom, Theme.Spacing.xs)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.stoneFirm)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        } else {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    writingOwn = true
                    chosenWord = nil
                    chosenBand = nil
                }
                typing = true
            } label: {
                Text("can't name it")
                    .font(Theme.Font.mono(13, relativeTo: .footnote))
                    .tracking(1)
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Body (optional, second)

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Where does it sit?")
                    .font(Theme.Font.serif(20, relativeTo: .title3))
                    .foregroundStyle(Theme.Color.ink.opacity(0.7))
                Text("optional — or just continue")
                    .font(Theme.Font.mono(11, relativeTo: .caption2))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Color.ink.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // TODO: a "what does the body signal" helper — not built yet (§6.3).

            FlowLayout(spacing: Theme.Spacing.sm, alignment: .leading) {
                ForEach(MomentConfig.bodyLocations, id: \.self) { location in
                    ChoiceChip(
                        label: location,
                        isSelected: chosenBody == location,
                        font: Theme.Font.sans(15, relativeTo: .subheadline)
                    ) {
                        toggleBody(location)
                    }
                }
                // "not sure" sits among the locations, equal in weight.
                ChoiceChip(
                    label: MomentConfig.bodyNotSure,
                    isSelected: chosenBody == MomentConfig.bodyNotSure,
                    font: Theme.Font.sans(15, relativeTo: .subheadline)
                ) {
                    toggleBody(MomentConfig.bodyNotSure)
                }
            }
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Continue

    private var continueAffordance: some View {
        Button(action: finish) {
            Text("continue")
                .font(Theme.Font.mono(13, relativeTo: .footnote))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
        }
        .buttonStyle(.plain)
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Actions

    private func pick(_ choice: WordChoice) {
        withAnimation(.easeInOut(duration: 0.25)) {
            writingOwn = false
            typedWord = ""
            chosenWord = choice.word
            chosenBand = choice.band
        }
        typing = false
    }

    /// Single-select; tapping the chosen location again clears it (a quiet skip).
    private func toggleBody(_ location: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            chosenBody = (chosenBody == location) ? nil : location
        }
    }

    private func finish() {
        let word = (chosenWord ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }
        onComplete(MomentDraft(word: word, band: chosenBand, bodyLocation: chosenBody))
    }
}

#Preview {
    NameView()
}
