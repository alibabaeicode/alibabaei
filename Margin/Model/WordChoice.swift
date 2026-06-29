import Foundation

/// One word in the curated palette (CLAUDE.md §6.3).
///
/// Each word carries a `band` so a picked Moment is complete for the Field and
/// the insight engine. The band is **internal only** — every word is shown with
/// identical visual weight; nothing in Name reveals or colors by band.
struct WordChoice: Identifiable, Hashable {
    let word: String
    let band: Band

    var id: String { word }
}
