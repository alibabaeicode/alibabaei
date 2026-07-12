import Foundation
import SwiftData

/// A recorded Moment — the single core record (CLAUDE.md §3), stored on device.
///
/// The `word` (including a written-in word) and the `note` are kept **only for
/// the person**. In v1 they are never read by any model — no analysis, no
/// sentiment, no processing (§2 guardrail).
///
/// `band` is stored as its raw string (`bandRaw`) so the optional — `nil` for a
/// written-in word we can't infer — persists simply and robustly.
@Model
final class Moment {
    var id: UUID
    var timestamp: Date
    var word: String
    var bodyLocation: String?
    var note: String?

    /// Backing storage for `band`. Persisted; use `band` to read/write.
    private var bandRaw: String?

    /// The coarse state, or `nil` for a written-in word (§3).
    var band: Band? {
        get { bandRaw.flatMap(Band.init(rawValue:)) }
        set { bandRaw = newValue?.rawValue }
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        band: Band? = nil,
        word: String,
        bodyLocation: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.bandRaw = band?.rawValue
        self.word = word
        self.bodyLocation = bodyLocation
        self.note = note
    }
}
