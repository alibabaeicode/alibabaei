import SwiftUI

/// The calm washi-paper field shared across the Moment loop.
///
/// A soft radial wash from paper to a slightly deeper paper — a little depth,
/// never glossy (§7). Place it at the back of a screen.
struct PaperBackground: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [Theme.Color.paper, Theme.Color.paperDeep]),
            center: .center,
            startRadius: 80,
            endRadius: 520
        )
        .ignoresSafeArea()
    }
}
