import SwiftUI

/// A soft, blurred sumi-ink mark — the visual atom of Margin.
///
/// Ink sinking into washi: dense at the center, dissolving to nothing at the
/// edge. It's the breath bloom in Settle and, later, a mark in the Field (§7).
/// Scales with its frame, so callers size it with `.frame(...)` and animate it
/// with `.scaleEffect(...)`.
struct InkMark: View {
    /// The ink tone — defaults to sumi ink; band tones are used in the Field.
    var tone: Color = Theme.Color.ink

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: tone.opacity(0.42), location: 0),
                            .init(color: tone.opacity(0.16), location: 0.5),
                            .init(color: tone.opacity(0),    location: 1),
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .blur(radius: radius * 0.06)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ZStack {
        Theme.Color.paper.ignoresSafeArea()
        InkMark()
            .frame(width: 240, height: 240)
    }
}
