import SwiftUI

/// **Settle** — the first stage of a Moment (CLAUDE.md §6.2).
///
/// One slow exhale. Nothing is tappable until the breath completes; the
/// "continue" affordance appears only after. The ink blooms and settles on the
/// exhale and becomes the first mark of this Moment — later, it carries into
/// the Field. Required and minimal: we guide a single breath, then step back.
struct SettleView: View {

    /// Called once the person has breathed and chosen to move on.
    var onContinue: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 0…1 — how far the ink has bloomed and settled.
    @State private var bloom: CGFloat = 0
    @State private var guidanceShown = true
    @State private var continueShown = false

    var body: some View {
        ZStack {
            background

            InkMark(tone: Theme.Color.ink)
                .frame(width: 240, height: 240)
                .scaleEffect(0.35 + bloom * 0.65)
                .opacity(0.15 + Double(bloom) * 0.85)

            VStack {
                Spacer()
                guidance
                Spacer()
                continueAffordance
                    .frame(height: Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.xxl)
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .task { await breathe() }
    }

    // MARK: - Pieces

    /// A soft paper field with a little depth (§7: depth, soft layering).
    private var background: some View {
        RadialGradient(
            gradient: Gradient(colors: [Theme.Color.paper, Theme.Color.paperDeep]),
            center: .center,
            startRadius: 80,
            endRadius: 520
        )
        .ignoresSafeArea()
    }

    /// The one calm line. It steps back once the breath is done.
    private var guidance: some View {
        Text("Breathe out, slowly.")
            .font(Theme.Font.serif(22, relativeTo: .title3))
            .foregroundStyle(Theme.Color.ink.opacity(0.7))
            .opacity(guidanceShown ? 1 : 0)
    }

    /// The way forward — rendered only after the breath, so nothing is tappable before.
    @ViewBuilder private var continueAffordance: some View {
        if continueShown {
            Button(action: onContinue) {
                Text("continue")
                    .font(Theme.Font.mono(13, relativeTo: .footnote))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.ink.opacity(0.55))
            }
            .transition(.opacity)
        }
    }

    // MARK: - Breath

    private func breathe() async {
        // Honor Reduce Motion: present the settled mark and the way forward,
        // without the long animation.
        guard !reduceMotion else {
            bloom = 1
            reveal()
            return
        }

        for _ in 0..<max(1, MomentConfig.breathCount) {
            try? await Task.sleep(for: .seconds(MomentConfig.settleBeat))
            withAnimation(.easeInOut(duration: MomentConfig.exhaleDuration)) {
                bloom = 1
            }
            try? await Task.sleep(for: .seconds(MomentConfig.exhaleDuration))
        }

        withAnimation(.easeInOut(duration: 1)) { guidanceShown = false }
        reveal()
    }

    private func reveal() {
        withAnimation(.easeInOut(duration: 1.1)) { continueShown = true }
    }
}

#Preview {
    SettleView()
}
