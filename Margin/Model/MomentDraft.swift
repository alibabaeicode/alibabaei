import Foundation

/// A Moment being built across the loop's stages, before it's saved.
///
/// Mirrors the `Moment` record (CLAUDE.md §3) but holds only what's gathered so
/// far. Persistence (SwiftData) isn't built yet, so this is the in-flight value
/// passed between stages. `band` is `nil` for a written-in word; `bodyLocation`
/// and `note` are optional.
struct MomentDraft {
    var word: String
    var band: Band?
    var bodyLocation: String?
    var note: String?

    init(word: String, band: Band? = nil, bodyLocation: String? = nil, note: String? = nil) {
        self.word = word
        self.band = band
        self.bodyLocation = bodyLocation
        self.note = note
    }
}
