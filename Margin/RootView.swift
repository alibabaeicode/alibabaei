import SwiftUI

/// The app's root surface — for now, the Moment loop as far as it's built.
///
/// Settle → Name → Note. The staged Home/Return and saving (SwiftData) aren't
/// built yet, so finishing Note simply returns to a fresh breath. Later stages
/// will route through here.
struct RootView: View {
    private enum Stage { case settle, name, note }

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
                    NoteView(draft: draft, onComplete: { _ in
                        // TODO: persist the completed Moment with SwiftData
                        // (wired separately). Then the staged Home/Return.
                        self.draft = nil
                        go(.settle)
                    })
                    .transition(.opacity)
                }
            }
        }
    }

    private func go(_ next: Stage) {
        withAnimation(.easeInOut(duration: 0.6)) { stage = next }
    }
}

#Preview {
    RootView()
}
