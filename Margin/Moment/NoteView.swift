import SwiftUI

/// **Note** — the third stage of a Moment (CLAUDE.md §6.4).
///
/// One optional free-text line, and never required. A gentle "let it be" saves
/// the Moment without a word written — an equal, natural choice, no guilt, no
/// "are you sure?". If something is written, the same action becomes "save".
/// An empty note is simply no note (`nil`).
///
/// In v1 this text is **never read by any model** — it's stored for the person
/// themselves. No analysis, no sentiment, no processing (§2, §6.4).
struct NoteView: View {

    /// The Moment so far (word, band, body). Note is added here.
    let draft: MomentDraft
    /// Called when the stage completes, with the note filled in (or left nil).
    var onComplete: (MomentDraft) -> Void = { _ in }

    @State private var text = ""
    @FocusState private var typing: Bool

    private var noteFont: Font { Theme.Font.serif(19, relativeTo: .body) }
    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasNote: Bool { !trimmed.isEmpty }

    var body: some View {
        ZStack {
            PaperBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    prompt
                    field
                    completion
                        .padding(.top, Theme.Spacing.sm)
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

    /// A quiet invitation, never a demand.
    private var prompt: some View {
        Text("Anything you'd like to say about this?")
            .font(Theme.Font.serif(27, relativeTo: .title))
            .foregroundStyle(Theme.Color.ink.opacity(0.85))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Field

    /// A soft "well" in the paper to write into — matte, low-chrome, not a form.
    private var field: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("in your own words…")
                    .font(noteFont)
                    .foregroundStyle(Theme.Color.ink.opacity(0.3))
                    .allowsHitTesting(false)
            }
            TextField("", text: $text, axis: .vertical)
                .font(noteFont)
                .lineLimit(MomentConfig.noteLineLimit)
                .foregroundStyle(Theme.Color.ink)
                .tint(Theme.Color.clay)
                .focused($typing)
        }
        .frame(minHeight: 96, alignment: .topLeading)
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .fill(Theme.Color.ink.opacity(0.035))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .strokeBorder(Theme.Color.stone, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Completion

    /// One gentle action. "let it be" when nothing is written (saves no note);
    /// "save" once there's something to keep. Both simply complete the stage.
    private var completion: some View {
        Button(action: finish) {
            Text(hasNote ? "save" : "let it be")
                .font(Theme.Font.mono(13, relativeTo: .footnote))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: hasNote)
    }

    // MARK: - Action

    private func finish() {
        var completed = draft
        completed.note = hasNote ? trimmed : nil
        onComplete(completed)
    }
}

#Preview {
    NoteView(draft: MomentDraft(word: "light", band: .settled))
}
