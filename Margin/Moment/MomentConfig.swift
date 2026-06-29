import Foundation

/// Tunable constants for the Moment loop.
///
/// These are *hypotheses* (CLAUDE.md §8), not gospel — kept in one place so they
/// can be tested and flipped cheaply, never hard-scattered through views.
enum MomentConfig {

    /// How many slow exhales the Settle stage asks for.
    /// Hypothesis: **1** for now (§6.2). A single constant so it can be tested.
    static let breathCount = 1

    /// The length of one slow exhale. Unhurried on purpose.
    static let exhaleDuration: TimeInterval = 5

    /// A brief, calm beat before the breath begins.
    static let settleBeat: TimeInterval = 0.8

    // MARK: - Name

    /// The curated word palette (§6.3) — tunable.
    ///
    /// Valence-balanced and **deliberately interleaved** so no light→heavy
    /// gradient is implied: the order alternates tones on purpose. Do not
    /// re-sort into "positive/negative" groups — the palette must stay flat and
    /// non-judgmental (a guardrail, CLAUDE.md §1, §6.3). Each word's band is
    /// internal only and never shown.
    static let words: [WordChoice] = [
        WordChoice(word: "light",    band: .settled),
        WordChoice(word: "tense",    band: .activated),
        WordChoice(word: "open",     band: .settled),
        WordChoice(word: "heavy",    band: .weighted),
        WordChoice(word: "alive",    band: .activated),
        WordChoice(word: "bright",   band: .settled),
        WordChoice(word: "restless", band: .activated),
        WordChoice(word: "drained",  band: .weighted),
    ]

    /// Optional body locations (§6.3) — tunable. A "not sure" option and a
    /// shame-free skip are added by the Name view, both equal in prominence.
    static let bodyLocations: [String] = [
        "chest", "jaw", "shoulders", "stomach", "head", "hands",
    ]

    /// The value stored when a person taps "not sure" (distinct from skipping,
    /// which leaves `bodyLocation` nil). Matches the data model's note in §3.
    static let bodyNotSure = "not sure"
}
