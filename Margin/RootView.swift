import SwiftUI
import SwiftData

/// The app's root surface — for now, the Moment loop as far as it's built.
///
/// Settle → Name → Note. A completed Moment is saved on device, then the flow
/// returns to a fresh breath (the staged Home/Return isn't built yet).
struct RootView: View {
    private enum Stage { case settle, name, note }

    @Environment(\.modelContext) private var modelContext

    @State private var stage: Stage = .settle
    /// The Moment being built, carried across the stages.
    @State private var draft: MomentDraft?

    var body: some View {
        ZStack {
            switch stage {
            case .settle:
                SettleView(onContinue: { go(.name) })
                    .transition(.opacity)
            case .name:
                NameView(onComplete: { named in
                    draft = named
                    go(.note)
                })
                .transition(.opacity)
            case .note:
                if let draft {
                    NoteView(draft: draft, onComplete: { completed in
                        save(completed)
                        self.draft = nil
                        go(.settle)
                    })
                    .transition(.opacity)
                }
            }
        }
        // TEMP: confirm saved Moments survive launches (see TEMP_MomentLog).
        .onAppear { TEMP_MomentLog.dumpAll(modelContext) }
    }

    /// Persists the whole Moment once, at the end of the flow. Invisible and
    /// instant — no confirmation, no interruption to the pacing.
    private func save(_ draft: MomentDraft) {
        let moment = Moment(
            band: draft.band,
            word: draft.word,
            bodyLocation: draft.bodyLocation,
            note: draft.note
        )
        modelContext.insert(moment)
        try? modelContext.save()
        TEMP_MomentLog.logSaved(moment) // TEMP: remove with TEMP_MomentLog.
    }

    private func go(_ next: Stage) {
        withAnimation(.easeInOut(duration: 0.6)) { stage = next }
    }
}

#Preview {
    RootView()
        .modelContainer(for: Moment.self, inMemory: true)
}
