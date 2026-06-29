import SwiftUI

/// The app's root surface — for now, the Moment loop as far as it's built.
///
/// Settle → Name. Note and the staged Home aren't built yet, so finishing Name
/// simply returns to a fresh breath. Later stages will route through here.
struct RootView: View {
    private enum Stage { case settle, name }

    @State private var stage: Stage = .settle

    var body: some View {
        ZStack {
            switch stage {
            case .settle:
                SettleView(onContinue: { go(.name) })
                    .transition(.opacity)
            case .name:
                NameView(onComplete: { _ in
                    // Note + staged Home not built yet — begin a fresh Moment.
                    go(.settle)
                })
                .transition(.opacity)
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
