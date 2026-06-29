import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Margin's central design tokens.
///
/// One quiet source of truth for color, type, and spacing — applied to real
/// screens as the core loop is built (CLAUDE.md §7). The direction is locked:
/// wabi-sabi / *ma* / sumi ink on washi paper — warm, matte, calm, never glossy.
/// The interface should be nearly invisible, so the user sees themselves.
///
/// These are *starting* tokens from the prototypes; refine them in context.
enum Theme {

    // MARK: - Color

    /// The Margin palette. Warm, matte, paper-and-ink. No pure black, no pure white.
    enum Color {
        /// Sumi ink — primary text and the darkest marks. `#1b1a16`
        static let ink = SwiftUI.Color(hex: 0x1B1A16)
        /// Deep indigo — the weighted band, cool depth. `#233650`
        static let indigo = SwiftUI.Color(hex: 0x233650)

        /// Washi paper — the primary surface. `#efece4`
        static let paper = SwiftUI.Color(hex: 0xEFECE4)
        /// A slightly deeper paper, for layering and recessed surfaces. `#e9e5dc`
        static let paperDeep = SwiftUI.Color(hex: 0xE9E5DC)

        /// Soft stone border. `#ded9ce`
        static let stone = SwiftUI.Color(hex: 0xDED9CE)
        /// A firmer stone border, for emphasis. `#c5c0b4`
        static let stoneFirm = SwiftUI.Color(hex: 0xC5C0B4)

        /// Warm clay accent — the activated band. `#b06040`
        static let clay = SwiftUI.Color(hex: 0xB06040)
        /// Muted gold — the settled band. `#a89668`
        static let gold = SwiftUI.Color(hex: 0xA89668)

        // MARK: Band tones
        //
        // The three coarse states, each with its own warm tone (CLAUDE.md §3, §7).
        // `band` can be nil when the user writes their own word — render that
        // neutral case with `neutral`, never with a band color.

        /// activated = high-arousal / charged.
        static let activated = clay
        /// weighted = low-energy / heavy.
        static let weighted = indigo
        /// settled = at ease / calm / light.
        static let settled = gold
        /// Neutral tone for a nil band (a written-in word we can't infer).
        static let neutral = stoneFirm
    }

    // MARK: - Typography

    /// Margin's three typefaces (CLAUDE.md §7):
    /// - **Newsreader** (serif) — headings and insight lines.
    /// - **Hanken Grotesk** (sans) — UI text.
    /// - **Spline Sans Mono** (mono) — small labels and eyebrows.
    ///
    /// Each helper scales with Dynamic Type via `relativeTo:`. If a custom font
    /// isn't bundled yet, it falls back to a system face with a matching design,
    /// so the skeleton always renders calmly rather than breaking.
    enum Font {
        /// Serif — for headings and the standing insight line.
        static func serif(_ size: CGFloat, relativeTo style: SwiftUI.Font.TextStyle = .body) -> SwiftUI.Font {
            font("Newsreader", fallback: .serif, size: size, relativeTo: style)
        }

        /// Sans — the default UI face.
        static func sans(_ size: CGFloat, relativeTo style: SwiftUI.Font.TextStyle = .body) -> SwiftUI.Font {
            font("HankenGrotesk-Regular", fallback: .default, size: size, relativeTo: style)
        }

        /// Mono — small labels and eyebrows.
        static func mono(_ size: CGFloat, relativeTo style: SwiftUI.Font.TextStyle = .caption) -> SwiftUI.Font {
            font("SplineSansMono-Regular", fallback: .monospaced, size: size, relativeTo: style)
        }

        /// Returns the named custom font when registered, otherwise a system
        /// font with the equivalent design — both scale with Dynamic Type.
        private static func font(
            _ name: String,
            fallback design: SwiftUI.Font.Design,
            size: CGFloat,
            relativeTo style: SwiftUI.Font.TextStyle
        ) -> SwiftUI.Font {
            if FontRegistry.isAvailable(name) {
                return .custom(name, size: size, relativeTo: style)
            }
            return .system(style, design: design)
        }
    }

    // MARK: - Spacing

    /// A small, calm spacing scale. Lots of negative space (*ma*) is the point.
    enum Spacing {
        /// 4
        static let xxs: CGFloat = 4
        /// 8
        static let xs: CGFloat = 8
        /// 12
        static let sm: CGFloat = 12
        /// 16
        static let md: CGFloat = 16
        /// 24
        static let lg: CGFloat = 24
        /// 32
        static let xl: CGFloat = 32
        /// 48
        static let xxl: CGFloat = 48
        /// 64 — generous breathing room around signature moments.
        static let xxxl: CGFloat = 64
    }

    // MARK: - Radius

    /// Soft, unhurried corners.
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 22
    }
}

// MARK: - Color from hex

private extension Color {
    /// Builds an opaque color from a 24-bit `0xRRGGBB` literal.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - Font availability

private enum FontRegistry {
    /// Caches whether a given PostScript/family name resolves to a real,
    /// registered font so we only ask the font system once per name.
    private static var cache: [String: Bool] = [:]

    static func isAvailable(_ name: String) -> Bool {
        if let known = cache[name] { return known }
        #if canImport(UIKit)
        let resolved = UIFont(name: name, size: 12)?.fontName.caseInsensitiveCompare(name) == .orderedSame
        #else
        let resolved = false
        #endif
        cache[name] = resolved
        return resolved
    }
}
