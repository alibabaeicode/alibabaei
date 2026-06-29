import SwiftUI

/// A Moment's coarse state (CLAUDE.md §3).
///
/// This is *energy/tone*, never good-or-bad. The three are equally native —
/// Margin mirrors, it never evaluates. `band` is `nil` when a person writes
/// their own word (we can't infer it), and that case is rendered neutrally.
///
/// The band is internal: it feeds the Field and the insight engine later. It is
/// **never shown** in Name and never used to color the word palette.
enum Band: String, Codable, CaseIterable {
    /// High-arousal / charged.
    case activated
    /// Low-energy / heavy.
    case weighted
    /// At ease / calm / light.
    case settled

    /// The band's warm tone, for marks in the Field (§7). Not used in Name.
    var tone: Color {
        switch self {
        case .activated: Theme.Color.activated
        case .weighted:  Theme.Color.weighted
        case .settled:   Theme.Color.settled
        }
    }
}
