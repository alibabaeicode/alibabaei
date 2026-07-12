import SwiftUI

/// **The Field** — the generative ink map of a person's Moments (CLAUDE.md §7).
///
/// Each Moment leaves one soft ink mark, toned by its band (a written-in word
/// with no band is neutral). Positions, sizes, and softness are derived
/// deterministically from each Moment's id, so a mark sits in the same place
/// every launch — the map is stable, not reshuffled.
///
/// No ranking, no valence sorting, no good/bad coloring: every mark is the same
/// kind of thing. The app mirrors; it never evaluates.
struct FieldView: View {
    let moments: [Moment]

    private let height: CGFloat = 300
    private let inset: CGFloat = 46

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(moments) { moment in
                    let seed = moment.id
                    let size = 54 + seed.stableUnit(salt: 7) * 58        // 54…112
                    InkMark(tone: moment.band?.tone ?? Theme.Color.neutral)
                        .frame(width: size, height: size)
                        .opacity(0.40 + seed.stableUnit(salt: 3) * 0.26) // 0.40…0.66
                        .position(
                            x: inset + seed.stableUnit(salt: 1) * (geo.size.width - inset * 2),
                            y: inset + seed.stableUnit(salt: 2) * (geo.size.height - inset * 2)
                        )
                }
            }
        }
        .frame(height: height)
    }
}

private extension UUID {
    /// A stable value in `[0, 1)` derived from the UUID bytes (independent of
    /// per-process hashing), varied by `salt`. Used to place a mark the same way
    /// every launch.
    func stableUnit(salt: UInt8 = 0) -> Double {
        var hash: UInt64 = 0xcbf29ce484222325            // FNV-1a offset basis
        withUnsafeBytes(of: uuid) { bytes in
            for byte in bytes { hash = (hash ^ UInt64(byte)) &* 0x100000001b3 }
        }
        hash = (hash ^ UInt64(salt)) &* 0x100000001b3
        return Double(hash % 10_000) / 10_000
    }
}
