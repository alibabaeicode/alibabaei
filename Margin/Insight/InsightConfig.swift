import Foundation

/// Tunable thresholds and gates for the insight engine (CLAUDE.md §5).
///
/// These exist so honesty can be tuned without touching rule logic. They are
/// deliberately conservative: a pattern must clear a real bar before it may be
/// claimed. When in doubt, raise the gate — a quiet Home is correct.
enum InsightConfig {

    /// The standing line looks at roughly the last week.
    static let standingWindowDays = 7

    // MARK: Pattern sufficiency gates (both must pass before ANY pattern fires)

    /// A pattern may not be claimed from a handful of marks…
    static let minMomentsForPattern = 8
    /// …nor from a single day (or two). A pattern needs days behind it.
    static let minDistinctDaysForPattern = 4

    // MARK: Time-of-day rule

    /// The band in question must appear at least this many times.
    static let minBandCountForTimeRule = 4
    /// …with at least this share of its moments concentrated in one part of day.
    static let timeConcentration = 0.6
    /// …and the data must actually span more than one part of day (otherwise
    /// "gather in the afternoon" would just mean "only used it that afternoon").
    static let minCoveredPartsForTimeRule = 2

    // MARK: Balance rule

    /// The leading band must outweigh the next by at least this ratio…
    static let balanceMargin = 1.6
    /// …and the next band must itself be real, so the comparison means something.
    static let minSecondBandForBalance = 2

    // MARK: Cold start

    /// At/below this many marks, the standing line reflects the act of pausing,
    /// not a trend — never a pattern.
    static let coldStartThreshold = 3
}
