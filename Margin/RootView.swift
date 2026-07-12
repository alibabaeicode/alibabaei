import SwiftUI
import SwiftData

/// The app's root surface. Home is the base; a Moment (Settle → Name → Note)
/// begins from Home, saves on device, and returns to Home.
struct RootView: View {
    private enum Stage { case home, settle, name, note }

    @Environment(\.modelContext) private var modelContext

    @State private var stage: Stage = .home
    /// The Moment being built, carried across the stages.
    @State private var draft: MomentDraft?

    var body: some View {
        ZStack {
            switch stage {
            case .home:
                HomeView(onBegin: { go(.settle) })
                    .transition(.opacity)
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
                        // TODO: the staged reveal (insight line first, then the
                        // Field, then recent) once the insight engine exists.
                        go(.home)
                    })
                    .transition(.opacity)
                }
            }
        }
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
    }

    private func go(_ next: Stage) {
        withAnimation(.easeInOut(duration: 0.6)) { stage = next }
    }
}

#Preview {
    RootView()
        .modelContainer(for: Moment.self, inMemory: true)
}
